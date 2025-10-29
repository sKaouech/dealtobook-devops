#!/bin/bash
set -euo pipefail

# 🎯 Script de déploiement avec SSL/HTTPS pour Hostinger - Version 2.0
# Gère DNS, certificats SSL, et déploiement complet avec flexibilité maximale

# Déterminer le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVOPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$DEVOPS_DIR/config"
# Les services sont au niveau workspace (parent de dealtobook-devops)
WORKSPACE_ROOT="$(cd "$DEVOPS_DIR/.." && pwd)"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m' # No Color

# Configuration - UTILISEZ DES VARIABLES D'ENVIRONNEMENT POUR LES SECRETS !
GITHUB_USERNAME="${GITHUB_USERNAME:-skaouech}"
REGISTRY="${REGISTRY:-ghcr.io}"
CR_PAT="${CR_PAT:-}"
CUSTOM_TAG="${CUSTOM_TAG:-}"  # Tag personnalisé pour les images

# Environnement (development ou production)
DEPLOY_ENV="${DEPLOY_ENV:-production}"

# Timeouts configurables
DB_READY_TIMEOUT="${DB_READY_TIMEOUT:-60}"
KEYCLOAK_READY_TIMEOUT="${KEYCLOAK_READY_TIMEOUT:-90}"
SERVICE_STABILIZATION_TIMEOUT="${SERVICE_STABILIZATION_TIMEOUT:-30}"

# Configuration basée sur l'environnement
if [[ "$DEPLOY_ENV" == "development" ]]; then
    HOSTINGER_IP="${HOSTINGER_DEV_HOST:-148.230.114.13}"
    HOSTINGER_USER="${HOSTINGER_DEV_USER:-root}"
    PROJECT_NAME="dealtobook-dev"
    DOCKER_COMPOSE_FILE="$CONFIG_DIR/docker-compose.ssl-complete.yml"
    ENV_FILE="$CONFIG_DIR/dealtobook-ssl-dev.env"
    IMAGE_TAG="${CUSTOM_TAG:-develop}"
    DOMAINS=("administration-dev.dealtobook.com" "website-dev.dealtobook.com" "keycloak-dev.dealtobook.com")
else
    HOSTINGER_IP="${HOSTINGER_PROD_HOST:-148.230.114.13}"
    HOSTINGER_USER="${HOSTINGER_PROD_USER:-root}"
    PROJECT_NAME="dealtobook"
    DOCKER_COMPOSE_FILE="$CONFIG_DIR/docker-compose.ssl-complete.yml"
    ENV_FILE="$CONFIG_DIR/dealtobook-ssl.env"
    IMAGE_TAG="${CUSTOM_TAG:-latest}"
    DOMAINS=("administration.dealtobook.com" "website.dealtobook.com" "keycloak.dealtobook.com")
fi

# Microservices configuration
BACKEND_SERVICES_DIRS=("deal_generator" "deal_security" "deal_setting")
BACKEND_SERVICES_IMAGES=("dealdealgenerator" "dealsecurity" "dealsetting")

FRONTEND_SERVICES_DIRS=("deal_webui" "deal_website")
FRONTEND_SERVICES_IMAGES=("dealtobook-deal-webui" "dealtobook-deal-website")

# Services spécifiques (peut être modifié par les arguments)
SPECIFIC_SERVICES=()
BUILD_SPECIFIC_SERVICES=false

# Service mapping centralisé (DRY principle)
# Compatible avec bash 3.x (macOS par défaut)

# Logging functions
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ ERROR: $1${NC}" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
}

info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Map service name to docker-compose service name
# Compatible bash 3.x avec case statement
map_service_name() {
    local service="$1"
    
    case "$service" in
        # Backend services
        deal_generator|dealdealgenerator|generator)
            echo "deal-generator"
            ;;
        deal_security|dealsecurity|security)
            echo "deal-security"
            ;;
        deal_setting|dealsetting|setting)
            echo "deal-setting"
            ;;
        
        # Frontend services
        deal_webui|dealtobook-deal-webui|webui|admin)
            echo "deal-webui"
            ;;
        deal_website|dealtobook-deal-website|website)
            echo "deal-website"
            ;;
        
        # Infrastructure
        postgres|postgresql|db)
            echo "postgres"
            ;;
        keycloak)
            echo "keycloak"
            ;;
        nginx)
            echo "nginx"
            ;;
        redis)
            echo "redis"
            ;;
        zipkin)
            echo "zipkin"
            ;;
        prometheus)
            echo "prometheus"
            ;;
        grafana)
            echo "grafana"
            ;;
        
        # Default: return as-is
        *)
            echo "$service"
            ;;
    esac
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

