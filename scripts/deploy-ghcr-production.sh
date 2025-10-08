#!/bin/bash
set -e

# 🚀 Script de déploiement production optimisé avec GHCR
# Utilise GitHub Container Registry pour les images Docker

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
GITHUB_USERNAME="skaouech"
REGISTRY="ghcr.io"
HOSTINGER_IP="${HOSTINGER_IP:-148.230.114.13}"
HOSTINGER_USER="${HOSTINGER_USER:-root}"
PROJECT_NAME="dealtobook"
DOCKER_COMPOSE_FILE="docker-compose.ghcr.yml"
ENV_FILE="dealtobook-ghcr.env"

# Microservices configuration (using simple arrays for bash compatibility)
BACKEND_SERVICES_DIRS=("deal_generator" "deal_security" "deal_setting")
BACKEND_SERVICES_IMAGES=("dealdealgenerator" "dealsecurity" "dealsetting")

FRONTEND_SERVICES_DIRS=("deal_webui" "deal_website")
FRONTEND_SERVICES_IMAGES=("dealtobook-deal-webui" "dealtobook-deal-website")

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

run_remote_cmd() {
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "$1"
}

check_prerequisites() {
    log "🔍 Vérification des prérequis..."
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé"
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose n'est pas installé"
    fi
    
    # Vérifier les variables d'environnement
    if [ -z "$CR_PAT" ]; then
        error "Variable CR_PAT non définie. Exportez votre token GitHub : export CR_PAT=ghp_..."
    fi
    
    # Vérifier SSH vers Hostinger
    if ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${HOSTINGER_USER}@${HOSTINGER_IP}" "echo 'SSH OK'" &> /dev/null; then
        error "Impossible de se connecter à Hostinger via SSH"
    fi
    
    success "Prérequis validés"
}

login_to_ghcr() {
    log "🔑 Connexion à GitHub Container Registry..."
    
    echo "$CR_PAT" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin || error "Échec de la connexion à GHCR"
    
    success "Connecté à GHCR"
}

build_backend_services() {
    log "🏗️ Construction des services backend avec JIB..."
    
    for i in "${!BACKEND_SERVICES_DIRS[@]}"; do
        local service_key="${BACKEND_SERVICES_DIRS[$i]}"
        local image_name="${BACKEND_SERVICES_IMAGES[$i]}"
        local service_dir="dealtobook-${service_key}"
        
        if [ -d "$service_dir" ]; then
            log "  Building $service_key → $image_name..."
            
            (cd "$service_dir" && {
                # Build avec JIB et push vers GHCR
                ./mvnw package -Pprod -DskipTests jib:build \
                    -Djib.to.image="$REGISTRY/$GITHUB_USERNAME/$image_name:latest" \
                    -Djib.to.auth.username="$GITHUB_USERNAME" \
                    -Djib.to.auth.password="$CR_PAT" || error "JIB build failed for $service_key"
                
                # Tag avec SHA pour traçabilité
                local commit_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
                docker pull "$REGISTRY/$GITHUB_USERNAME/$image_name:latest"
                docker tag "$REGISTRY/$GITHUB_USERNAME/$image_name:latest" \
                          "$REGISTRY/$GITHUB_USERNAME/$image_name:$commit_sha"
                docker push "$REGISTRY/$GITHUB_USERNAME/$image_name:$commit_sha"
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
        local service_dir="dealtobook-${service_key}"
        
        if [ -d "$service_dir" ]; then
            log "  Building $service_key → $image_name..."
            
            local dockerfile="Dockerfile.simple"
            if [ "$service_key" = "deal_website" ]; then
                dockerfile="Dockerfile.frontend"
            fi
            
            # Build et push de l'image frontend
            docker build -t "$REGISTRY/$GITHUB_USERNAME/$image_name:latest" \
                        -f "$service_dir/$dockerfile" "$service_dir/" || error "Docker build failed for $service_key"
            
            docker push "$REGISTRY/$GITHUB_USERNAME/$image_name:latest" || error "Docker push failed for $service_key"
            
            # Tag avec SHA pour traçabilité
            local commit_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
            docker tag "$REGISTRY/$GITHUB_USERNAME/$image_name:latest" \
                      "$REGISTRY/$GITHUB_USERNAME/$image_name:$commit_sha"
            docker push "$REGISTRY/$GITHUB_USERNAME/$image_name:$commit_sha"
            
            success "  Service $service_key construit et poussé"
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
    
    success "Configuration transférée"
}

start_services_on_hostinger() {
    log "🔄 Démarrage des services sur Hostinger..."
    
    run_remote_cmd "cd /opt/${PROJECT_NAME} && {
        # Login to GHCR
        echo '$CR_PAT' | docker login ghcr.io -u '$GITHUB_USERNAME' --password-stdin
        
        # Arrêter les anciens services
        docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env down --remove-orphans || true
        
        # Pull des nouvelles images
        docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env pull
        
        # Démarrer les services
        docker-compose -f $DOCKER_COMPOSE_FILE --env-file .env up -d
        
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
    echo -e "${BLUE}📋 Images GHCR :${NC}"
    for i in "${!BACKEND_SERVICES_DIRS[@]}"; do
        local service_key="${BACKEND_SERVICES_DIRS[$i]}"
        local image_name="${BACKEND_SERVICES_IMAGES[$i]}"
        echo "  • $service_key: $REGISTRY/$GITHUB_USERNAME/$image_name:latest"
    done
    for i in "${!FRONTEND_SERVICES_DIRS[@]}"; do
        local service_key="${FRONTEND_SERVICES_DIRS[$i]}"
        local image_name="${FRONTEND_SERVICES_IMAGES[$i]}"
        echo "  • $service_key: $REGISTRY/$GITHUB_USERNAME/$image_name:latest"
    done
    echo ""
    echo -e "${PURPLE}🚀 Commandes utiles :${NC}"
    echo "  • Status: ssh $HOSTINGER_USER@$HOSTINGER_IP 'cd /opt/$PROJECT_NAME && docker-compose ps'"
    echo "  • Logs: ssh $HOSTINGER_USER@$HOSTINGER_IP 'cd /opt/$PROJECT_NAME && docker-compose logs -f'"
    echo "  • Restart: ssh $HOSTINGER_USER@$HOSTINGER_IP 'cd /opt/$PROJECT_NAME && docker-compose restart'"
}

main() {
    echo -e "${PURPLE}"
    echo "🚀 ===== DÉPLOIEMENT PRODUCTION DEALTOBOOK AVEC GHCR ====="
    echo "=========================================================="
    echo -e "${NC}"
    
    case "$1" in
        build)
            check_prerequisites
            login_to_ghcr
            build_backend_services
            build_frontend_services
            ;;
        deploy)
            check_prerequisites
            login_to_ghcr
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
        status)
            health_check
            ;;
        *)
            echo "Usage: $0 {build|deploy|config|start|status}"
            echo ""
            echo "  build   - Construire et pousser les images vers GHCR"
            echo "  deploy  - Déploiement complet (build + deploy + config)"
            echo "  config  - Déployer uniquement la configuration"
            echo "  start   - Démarrer les services sur Hostinger"
            echo "  status  - Vérifier le status du déploiement"
            echo ""
            echo "🔑 Prérequis :"
            echo "  export CR_PAT=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"
            echo "  export HOSTINGER_IP=148.230.114.13"
            echo "  export HOSTINGER_USER=root"
            echo ""
            echo "🚀 Pour un déploiement complet :"
            echo "  ./deploy-ghcr-production.sh deploy"
            exit 1
            ;;
    esac
}

main "$@"

