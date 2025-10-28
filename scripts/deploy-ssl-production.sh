#!/bin/bash
set -e

# 🎯 Script de déploiement avec SSL/HTTPS pour Hostinger
# Gère DNS, certificats SSL, et déploiement complet

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration - UTILISEZ DES VARIABLES D'ENVIRONNEMENT POUR LES SECRETS !
GITHUB_USERNAME="${GITHUB_USERNAME:-skaouech}"
REGISTRY="${REGISTRY:-ghcr.io}"
CR_PAT="${CR_PAT:-}"  # ⚠️ DÉFINIR COMME VARIABLE D'ENVIRONNEMENT: export CR_PAT="votre_token"

# Environnement (development ou production)
DEPLOY_ENV="${DEPLOY_ENV:-production}"  # Par défaut: production

# Configuration basée sur l'environnement
if [[ "$DEPLOY_ENV" == "development" ]]; then
    HOSTINGER_IP="${HOSTINGER_DEV_HOST:-148.230.114.13}"
    HOSTINGER_USER="${HOSTINGER_DEV_USER:-root}"
    PROJECT_NAME="dealtobook-dev"
    DOCKER_COMPOSE_FILE="docker-compose.ssl-complete.yml"
    ENV_FILE="dealtobook-ssl-dev.env"
    IMAGE_TAG="develop"
    DOMAINS=("administration-dev.dealtobook.com" "website-dev.dealtobook.com" "keycloak-dev.dealtobook.com")
else
    HOSTINGER_IP="${HOSTINGER_PROD_HOST:-148.230.114.13}"
    HOSTINGER_USER="${HOSTINGER_PROD_USER:-root}"
    PROJECT_NAME="dealtobook"
    DOCKER_COMPOSE_FILE="docker-compose.ssl-complete.yml"
    ENV_FILE="dealtobook-ssl.env"
    IMAGE_TAG="latest"
    DOMAINS=("administration.dealtobook.com" "website.dealtobook.com" "keycloak.dealtobook.com")
fi

# Microservices configuration (using simple arrays for bash compatibility)
BACKEND_SERVICES_DIRS=("deal_generator" "deal_security" "deal_setting")
BACKEND_SERVICES_IMAGES=("dealdealgenerator" "dealsecurity" "dealsetting")

FRONTEND_SERVICES_DIRS=("deal_webui" "deal_website")
FRONTEND_SERVICES_IMAGES=("dealtobook-deal-webui" "dealtobook-deal-website")

# Services spécifiques (peut être modifié par les arguments)
SPECIFIC_SERVICES=()
BUILD_SPECIFIC_SERVICES=false

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Parse specific services from arguments
parse_services() {
    local services_arg="$1"
    if [[ -n "$services_arg" ]]; then
        BUILD_SPECIFIC_SERVICES=true
        IFS=',' read -ra SPECIFIC_SERVICES <<< "$services_arg"
        log "🎯 Services spécifiques sélectionnés: ${SPECIFIC_SERVICES[*]}"
    fi
}

# Check if a service should be processed
should_process_service() {
    local service="$1"
    if [[ "$BUILD_SPECIFIC_SERVICES" == "false" ]]; then
        return 0  # Process all services
    fi
    
    for specific_service in "${SPECIFIC_SERVICES[@]}"; do
        if [[ "$service" == "$specific_service" ]]; then
            return 0  # Process this service
        fi
    done
    return 1  # Skip this service
}

# Configure Java 17 for JHipster compatibility
setup_java17() {
    log "🔧 Configuration de Java 17..."
    
    # Check if Java 17 is available
    if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
        export JAVA_HOME=$(/usr/libexec/java_home -v 17)
        export PATH="$JAVA_HOME/bin:$PATH"
        success "Java 17 configuré: $JAVA_HOME"
        java -version
    else
        error "Java 17 non trouvé. Veuillez installer Java 17 (JDK 11-18 requis pour JHipster)"
    fi
}

run_remote_cmd() {
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "$1"
}

check_prerequisites() {
    local skip_ssh=${1:-false}
    log "🔍 Vérification des prérequis..."
    
    # Setup Java 17 first
    setup_java17
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé"
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose n'est pas installé"
    fi
    
    # Vérifier les variables d'environnement pour GHCR (optionnel pour SSL)
    if [ -n "$CR_PAT" ]; then
        info "Token GHCR détecté - build et push vers GHCR activés"
    else
        warning "Variable CR_PAT non définie - utilisation des images locales uniquement"
    fi
    
    # Vérifier SSH vers Hostinger (sauf pour build local)
    if [ "$skip_ssh" != "true" ]; then
        if ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${HOSTINGER_USER}@${HOSTINGER_IP}" "echo 'SSH OK'" &> /dev/null; then
            error "Impossible de se connecter à Hostinger via SSH"
        fi
    fi
    
    success "Prérequis validés"
}