# Get mapped services list for docker-compose commands
get_mapped_services_list() {
    local services_list=""
    for service in "${SPECIFIC_SERVICES[@]}"; do
        local mapped=$(map_service_name "$service")
        services_list+=" $mapped"
    done
    echo "$services_list"
}

# Configure Java 17 for JHipster compatibility
setup_java17() {
    log "🔧 Configuration de Java 17..."
    
    if /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
        export JAVA_HOME=$(/usr/libexec/java_home -v 17)
        export PATH="$JAVA_HOME/bin:$PATH"
        success "Java 17 configuré: $JAVA_HOME"
        java -version
    else
        error "Java 17 non trouvé. Veuillez installer Java 17 (JDK 11-18 requis pour JHipster)"
    fi
}

# Execute remote SSH command
run_remote_cmd() {
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "$1"
}

# Helper: retry command with backoff
retry_with_backoff() {
  local max_retries="$1"; shift
  local delay="$1"; shift
  local attempt=1
  while true; do
    "$@" && return 0
    if [ "$attempt" -ge "$max_retries" ]; then
      return 1
    fi
    sleep "$delay"
    attempt=$((attempt+1))
    delay=$((delay*2))
  done
}

# Check prerequisites
check_prerequisites() {
    local skip_ssh=${1:-false}
    log "🔍 Vérification des prérequis..."
    
    # Setup Java 17 first
    setup_java17
    
    # Check required tools
    local required_tools=("docker" "docker-compose" "ssh" "scp")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            error "$tool n'est pas installé"
        fi
    done
    
    # Vérifier les variables d'environnement pour GHCR
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

# Login to GitHub Container Registry
login_to_ghcr() {
    if [ -n "$CR_PAT" ]; then
        log "🔑 Connexion à GitHub Container Registry..."
        echo "$CR_PAT" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin || error "Échec de la connexion à GHCR"
        success "Connecté à GHCR"
    else
        warning "CR_PAT non défini - pas de connexion GHCR"
    fi
}

# Check SSL certificates
check_ssl_certificates() {
    log "🔒 Vérification des certificats SSL..."
    
    local all_valid=true
    for domain in "${DOMAINS[@]}"; do
        log "  Vérification du certificat pour ${domain}..."
        if run_remote_cmd "test -f /etc/letsencrypt/live/${domain}/fullchain.pem"; then
            success "  ✅ Certificat SSL trouvé pour ${domain}"
        else
            warning "  ⚠️  Certificat SSL manquant pour ${domain}"
            all_valid=false
        fi
    done
    
    if [ "$all_valid" = true ]; then
        success "🔒 Tous les certificats SSL sont présents"
        return 0
    else
        return 1
    fi
}

# Setup SSL certificates
setup_ssl_certificates() {
    log "🔒 Configuration des certificats SSL avec Let's Encrypt..."
    
    # Arrêter les services qui utilisent les ports 80/443
    run_remote_cmd "docker stop ${PROJECT_NAME}-nginx 2>/dev/null || true"
    run_remote_cmd "systemctl stop nginx 2>/dev/null || true"
    
    # Installer Certbot si nécessaire
    run_remote_cmd "apt update && apt install -y certbot python3-certbot-nginx"
    
    # Configuration Nginx temporaire pour Certbot
    local temp_nginx_config='events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name '
    
    # Ajouter les domaines dynamiquement
    temp_nginx_config+="${DOMAINS[@]};"
    
    temp_nginx_config+='
        
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        
        location / {
            return 301 https://$host$request_uri;
        }
    }
}'
    
    run_remote_cmd "cat > /tmp/nginx-temp.conf << 'EOF'
$temp_nginx_config
EOF"
    
    # Démarrer Nginx temporaire
    run_remote_cmd "mkdir -p /var/www/certbot"
    run_remote_cmd "cp /tmp/nginx-temp.conf /etc/nginx/nginx.conf"
    run_remote_cmd "systemctl start nginx"
    
    # Obtenir les certificats
    local domain_args=""
    for domain in "${DOMAINS[@]}"; do
        domain_args+=" -d $domain"
    done
    
    run_remote_cmd "certbot --nginx $domain_args --non-interactive --agree-tos --email admin@dealtobook.com --expand"
    
    # Arrêter Nginx système
    run_remote_cmd "systemctl stop nginx && systemctl disable nginx"
    
    success "🔒 Certificats SSL configurés avec succès"
}

# Build backend services
build_backend_services() {
    log "🏗️ Construction des services backend avec JIB..."
    
    local build_failed=false
    for i in "${!BACKEND_SERVICES_DIRS[@]}"; do
        local service_key="${BACKEND_SERVICES_DIRS[$i]}"
        local image_name="${BACKEND_SERVICES_IMAGES[$i]}"
        local service_dir="$WORKSPACE_ROOT/dealtobook-${service_key}"
        
        # Vérifier si ce service doit être traité
        if ! should_process_service "$service_key" && ! should_process_service "$image_name"; then
            info "⏭️ Service $service_key ignoré (non spécifié)"
            continue
        fi
        
        if [ -d "$service_dir" ]; then
            log "  Building $service_key → $image_name..."
            
            (cd "$service_dir" && {
                if [ -n "$CR_PAT" ]; then
                    local image_name_lower=$(echo "$GITHUB_USERNAME/$image_name" | tr '[:upper:]' '[:lower:]')
                    
                    # Build avec JIB et push vers GHCR (avec retry et timeout augmenté)
                    retry_with_backoff 3 5 \
                      ./mvnw -ntp compile jib:build -Pprod -DskipTests \
                        -Djib.httpTimeout=120000 \
                        -Djib.to.image="$REGISTRY/$image_name_lower:$IMAGE_TAG" \
                        -Djib.to.auth.username="$GITHUB_USERNAME" \
                        -Djib.to.auth.password="$CR_PAT" \
                    || { error "  ❌ JIB build failed for $service_key"; build_failed=true; }
                    
                    # Tag avec SHA pour traçabilité (best-effort)
                    local commit_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
                    docker tag "$REGISTRY/$image_name_lower:$IMAGE_TAG" \
                              "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
                    retry_with_backoff 3 5 docker push "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
                } else {
                    retry_with_backoff 3 5 \
                      ./mvnw -ntp compile jib:dockerBuild -Pprod -DskipTests \
                      -Djib.httpTimeout=120000 \
                    || { error "  ❌ JIB build failed for $service_key"; build_failed=true; }
                }
            }) || { error "Build failed for $service_key"; build_failed=true; }
            
            [ "$build_failed" = false ] && success "  Service $service_key construit et poussé"
        else
            warning "  Répertoire $service_dir non trouvé"
        fi
    done
    
    if [ "$build_failed" = true ]; then
        error "Un ou plusieurs builds ont échoué"
    fi
}