login_to_ghcr() {
    if [ -n "$CR_PAT" ]; then
        log "🔑 Connexion à GitHub Container Registry..."
        echo "$CR_PAT" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin || error "Échec de la connexion à GHCR"
        success "Connecté à GHCR"
    else
        warning "CR_PAT non défini - pas de connexion GHCR"
    fi
}

check_ssl_certificates() {
    log "🔒 Vérification des certificats SSL..."
    
    for domain in "${DOMAINS[@]}"; do
        log "  Vérification du certificat pour ${domain}..."
        if run_remote_cmd "test -f /etc/letsencrypt/live/${domain}/fullchain.pem"; then
            success "  ✅ Certificat SSL trouvé pour ${domain}"
        else
            warning "  ⚠️  Certificat SSL manquant pour ${domain}"
            return 1
        fi
    done
    
    success "🔒 Tous les certificats SSL sont présents"
}

setup_ssl_certificates() {
    log "🔒 Configuration des certificats SSL avec Let's Encrypt..."
    
    # Arrêter les services qui utilisent les ports 80/443
    run_remote_cmd "docker stop dealtobook-nginx || true"
    run_remote_cmd "systemctl stop nginx || true"
    
    # Installer Certbot si nécessaire
    run_remote_cmd "apt update && apt install -y certbot python3-certbot-nginx"
    
    # Configuration Nginx temporaire pour Certbot
    run_remote_cmd 'cat > /tmp/nginx-temp.conf << "EOF"
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name administration-dev.dealtobook.com website-dev.dealtobook.com keycloak-dev.dealtobook.com;
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location / {
            return 301 https://$host$request_uri;
        }
    }
}
EOF'
    
    # Démarrer Nginx temporaire
    run_remote_cmd "mkdir -p /var/www/certbot"
    run_remote_cmd "cp /tmp/nginx-temp.conf /etc/nginx/nginx.conf"
    run_remote_cmd "systemctl start nginx"
    
    # Obtenir les certificats
    DOMAIN_LIST=$(IFS=' -d '; echo "${DOMAINS[*]}")
    run_remote_cmd "certbot --nginx -d ${DOMAIN_LIST// -d / -d } --non-interactive --agree-tos --email admin@dealtobook.com --expand"
    
    # Arrêter Nginx système
    run_remote_cmd "systemctl stop nginx && systemctl disable nginx"
    
    success "🔒 Certificats SSL configurés avec succès"
}

build_backend_services() {
    log "🏗️ Construction des services backend avec JIB..."
    
    for i in "${!BACKEND_SERVICES_DIRS[@]}"; do
        local service_key="${BACKEND_SERVICES_DIRS[$i]}"
        local image_name="${BACKEND_SERVICES_IMAGES[$i]}"
        local service_dir="../dealtobook-${service_key}"
        
        # Vérifier si ce service doit être traité
        if ! should_process_service "$service_key" && ! should_process_service "$image_name"; then
            info "⏭️ Service $service_key ignoré (non spécifié)"
            continue
        fi
        
        if [ -d "$service_dir" ]; then
            log "  Building $service_key → $image_name..."
            
            (cd "$service_dir" && {
                if [ -n "$CR_PAT" ]; then
                    # Convertir en minuscules pour Docker
                    local image_name_lower=$(echo "$GITHUB_USERNAME/$image_name" | tr '[:upper:]' '[:lower:]')
                    
                    # Build avec JIB et push vers GHCR (compile + build en une étape)
                    ./mvnw compile jib:build -Pprod -DskipTests \
                        -Djib.to.image="$REGISTRY/$image_name_lower:$IMAGE_TAG" \
                        -Djib.to.auth.username="$GITHUB_USERNAME" \
                        -Djib.to.auth.password="$CR_PAT" || error "JIB build failed for $service_key"
                    
                    # Tag avec SHA pour traçabilité
                    local commit_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
                    docker tag "$REGISTRY/$image_name_lower:$IMAGE_TAG" \
                              "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
                    docker push "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
                else
                    # Build local uniquement (compile + build en une étape)
                    ./mvnw compile jib:dockerBuild -Pprod -DskipTests || error "JIB build failed for $service_key"
                fi
            }) || error "Build failed for $service_key"
            
            success "  Service $service_key construit et poussé"
        else
            warning "  Répertoire $service_dir non trouvé"
        fi
    done
}

build_frontend_services() {
    log "🌐 Construction des services frontend..."
    
    for i in "${!FRONTEND_SERVICES_DIRS[@]}"; do
        local service_key="${FRONTEND_SERVICES_DIRS[$i]}"
        local image_name="${FRONTEND_SERVICES_IMAGES[$i]}"
        local service_dir="../dealtobook-${service_key}"
        
        # Vérifier si ce service doit être traité
        if ! should_process_service "$service_key" && ! should_process_service "$image_name"; then
            info "⏭️ Service $service_key ignoré (non spécifié)"
            continue
        fi
        
        if [ -d "$service_dir" ]; then
            log "  Building $service_key → $image_name..."
            
            local dockerfile="Dockerfile.simple"
            if [ "$service_key" = "deal_website" ]; then
                dockerfile="Dockerfile.frontend"
            fi
            
            if [ -n "$CR_PAT" ]; then
                # Convertir en minuscules pour Docker
                local image_name_lower=$(echo "$GITHUB_USERNAME/$image_name" | tr '[:upper:]' '[:lower:]')
                
                # Build et push vers GHCR avec architecture linux/amd64
                docker build --platform linux/amd64 -t "$REGISTRY/$image_name_lower:$IMAGE_TAG" \
                            -f "$service_dir/$dockerfile" "$service_dir/" || error "Docker build failed for $service_key"
                
                docker push "$REGISTRY/$image_name_lower:$IMAGE_TAG" || error "Docker push failed for $service_key"
                
                # Tag avec SHA pour traçabilité
                local commit_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
                docker tag "$REGISTRY/$image_name_lower:$IMAGE_TAG" \
                          "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
                docker push "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
            else
                # Build local uniquement avec architecture linux/amd64
                docker build --platform linux/amd64 -t "$image_name:latest" \
                            -f "$service_dir/$dockerfile" "$service_dir/" || error "Docker build failed for $service_key"
            fi
            
            success "  Service $service_key construit"
        else
            warning "  Répertoire $service_dir non trouvé"
        fi
    done
}

deploy_to_hostinger() {
    log "🚀 Déploiement sur Hostinger..."
    
    # Créer le répertoire de projet sur Hostinger
    run_remote_cmd "mkdir -p /opt/${PROJECT_NAME}/{nginx,monitoring/grafana/provisioning/{datasources,dashboards},scripts}"
    
    # Transférer les fichiers de configuration
    log "  Transfert des fichiers de configuration..."
    scp -o StrictHostKeyChecking=no "$DOCKER_COMPOSE_FILE" "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || error "Failed to transfer docker-compose"
    scp -o StrictHostKeyChecking=no "$ENV_FILE" "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/.env" || error "Failed to transfer .env file"
    
    # Transférer la configuration Nginx
    if [ -d "nginx" ]; then
        scp -r -o StrictHostKeyChecking=no nginx/ "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || warning "Failed to transfer nginx config"
    fi
    
    # Transférer la configuration de monitoring
    if [ -d "monitoring" ]; then
        scp -r -o StrictHostKeyChecking=no monitoring/ "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || warning "Failed to transfer monitoring config"
    fi
    
    # Transférer les scripts
    if [ -d "scripts" ]; then
        scp -r -o StrictHostKeyChecking=no scripts/ "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || warning "Failed to transfer scripts"
    fi
    
    # Transférer keycloak them
    if [ -d "keycloak-themes" ]; then
        scp -r -o StrictHostKeyChecking=no keycloak-themes/ "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || warning "Failed to transfer keycloak-themes"
    fi

    success "Configuration transférée"
}