# Build frontend services
build_frontend_services() {
    log "🌐 Construction des services frontend..."
    
    local build_failed=false
    for i in "${!FRONTEND_SERVICES_DIRS[@]}"; do
        local service_key="${FRONTEND_SERVICES_DIRS[$i]}"
        local image_name="${FRONTEND_SERVICES_IMAGES[$i]}"
        local service_dir="$WORKSPACE_ROOT/dealtobook-${service_key}"
        
        if ! should_process_service "$service_key" && ! should_process_service "$image_name"; then
            info "⏭️ Service $service_key ignoré (non spécifié)"
            continue
        fi
        
        if [ -d "$service_dir" ]; then
            log "  Building $service_key → $image_name..."
            
            local dockerfile="Dockerfile.simple"
            [ "$service_key" = "deal_website" ] && dockerfile="Dockerfile.frontend"
            
            if [ -n "$CR_PAT" ]; then
                local image_name_lower=$(echo "$GITHUB_USERNAME/$image_name" | tr '[:upper:]' '[:lower:]')
                
                retry_with_backoff 3 5 docker build --platform linux/amd64 -t "$REGISTRY/$image_name_lower:$IMAGE_TAG" -f "$service_dir/$dockerfile" "$service_dir/" \
                  || { error "  ❌ Docker build failed for $service_key"; build_failed=true; }
                
                retry_with_backoff 3 5 docker push "$REGISTRY/$image_name_lower:$IMAGE_TAG" \
                  || { error "  ❌ Docker push failed for $service_key"; build_failed=true; }
                
                local commit_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
                docker tag "$REGISTRY/$image_name_lower:$IMAGE_TAG" "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
                retry_with_backoff 3 5 docker push "$REGISTRY/$image_name_lower:$IMAGE_TAG-$commit_sha" 2>/dev/null || true
            } else {
                retry_with_backoff 3 5 docker build --platform linux/amd64 -t "$image_name:latest" -f "$service_dir/$dockerfile" "$service_dir/" \
                  || { error "  ❌ Docker build failed for $service_key"; build_failed=true; }
            }
            
            [ "$build_failed" = false ] && success "  Service $service_key construit"
        else
            warning "  Répertoire $service_dir non trouvé"
        fi
    done
    
    if [ "$build_failed" = true ]; then
        error "Un ou plusieurs builds ont échoué"
    fi
}

# Deploy configuration to Hostinger
deploy_to_hostinger() {
    log "🚀 Déploiement sur Hostinger..."
    
    # Créer le répertoire de projet sur Hostinger
    run_remote_cmd "mkdir -p /opt/${PROJECT_NAME}/{nginx,monitoring/grafana/provisioning/{datasources,dashboards},scripts,keycloak-themes}"
    
    # Transférer les fichiers de configuration
    log "  Transfert des fichiers de configuration..."
    scp -o StrictHostKeyChecking=no "$DOCKER_COMPOSE_FILE" "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || error "Failed to transfer docker-compose"
    scp -o StrictHostKeyChecking=no "$ENV_FILE" "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/.env" || error "Failed to transfer .env file"
    
    # Transférer les répertoires de configuration
    local config_dirs=("nginx" "monitoring" "keycloak-themes")
    for dir in "${config_dirs[@]}"; do
        local config_path="$CONFIG_DIR/$dir"
        if [ -d "$config_path" ]; then
            scp -r -o StrictHostKeyChecking=no "$config_path/" "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || warning "Failed to transfer $dir"
        else
            warning "  Répertoire $config_path non trouvé"
        fi
    done
    
    # Transférer les scripts si nécessaire
    if [ -d "$SCRIPT_DIR" ]; then
        scp -r -o StrictHostKeyChecking=no "$SCRIPT_DIR/" "${HOSTINGER_USER}@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/scripts" || warning "Failed to transfer scripts"
    fi
    
    success "Configuration transférée"
}

# Pull images on remote server
pull_images_on_hostinger() {
    log "🔄 Pull des images Docker sur Hostinger..."
    
    if [ -z "$CR_PAT" ]; then
        warning "CR_PAT non défini - impossible de pull les images"
        return 0
    fi
    
    local services_to_pull=$(get_mapped_services_list)
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        echo '$CR_PAT' | docker login ghcr.io -u '$GITHUB_USERNAME' --password-stdin
        
        if [ '$BUILD_SPECIFIC_SERVICES' = 'true' ]; then
            echo '🎯 Pull des images spécifiques:$services_to_pull'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env pull$services_to_pull
        else
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env pull
        fi
    }" || warning "Erreur lors du pull des images"
    
    success "Images téléchargées"
}

# Start services on Hostinger
start_services_on_hostinger() {
    log "🔄 Démarrage des services sur Hostinger..."
    
    local services_list=$(get_mapped_services_list)
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        # Login to GHCR if available
        if [ -n '$CR_PAT' ]; then
            echo '$CR_PAT' | docker login ghcr.io -u '$GITHUB_USERNAME' --password-stdin
        fi
    
        # Créer le réseau Docker
        docker network create dealtobook-network 2>/dev/null || true
    
        # Démarrer les services
        if [ '$BUILD_SPECIFIC_SERVICES' = 'true' ]; then
            echo '🎯 Démarrage des services spécifiques:$services_list'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate$services_list
        else
            # Démarrage séquentiel des services pour éviter les conflits de dépendances
            echo '🚀 Démarrage séquentiel des services avec force-recreate...'
            
            # Arrêter tous les services d'abord
            echo '🛑 Arrêt des services existants...'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env down --remove-orphans
            
            # 1. Infrastructure de base
            echo '📊 Démarrage de l infrastructure...'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate postgres redis zipkin prometheus grafana
            sleep 10
            
            # 2. Keycloak
            echo '🔐 Démarrage de Keycloak...'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate keycloak
            sleep 15
            
            # 3. Services backend
            echo '⚙️ Démarrage des services backend...'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate deal-generator deal-security deal-setting
            sleep 20
            
            # 4. Services frontend
            echo '🌐 Démarrage des services frontend...'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate deal-webui deal-website
            sleep 10
            
            # 5. Nginx
            echo '🔄 Démarrage de Nginx...'
            docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d --force-recreate nginx
            
            echo '✅ Tous les services démarrés séquentiellement'
        fi
        
        echo 'Services démarrés'
    }" || error "Échec du démarrage des services"
    
    success "Services démarrés sur Hostinger"
}

# Stop services on Hostinger
stop_services_on_hostinger() {
    log "🛑 Arrêt des services sur Hostinger..."
    
    local services_list=$(get_mapped_services_list)
    
    if [ "$BUILD_SPECIFIC_SERVICES" = "true" ]; then
        log "🎯 Arrêt des services spécifiques:$services_list"
        run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env stop$services_list"
    else
        run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env stop"
    fi
    
    success "Services arrêtés"
}

# Restart services on Hostinger
restart_services_on_hostinger() {
    log "🔄 Redémarrage des services sur Hostinger..."
    
    local services_list=$(get_mapped_services_list)
    
    if [ "$BUILD_SPECIFIC_SERVICES" = "true" ]; then
        log "🎯 Redémarrage des services spécifiques:$services_list"
        run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env restart$services_list"
    else
        run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env restart"
    fi
    
    success "Services redémarrés"
}

# Scale services
scale_services() {
    local service="$1"
    local replicas="${2:-1}"
    
    log "📈 Scaling service $service to $replicas replicas..."
    
    local mapped_service=$(map_service_name "$service")
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env up -d --scale $mapped_service=$replicas"
    
    success "Service $service scaled to $replicas"
}

# Execute command in service container
exec_in_service() {
    local service="$1"
    shift
    local command="$*"
    
    log "🖥️ Exécution de commande dans $service: $command"
    
    local mapped_service=$(map_service_name "$service")
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env exec -T $mapped_service $command"
}

# Inspect service
inspect_service() {
    local service="$1"
    
    log "🔍 Inspection du service $service..."
    
    local mapped_service=$(map_service_name "$service")
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        echo '=== Container Info ==='
        docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env ps $mapped_service
        echo ''
        echo '=== Container Details ==='
        docker inspect \$(docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env ps -q $mapped_service) 2>/dev/null || echo 'Container not running'
        echo ''
        echo '=== Recent Logs (last 50 lines) ==='
        docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env logs --tail=50 $mapped_service
    }"
}