start_services_on_hostinger() {
    log "🔄 Démarrage des services sur Hostinger..."
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        # Login to GHCR if available
        if [ -n '$CR_PAT' ]; then
            echo '$CR_PAT' | docker login ghcr.io -u '$GITHUB_USERNAME' --password-stdin
            # Pull des nouvelles images
            if [ '$BUILD_SPECIFIC_SERVICES' = 'true' ]; then
                # Pull seulement les services spécifiés
                services_to_pull=''
                for service in ${SPECIFIC_SERVICES[@]}; do
                    case \$service in
                        'deal_generator'|'dealdealgenerator')
                            services_to_pull+=\" deal-generator\"
                            ;;
                        'deal_security'|'dealsecurity')
                            services_to_pull+=\" deal-security\"
                            ;;
                        'deal_setting'|'dealsetting')
                            services_to_pull+=\" deal-setting\"
                            ;;
                        'deal_webui'|'dealtobook-deal-webui')
                            services_to_pull+=\" deal-webui\"
                            ;;
                        'deal_website'|'dealtobook-deal-website')
                            services_to_pull+=\" deal-website\"
                            ;;
                        'keycloak')
                            services_to_pull+=\" keycloak\"
                            ;;
                        'postgres'|'postgresql')
                            services_to_pull+=\" postgres\"
                            ;;
                        *)
                            services_to_pull+=\" \$service\"
                            ;;
                    esac
                done
                if [ -n '$CR_PAT' ]; then
                    echo \"🎯 Pull des images spécifiques:\$services_to_pull\"
                    docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env pull\$services_to_pull
                else
                    echo \"🎯 Utilisation des images locales (pas de pull)\"
                fi
            else
                if [ -n '$CR_PAT' ]; then
                    docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env pull
                else
                    echo \"🎯 Utilisation des images locales (pas de pull)\"
                fi
            fi
        fi
    
    # Arrêter les anciens services
        if [ '$BUILD_SPECIFIC_SERVICES' = 'true' ]; then
            # Arrêter seulement les services spécifiés
            services_to_stop=''
            for service in ${SPECIFIC_SERVICES[@]}; do
                case \$service in
                    'deal_generator'|'dealdealgenerator')
                        services_to_stop+=\" deal-generator\"
                        ;;
                    'deal_security'|'dealsecurity')
                        services_to_stop+=\" deal-security\"
                        ;;
                    'deal_setting'|'dealsetting')
                        services_to_stop+=\" deal-setting\"
                        ;;
                    'deal_webui'|'dealtobook-deal-webui')
                        services_to_stop+=\" deal-webui\"
                        ;;
                    'deal_website'|'dealtobook-deal-website')
                        services_to_stop+=\" deal-website\"
                        ;;
                    'keycloak')
                        services_to_stop+=\" keycloak\"
                        ;;
                    'postgres'|'postgresql')
                        services_to_stop+=\" postgres\"
                        ;;
                    *)
                        services_to_stop+=\" \$service\"
                        ;;
                esac
            done
            echo \"🎯 Arrêt des services spécifiques:\$services_to_stop\"
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env stop\$services_to_stop || true
        else
            # Arrêter tous les services
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env down --remove-orphans || true
        fi
    
    # Créer le réseau Docker
        docker network create dealtobook-network || true
    
    # Démarrer les services
        if [ '$BUILD_SPECIFIC_SERVICES' = 'true' ]; then
            # Construire la liste des services à démarrer
            services_to_start=''
            for service in ${SPECIFIC_SERVICES[@]}; do
                case \$service in
                    'deal_generator'|'dealdealgenerator')
                        services_to_start+=\" deal-generator\"
                        ;;
                    'deal_security'|'dealsecurity')
                        services_to_start+=\" deal-security\"
                        ;;
                    'deal_setting'|'dealsetting')
                        services_to_start+=\" deal-setting\"
                        ;;
                    'deal_webui'|'dealtobook-deal-webui')
                        services_to_start+=\" deal-webui\"
                        ;;
                    'deal_website'|'dealtobook-deal-website')
                        services_to_start+=\" deal-website\"
                        ;;
                    'keycloak')
                        services_to_start+=\" keycloak\"
                        ;;
                    'postgres'|'postgresql')
                        services_to_start+=\" postgres\"
                        ;;
                    *)
                        services_to_start+=\" \$service\"
                        ;;
                esac
            done
            echo \"🎯 Démarrage des services spécifiques:\$services_to_start\"
            if [ -n '$CR_PAT' ]; then
                docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --pull always\$services_to_start
            else
                docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d\$services_to_start
            fi
        else
            # Démarrage séquentiel des services pour éviter les conflits de dépendances
            echo \"🚀 Démarrage séquentiel des services avec force-recreate...\"
            
            # Arrêter tous les services d'abord pour forcer la récupération des nouvelles images
            echo \"🛑 Arrêt des services existants...\"
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env down --remove-orphans
            
            # 1. Infrastructure de base
            echo \"📊 Démarrage de l'infrastructure...\"
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate postgres redis zipkin prometheus grafana
            sleep 10
            
            # 2. Keycloak (dépend de PostgreSQL)
            echo \"🔐 Démarrage de Keycloak...\"
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate keycloak
            sleep 15
            
            # 3. Services backend (dépendent de Keycloak et PostgreSQL)
            echo \"⚙️ Démarrage des services backend...\"
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate deal-generator deal-security deal-setting
            sleep 20
            
            # 4. Services frontend (dépendent des services backend) - FORCE RECREATE pour nouvelles images
            echo \"🌐 Démarrage des services frontend avec nouvelles images...\"
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate deal-webui deal-website
            sleep 10
            
            # 5. Nginx (dépend de tous les autres services)
            echo \"🔄 Démarrage de Nginx...\"
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate nginx
            
            echo \"✅ Tous les services démarrés séquentiellement avec force-recreate\"
        fi
        
        echo 'Services démarrés'
    }" || error "Échec du démarrage des services"
    
    success "Services démarrés sur Hostinger"
}