# Setup databases
setup_databases() {
    log "🗄️ Configuration des bases de données..."
    
    log "  Attente de PostgreSQL (${DB_READY_TIMEOUT}s)..."
    sleep "$DB_READY_TIMEOUT"
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        docker exec ${PROJECT_NAME}-postgres psql -U dealtobook -d dealtobook_db -c 'CREATE DATABASE IF NOT EXISTS deal_setting;' 2>/dev/null || true
        docker exec ${PROJECT_NAME}-postgres psql -U dealtobook -d dealtobook_db -c 'CREATE DATABASE IF NOT EXISTS keycloak;' 2>/dev/null || true
        docker exec ${PROJECT_NAME}-postgres psql -U dealtobook -d dealtobook_db -c 'CREATE DATABASE IF NOT EXISTS deal_generator;' 2>/dev/null || true
        
        echo 'Bases de données configurées'
    }" || warning "Erreur lors de la configuration des bases de données"
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env restart deal-generator deal-security deal-setting
        echo 'Services backend redémarrés'
    }" || warning "Erreur lors du redémarrage des services backend"
    
    success "Bases de données configurées"
}

# Setup Keycloak realm
setup_keycloak_realm() {
    log "🔐 Configuration du realm Keycloak..."
    
    log "  Attente de Keycloak (${KEYCLOAK_READY_TIMEOUT}s)..."
    sleep "$KEYCLOAK_READY_TIMEOUT"
    
    local keycloak_url="https://keycloak-dev.dealtobook.com"
    if [[ "$DEPLOY_ENV" == "production" ]]; then
        keycloak_url="https://keycloak.dealtobook.com"
    fi
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        ADMIN_TOKEN=\$(curl -s -X POST '$keycloak_url/realms/master/protocol/openid-connect/token' \
            -H 'Content-Type: application/x-www-form-urlencoded' \
            -d 'username=admin' \
            -d 'password=\${KEYCLOAK_ADMIN_PASSWORD:-admin123}' \
            -d 'grant_type=password' \
            -d 'client_id=admin-cli' \
            --insecure | jq -r '.access_token' 2>/dev/null || echo 'null')
        
        if [ \"\$ADMIN_TOKEN\" != 'null' ] && [ -n \"\$ADMIN_TOKEN\" ]; then
            echo 'Token admin obtenu'
            
            curl -s -X POST '$keycloak_url/admin/realms' \
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
            
            curl -s -X POST '$keycloak_url/admin/realms/dealtobook/clients' \
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
                        \"'$keycloak_url'/*\"
                    ],
                    \"webOrigins\": [
                        \"*\"
                    ]
                }' 2>/dev/null || true
            
            echo 'Realm et client Keycloak configurés'
        else
            echo 'Impossible d obtenir le token admin Keycloak'
        fi
    }" || warning "Erreur lors de la configuration Keycloak"
    
    success "Keycloak configuré"
}

# Health check
health_check() {
    log "🔍 Vérification de la santé des services..."
    
    log "  Attente de la stabilisation (${SERVICE_STABILIZATION_TIMEOUT}s)..."
    sleep "$SERVICE_STABILIZATION_TIMEOUT"
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        echo '📊 Status des conteneurs :'
        docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env ps
        
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
        if curl -s -I https://administration${DEPLOY_ENV:+-dev}.dealtobook.com 2>/dev/null | head -1 | grep -q '200\|301\|302'; then
            echo '✅ Accessible'
        else
            echo '❌ Not accessible'
        fi
        
        echo -n '  • Website (HTTPS): '
        if curl -s -I https://website${DEPLOY_ENV:+-dev}.dealtobook.com 2>/dev/null | head -1 | grep -q '200\|301\|302'; then
            echo '✅ Accessible'
        else
            echo '❌ Not accessible'
        fi
        
        echo -n '  • Keycloak (HTTPS): '
        if curl -s -I https://keycloak${DEPLOY_ENV:+-dev}.dealtobook.com 2>/dev/null | head -1 | grep -q '200\|301\|302'; then
            echo '✅ Accessible'
        else
            echo '❌ Not accessible'
        fi
    }" || warning "Erreur lors de la vérification de santé"
    
    success "Vérification de santé terminée"
}

# Test SSL endpoints
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

# Show deployment summary
show_deployment_summary() {
    log "✅ DÉPLOIEMENT TERMINÉ !"
    echo ""
    echo -e "${GREEN}🎉 DEALTOBOOK DÉPLOYÉ AVEC SUCCÈS !${NC}"
    echo "=================================================="
    echo ""
    echo -e "${BLUE}🌐 Applications HTTPS :${NC}"
    
    if [[ "$DEPLOY_ENV" == "development" ]]; then
        echo "  • Administration: https://administration-dev.dealtobook.com"
        echo "  • Website: https://website-dev.dealtobook.com"
        echo "  • Keycloak: https://keycloak-dev.dealtobook.com"
    else
        echo "  • Administration: https://administration.dealtobook.com"
        echo "  • Website: https://website.dealtobook.com"
        echo "  • Keycloak: https://keycloak.dealtobook.com"
    fi
    
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
    echo "  • Status: $0 status"
    echo "  • Logs: $0 logs [service]"
    echo "  • Restart: $0 restart [service]"
    echo "  • Health: $0 health"
    echo "  • Inspect: $0 inspect <service>"
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 {COMMAND} [services] [options]

📦 BUILD & DEPLOY:
  build              : Construire et pousser les images vers GHCR
  build-only         : Build uniquement (sans déploiement)
  deploy             : Déploiement complet (build + deploy + config + SSL)
  deploy-only        : Déployer sans rebuild
  update             : Mise à jour sélective (build + redémarrage ciblé)
  redeploy           : Redéploiement rapide (sans rebuild)

🔧 GESTION DES SERVICES:
  start              : Démarrer les services
  stop               : Arrêter les services
  restart            : Redémarrer les services
  down               : Arrêter et supprimer tous les conteneurs
  pull               : Télécharger les images sans redémarrer
  ps|list            : Liste des conteneurs
  scale <service> <n>: Scaler un service à n replicas

🛠️ OPÉRATIONS AVANCÉES:
  exec <service> <cmd>: Exécuter une commande dans un conteneur
  inspect <service>  : Inspecter un service (logs, config, etc.)
  
📊 MONITORING & DEBUG:
  status             : Vérifier le status du déploiement
  health             : Health check détaillé
  logs [service]     : Afficher les logs en temps réel
  test-ssl           : Tester les endpoints HTTPS

⚙️ CONFIGURATION:
  ssl-setup          : Configurer les certificats SSL Let's Encrypt
  config             : Déployer uniquement la configuration

🎯 Services disponibles (optionnel) :
  Backend : deal_generator (generator), deal_security (security), deal_setting (setting)
  Frontend: deal_webui (webui/admin), deal_website (website)
  Infra   : keycloak, postgres (db), redis, nginx, zipkin, prometheus, grafana

📝 Exemples d'utilisation :

  🟡 DEVELOPMENT:
    export DEPLOY_ENV=development
    export CR_PAT="your_token"
    $0 deploy

  🟢 PRODUCTION:
    export DEPLOY_ENV=production
    export CR_PAT="your_token"
    $0 deploy

  Build d'un service spécifique:
    $0 build deal_security

  Restart plusieurs services:
    $0 restart deal_generator,deal_security

  Voir les logs d'un service:
    $0 logs webui

  Scaler un service:
    $0 scale deal-generator 3

  Exécuter une commande:
    $0 exec postgres psql -U dealtobook

  Inspecter un service:
    $0 inspect deal-security

  Utiliser un tag personnalisé:
    export CUSTOM_TAG="v1.2.3"
    $0 deploy

🔑 Variables d'environnement :
  OBLIGATOIRE:
    export CR_PAT="votre_github_token"               # Token GitHub pour GHCR

  ENVIRONNEMENT:
    export DEPLOY_ENV="development|production"       # Environnement cible

  SERVEURS:
    export HOSTINGER_DEV_HOST="148.230.114.13"       # IP serveur dev
    export HOSTINGER_DEV_USER="root"                 # User SSH dev
    export HOSTINGER_PROD_HOST="148.230.114.13"      # IP serveur prod
    export HOSTINGER_PROD_USER="root"                # User SSH prod

  TIMEOUTS (optionnel):
    export DB_READY_TIMEOUT="60"                     # Timeout PostgreSQL
    export KEYCLOAK_READY_TIMEOUT="90"               # Timeout Keycloak
    export SERVICE_STABILIZATION_TIMEOUT="30"        # Timeout stabilisation

  AUTRES:
    export GITHUB_USERNAME="skaouech"                # Utilisateur GitHub
    export CUSTOM_TAG="v1.2.3"                       # Tag personnalisé

⚠️  SÉCURITÉ: Ne JAMAIS hardcoder les tokens dans le code !
EOF
}