setup_databases() {
    log "🗄️ Configuration des bases de données..."
    
    # Attendre que PostgreSQL soit prêt
    log "  Attente de PostgreSQL (60s)..."
    sleep 60
    
    # Créer les bases de données
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        # Créer les bases de données si elles n'existent pas
        docker exec dealtobook-postgres psql -U dealtobook -d dealtobook_db -c 'CREATE DATABASE IF NOT EXISTS deal_setting;' 2>/dev/null || true
        docker exec dealtobook-postgres psql -U dealtobook -d dealtobook_db -c 'CREATE DATABASE IF NOT EXISTS keycloak;' 2>/dev/null || true
        docker exec dealtobook-postgres psql -U dealtobook -d dealtobook_db -c 'CREATE DATABASE IF NOT EXISTS deal_generator;' 2>/dev/null || true
        
        echo 'Bases de données configurées'
    }" || warning "Erreur lors de la configuration des bases de données"
    
    # Redémarrer les services backend
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env restart deal-generator deal-security deal-setting
        echo 'Services backend redémarrés'
    }" || warning "Erreur lors du redémarrage des services backend"
    
    success "Bases de données configurées"
}

setup_keycloak_realm() {
    log "🔐 Configuration du realm Keycloak..."
    
    # Attendre que Keycloak soit prêt
    log "  Attente de Keycloak (90s)..."
    sleep 90
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        # Obtenir le token d'admin
        ADMIN_TOKEN=\$(curl -s -X POST 'https://keycloak-dev.dealtobook.com/realms/master/protocol/openid-connect/token' \
            -H 'Content-Type: application/x-www-form-urlencoded' \
            -d 'username=admin' \
            -d 'password=${KEYCLOAK_ADMIN_PASSWORD:-admin123}' \
            -d 'grant_type=password' \
            -d 'client_id=admin-cli' \
            --insecure | jq -r '.access_token' 2>/dev/null || echo 'null')
        
        if [ \"\$ADMIN_TOKEN\" != 'null' ] && [ -n \"\$ADMIN_TOKEN\" ]; then
            echo 'Token admin obtenu'
            
            # Créer le realm dealtobook
            curl -s -X POST 'https://keycloak-dev.dealtobook.com/admin/realms' \
                -H \"Authorization: Bearer \$ADMIN_TOKEN\" \
                -H 'Content-Type: application/json' \
                --insecure \
                -d '{
                    \"realm\": \"dealtobook\",
                    \"displayName\": \"DealToBook Realm\",
                    \"enabled\": true,
                    \"sslRequired\": \"external\",
                    \"registrationAllowed\": true,
                    \"loginWithEmailAllowed\": true,
                    \"duplicateEmailsAllowed\": false,
                    \"resetPasswordAllowed\": true,
                    \"editUsernameAllowed\": false,
                    \"bruteForceProtected\": true
                }' 2>/dev/null || true
            
            # Créer le client
            curl -s -X POST 'https://keycloak-dev.dealtobook.com/admin/realms/dealtobook/clients' \
                -H \"Authorization: Bearer \$ADMIN_TOKEN\" \
                -H 'Content-Type: application/json' \
                --insecure \
                -d '{
                    \"clientId\": \"dealtobook-app\",
                    \"name\": \"DealToBook Application\",
                    \"enabled\": true,
                    \"clientAuthenticatorType\": \"client-secret\",
                    \"secret\": \"dealtobook-secret\",
                    \"standardFlowEnabled\": true,
                    \"implicitFlowEnabled\": false,
                    \"directAccessGrantsEnabled\": true,
                    \"serviceAccountsEnabled\": true,
                    \"publicClient\": false,
                    \"protocol\": \"openid-connect\",
                    \"redirectUris\": [
                        \"https://administration-dev.dealtobook.com/*\",
                        \"https://website-dev.dealtobook.com/*\"
                    ],
                    \"webOrigins\": [
                        \"https://administration-dev.dealtobook.com\",
                        \"https://website-dev.dealtobook.com\"
                    ]
                }' 2>/dev/null || true
            
            echo 'Realm et client Keycloak configurés'
        else
            echo 'Impossible d obtenir le token admin Keycloak'
        fi
    }" || warning "Erreur lors de la configuration Keycloak"
    
    success "Keycloak configuré"
}

redeploy_services_only() {
    log "🔄 Redéploiement rapide des services (sans rebuild)..."
    
    # Transférer les fichiers de configuration mis à jour
    deploy_to_hostinger
    
    # Arrêter et redémarrer les services avec force-recreate
    run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env down --remove-orphans"
    run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env up -d --force-recreate" || error "Docker Compose redeploy failed"
    
    log "⏳ Attente de 30 secondes pour le redémarrage des services..."
    sleep 30
    
    success "🔄 Services redéployés avec succès"
}

test_ssl_endpoints() {
    log "🌐 Test des endpoints HTTPS..."
    
    for domain in "${DOMAINS[@]}"; do
        log "  Test de https://${domain}..."
        if run_remote_cmd "curl -s -I https://${domain} | head -1"; then
            success "  ✅ ${domain} répond"
        else
            warning "  ⚠️  ${domain} ne répond pas"
        fi
    done
}

health_check() {
    log "🔍 Vérification de la santé des services..."
    
    # Attendre la stabilisation
    log "  Attente de la stabilisation (60s)..."
    sleep 60
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        echo '📊 Status des conteneurs :'
        docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
        
        echo -e '\n🧪 Health checks :'
        
        # Test des endpoints backend
        for port in 8081 8082 8083; do
            service_name=\$(case \$port in 8081) echo 'generator';; 8082) echo 'security';; 8083) echo 'setting';; esac)
            echo -n \"  • deal_\$service_name (\$port): \"
            if curl -s -f http://localhost:\$port/management/health > /dev/null 2>&1; then
                echo '✅ Healthy'
            else
                echo '❌ Unhealthy'
            fi
        done
        
        # Test des endpoints HTTPS
        echo -n '  • WebUI (HTTPS): '
        if curl -s -I https://administration-dev.dealtobook.com 2>/dev/null | head -1 | grep -q '200\|301\|302'; then
            echo '✅ Accessible'
        else
            echo '❌ Not accessible'
        fi
        
        echo -n '  • Website (HTTPS): '
        if curl -s -I https://website-dev.dealtobook.com 2>/dev/null | head -1 | grep -q '200\|301\|302'; then
            echo '✅ Accessible'
        else
            echo '❌ Not accessible'
        fi
        
        echo -n '  • Keycloak (HTTPS): '
        if curl -s -I https://keycloak-dev.dealtobook.com 2>/dev/null | head -1 | grep -q '200\|301\|302'; then
            echo '✅ Accessible'
        else
            echo '❌ Not accessible'
        fi
    }" || warning "Erreur lors de la vérification de santé"
    
    success "Vérification de santé terminée"
}

show_deployment_summary() {
    log "✅ DÉPLOIEMENT TERMINÉ !"
    echo ""
    echo -e "${GREEN}🎉 DEALTOBOOK DÉPLOYÉ AVEC SUCCÈS !${NC}"
    echo "=================================================="
    echo ""
    echo -e "${BLUE}🌐 Applications HTTPS :${NC}"
    echo "  • Administration: https://administration-dev.dealtobook.com"
    echo "  • Website: https://website-dev.dealtobook.com"
    echo "  • Keycloak: https://keycloak-dev.dealtobook.com"
    echo ""
    echo -e "${BLUE}📊 Monitoring :${NC}"
    echo "  • Prometheus: http://$HOSTINGER_IP:9090"
    echo "  • Grafana: http://$HOSTINGER_IP:3000 (admin/admin)"
    echo "  • Zipkin: http://$HOSTINGER_IP:9411"
    echo ""
    echo -e "${BLUE}🔧 APIs Backend :${NC}"
    echo "  • Generator: http://$HOSTINGER_IP:8081/management/health"
    echo "  • Security: http://$HOSTINGER_IP:8082/management/health"
    echo "  • Setting: http://$HOSTINGER_IP:8083/management/health"
    echo ""
    echo -e "${PURPLE}🚀 Commandes utiles :${NC}"
    echo "  • Status: ssh $HOSTINGER_USER@$HOSTINGER_IP 'cd /opt/$PROJECT_NAME && docker-compose ps'"
    echo "  • Logs: ssh $HOSTINGER_USER@$HOSTINGER_IP 'cd /opt/$PROJECT_NAME && docker-compose logs -f'"
    echo "  • Restart: ssh $HOSTINGER_USER@$HOSTINGER_IP 'cd /opt/$PROJECT_NAME && docker-compose restart'"
}