# Main function
main() {
    echo -e "${PURPLE}"
    echo "🚀 ===== DÉPLOIEMENT DEALTOBOOK AVEC SSL v2.0 ====="
    echo "==================================================="
    echo -e "${NC}"
    
    # Afficher l'environnement actif
    if [[ "$DEPLOY_ENV" == "development" ]]; then
        echo -e "${YELLOW}📍 Environnement: DEVELOPMENT${NC}"
    else
        echo -e "${GREEN}📍 Environnement: PRODUCTION${NC}"
    fi
    echo -e "   🖥️  Serveur: $HOSTINGER_IP"
    echo -e "   📁 Dossier: /opt/$PROJECT_NAME"
    echo -e "   🏷️  Tag images: $IMAGE_TAG"
    echo ""
    
    # Parse command
    local command="${1:-}"
    shift || true
    
    # Parse services if provided
    if [[ -n "${1:-}" ]] && [[ ! "$1" =~ ^- ]]; then
        parse_services "$1"
        shift || true
    fi
    
    case "$command" in
        ssl-setup)
            check_prerequisites
            setup_ssl_certificates
            ;;
        build)
            check_prerequisites true
            login_to_ghcr
            build_backend_services
            build_frontend_services
            ;;
        build-only)
            log "🏗️ Build uniquement (sans déploiement)..."
            check_prerequisites true
            login_to_ghcr
            build_backend_services
            build_frontend_services
            success "✅ Build terminé"
            ;;
        deploy)
            check_prerequisites
            login_to_ghcr
            
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
        deploy-only)
            log "🚀 Déploiement uniquement (sans rebuild)..."
            check_prerequisites
            deploy_to_hostinger
            start_services_on_hostinger
            health_check
            success "✅ Déploiement terminé"
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
        redeploy)
            log "🔄 Redéploiement rapide..."
            check_prerequisites
            deploy_to_hostinger
            restart_services_on_hostinger
            health_check
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
        stop)
            check_prerequisites
            stop_services_on_hostinger
            ;;
        restart)
            check_prerequisites
            restart_services_on_hostinger
            success "✅ Services redémarrés"
            ;;
        down)
            log "⬇️ Arrêt et suppression des conteneurs..."
            check_prerequisites
            run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env down --remove-orphans"
            success "✅ Services arrêtés et supprimés"
            ;;
        pull)
            check_prerequisites
            pull_images_on_hostinger
            ;;
        scale)
            if [[ -z "${1:-}" ]] || [[ -z "${2:-}" ]]; then
                error "Usage: $0 scale <service> <replicas>"
            fi
            check_prerequisites
            scale_services "$1" "$2"
            ;;
        exec)
            if [[ -z "${1:-}" ]]; then
                error "Usage: $0 exec <service> <command>"
            fi
            check_prerequisites
            exec_in_service "$@"
            ;;
        inspect)
            if [[ -z "${1:-}" ]]; then
                error "Usage: $0 inspect <service>"
            fi
            check_prerequisites
            inspect_service "$1"
            ;;
        logs)
            log "📋 Affichage des logs..."
            check_prerequisites
            
            local services_list=$(get_mapped_services_list)
            if [[ "$BUILD_SPECIFIC_SERVICES" == "true" ]]; then
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env logs -f$services_list"
            else
                run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env logs -f"
            fi
            ;;
        ps|list)
            log "📋 Liste des conteneurs..."
            check_prerequisites
            run_remote_cmd "cd /opt/${PROJECT_NAME} && docker-compose -f ${DOCKER_COMPOSE_FILE} --env-file .env ps"
            ;;
        status)
            health_check
            ;;
        health)
            log "🏥 Vérification santé détaillée..."
            health_check
            ;;
        test-ssl)
            test_ssl_endpoints
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            show_usage
            exit 1
            ;;
    esac
}

# Execute main with all arguments
main "$@"