main() {
    echo -e "${PURPLE}"
    echo "🚀 ===== DÉPLOIEMENT DEALTOBOOK AVEC SSL ====="
    echo "=============================================="
    echo -e "${NC}"
    
    # Afficher l'environnement actif
    if [[ "$DEPLOY_ENV" == "development" ]]; then
        echo -e "${YELLOW}📍 Environnement: DEVELOPMENT${NC}"
        echo -e "   🖥️  Serveur: $HOSTINGER_IP"
        echo -e "   📁 Dossier: /opt/$PROJECT_NAME"
        echo -e "   🏷️  Tag images: $IMAGE_TAG"
    else
        echo -e "${GREEN}📍 Environnement: PRODUCTION${NC}"
        echo -e "   🖥️  Serveur: $HOSTINGER_IP"
        echo -e "   📁 Dossier: /opt/$PROJECT_NAME"
        echo -e "   🏷️  Tag images: $IMAGE_TAG"
    fi
    echo ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
    
    # Parse services spécifiques si fournis
    if [[ "$2" =~ ^[a-zA-Z_,]+$ ]]; then
        parse_services "$2"
    fi
    
    case "$1" in
        ssl-setup)
            check_prerequisites
            setup_ssl_certificates
            ;;
        build)
            check_prerequisites true  # Skip SSH check for build-only
            login_to_ghcr
            build_backend_services
            build_frontend_services
            ;;
        deploy)
            check_prerequisites
            login_to_ghcr
            
            # Vérifier les certificats SSL
            if ! check_ssl_certificates; then
                warning "Certificats SSL manquants. Exécutez d'abord: $0 ssl-setup"
                exit 1
            fi
            
            build_backend_services
            build_frontend_services
            deploy_to_hostinger
            start_services_on_hostinger
            setup_databases
            setup_keycloak_realm
            health_check
            show_deployment_summary
            ;;
        config)
            check_prerequisites
            deploy_to_hostinger
            ;;
        start)
            check_prerequisites
            start_services_on_hostinger
            setup_databases
            health_check
            ;;
        redeploy)
            log "🔄 Redéploiement rapide avec vos changements..."
            check_prerequisites
            redeploy_services_only
            health_check
            ;;
        update)
            log "🔄 Mise à jour sélective des services..."
            check_prerequisites
            login_to_ghcr
            build_backend_services
            build_frontend_services
            deploy_to_hostinger
            start_services_on_hostinger
            health_check
            ;;
        status)
            health_check
            ;;
        test-ssl)
            test_ssl_endpoints
            ;;
        down)
            log "Arrêt des services..."
            run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env down --remove-orphans"
            ;;
        logs)
            log "Affichage des logs..."
            if [[ "$BUILD_SPECIFIC_SERVICES" == "true" ]]; then
                # Construire la liste des services pour les logs
                services_list=""
                for service in "${SPECIFIC_SERVICES[@]}"; do
                    services_list+=" $service"
                done
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env logs -f${services_list}"
            else
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env logs -f"
            fi
            ;;
        restart)
            log "🔄 Redémarrage des services..."
            if [[ "$BUILD_SPECIFIC_SERVICES" == "true" ]]; then
                # Redémarrer seulement les services spécifiés
                services_to_restart=""
                for service in "${SPECIFIC_SERVICES[@]}"; do
                    case "$service" in
                        'deal_generator'|'dealdealgenerator')
                            services_to_restart+=" deal-generator"
                            ;;
                        'deal_security'|'dealsecurity')
                            services_to_restart+=" deal-security"
                            ;;
                        'deal_setting'|'dealsetting')
                            services_to_restart+=" deal-setting"
                            ;;
                        'deal_webui'|'dealtobook-deal-webui')
                            services_to_restart+=" deal-webui"
                            ;;
                        'deal_website'|'dealtobook-deal-website')
                            services_to_restart+=" deal-website"
                            ;;
                        'keycloak')
                            services_to_restart+=" keycloak"
                            ;;
                        'postgres'|'postgresql')
                            services_to_restart+=" postgres"
                            ;;
                        'nginx')
                            services_to_restart+=" nginx"
                            ;;
                        'redis')
                            services_to_restart+=" redis"
                            ;;
                        *)
                            services_to_restart+=" $service"
                            ;;
                    esac
                done
                log "🎯 Redémarrage des services:$services_to_restart"
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env restart$services_to_restart"
            else
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env restart"
            fi
            success "✅ Services redémarrés"
            ;;
        stop)
            log "🛑 Arrêt des services..."
            if [[ "$BUILD_SPECIFIC_SERVICES" == "true" ]]; then
                # Arrêter seulement les services spécifiés
                services_to_stop=""
                for service in "${SPECIFIC_SERVICES[@]}"; do
                    case "$service" in
                        'deal_generator'|'dealdealgenerator')
                            services_to_stop+=" deal-generator"
                            ;;
                        'deal_security'|'dealsecurity')
                            services_to_stop+=" deal-security"
                            ;;
                        'deal_setting'|'dealsetting')
                            services_to_stop+=" deal-setting"
                            ;;
                        'deal_webui'|'dealtobook-deal-webui')
                            services_to_stop+=" deal-webui"
                            ;;
                        'deal_website'|'dealtobook-deal-website')
                            services_to_stop+=" deal-website"
                            ;;
                        'keycloak')
                            services_to_stop+=" keycloak"
                            ;;
                        'postgres'|'postgresql')
                            services_to_stop+=" postgres"
                            ;;
                        'nginx')
                            services_to_stop+=" nginx"
                            ;;
                        *)
                            services_to_stop+=" $service"
                            ;;
                    esac
                done
                log "🎯 Arrêt des services:$services_to_stop"
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env stop$services_to_stop"
            else
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env stop"
            fi
            success "✅ Services arrêtés"
            ;;
        ps|list)
            log "📋 Liste des conteneurs..."
            run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env ps"
            ;;
        health)
            log "🏥 Vérification santé détaillée..."
            health_check
            ;;
        build-only)
            log "🏗️ Build uniquement (sans déploiement)..."
            check_prerequisites true
            login_to_ghcr
            build_backend_services
            build_frontend_services
            success "✅ Build terminé"
            ;;
        deploy-only)
            log "🚀 Déploiement uniquement (sans rebuild)..."
            check_prerequisites
            deploy_to_hostinger
            start_services_on_hostinger
            health_check
            success "✅ Déploiement terminé"
            ;;
        *)
            echo "Usage: $0 {COMMAND} [services]"
            echo ""
            echo "📦 BUILD & DEPLOY:"
            echo "  build         : Construire et pousser les images vers GHCR"
            echo "  build-only    : Build uniquement (sans déploiement)"
            echo "  deploy        : Déploiement complet (build + deploy + config + SSL)"
            echo "  deploy-only   : Déployer sans rebuild"
            echo "  update        : Mise à jour sélective (build + redémarrage ciblé)"
            echo "  redeploy      : Redéploiement rapide (sans rebuild)"
            echo ""
            echo "🔧 GESTION DES SERVICES:"
            echo "  start         : Démarrer les services"
            echo "  stop          : Arrêter les services"
            echo "  restart       : Redémarrer les services"
            echo "  down          : Arrêter et supprimer tous les conteneurs"
            echo "  ps|list       : Liste des conteneurs"
            echo ""
            echo "📊 MONITORING & DEBUG:"
            echo "  status        : Vérifier le status du déploiement"
            echo "  health        : Health check détaillé"
            echo "  logs          : Afficher les logs en temps réel"
            echo "  test-ssl      : Tester les endpoints HTTPS"
            echo ""
            echo "⚙️ CONFIGURATION:"
            echo "  ssl-setup     : Configurer les certificats SSL Let's Encrypt"
            echo "  config        : Déployer uniquement la configuration"
            echo ""
            echo "🎯 Services disponibles (optionnel) :"
            echo "  Backend : deal_generator, deal_security, deal_setting"
            echo "  Frontend: deal_webui, deal_website"
            echo "  Infra   : keycloak, postgres, redis, nginx, zipkin, prometheus, grafana"
            echo ""
            echo "📝 Exemples d'utilisation :"
            echo ""
            echo "  🟡 DEVELOPMENT:"
            echo "    export DEPLOY_ENV=development"
            echo "    export CR_PAT=\"your_token\""
            echo "    ./deploy-ssl-production.sh deploy"
            echo ""
            echo "  🟢 PRODUCTION:"
            echo "    export DEPLOY_ENV=production"
            echo "    export CR_PAT=\"your_token\""
            echo "    ./deploy-ssl-production.sh deploy"
            echo ""
            echo "  Build d'un service spécifique:"
            echo "    ./deploy-ssl-production.sh build deal_security"
            echo ""
            echo "  Redémarrer des services:"
            echo "    ./deploy-ssl-production.sh restart deal_generator,deal_security"
            echo ""
            echo "  Voir les logs d'un service:"
            echo "    ./deploy-ssl-production.sh logs deal_webui"
            echo ""
            echo "  Health check:"
            echo "    ./deploy-ssl-production.sh health"
            echo ""
            echo "🔑 Variables d'environnement :"
            echo "  OBLIGATOIRE:"
            echo "    export CR_PAT=\"votre_github_token\"         # Token GitHub pour GHCR"
            echo ""
            echo "  ENVIRONNEMENT (Development ou Production):"
            echo "    export DEPLOY_ENV=\"development\"            # Deploy vers DEV (tag: develop, /opt/dealtobook-dev)"
            echo "    export DEPLOY_ENV=\"production\"             # Deploy vers PROD (tag: latest, /opt/dealtobook)"
            echo ""
            echo "  DEVELOPMENT:"
            echo "    export HOSTINGER_DEV_HOST=\"148.230.114.13\" # IP serveur dev"
            echo "    export HOSTINGER_DEV_USER=\"root\"           # User SSH dev"
            echo ""
            echo "  PRODUCTION:"
            echo "    export HOSTINGER_PROD_HOST=\"148.230.114.13\"# IP serveur prod"
            echo "    export HOSTINGER_PROD_USER=\"root\"          # User SSH prod"
            echo ""
            echo "  AUTRES:"
            echo "    export GITHUB_USERNAME=\"skaouech\"          # Utilisateur GitHub (en minuscules)"
            echo ""
            echo "⚠️  SÉCURITÉ: Ne JAMAIS hardcoder les tokens dans le code !"
            exit 1
            ;;
    esac
}

main "$@"
