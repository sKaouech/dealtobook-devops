#!/bin/bash
set -e

# 🚀 Script de synchronisation depuis le repository local vers Hostinger
# Déploie les changements locaux sur le serveur de production

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
HOSTINGER_IP="148.230.114.13"
HOSTINGER_USER="root"
REMOTE_PATH="/opt/dealtobook"

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

deploy_file() {
    local local_file="$1"
    local remote_file="$2"
    
    if [ ! -f "$local_file" ]; then
        warning "⚠️  Fichier local non trouvé: ${local_file}"
        return 1
    fi
    
    log "Déploiement: ${local_file} -> ${remote_file}"
    
    if scp -o StrictHostKeyChecking=no "${local_file}" "${HOSTINGER_USER}@${HOSTINGER_IP}:${REMOTE_PATH}/${remote_file}"; then
        success "✅ ${remote_file} déployé"
    else
        error "❌ Échec du déploiement: ${remote_file}"
    fi
}

deploy_directory() {
    local local_dir="$1"
    local remote_dir="$2"
    
    if [ ! -d "$local_dir" ]; then
        warning "⚠️  Répertoire local non trouvé: ${local_dir}"
        return 1
    fi
    
    log "Déploiement du répertoire: ${local_dir} -> ${remote_dir}"
    
    # Créer le répertoire distant s'il n'existe pas
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "mkdir -p ${REMOTE_PATH}/${remote_dir}"
    
    if scp -r -o StrictHostKeyChecking=no "${local_dir}/" "${HOSTINGER_USER}@${HOSTINGER_IP}:${REMOTE_PATH}/${remote_dir}/"; then
        success "✅ Répertoire ${remote_dir} déployé"
    else
        error "❌ Échec du déploiement du répertoire: ${remote_dir}"
    fi
}

restart_services() {
    log "🔄 Redémarrage des services sur Hostinger..."
    
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "
        cd ${REMOTE_PATH} && 
        docker-compose -f docker-compose.ghcr-complete.yml --env-file .env up -d --no-deps nginx
    " || warning "⚠️  Échec du redémarrage de Nginx"
    
    success "✅ Services redémarrés"
}

main() {
    local restart_flag="$1"
    
    log "🚀 Début du déploiement vers Hostinger..."
    
    # Vérifier s'il y a des changements non commitées
    if git status --porcelain | grep -q .; then
        warning "📝 Changements non commitées détectés:"
        git status --short
        
        echo ""
        read -p "Voulez-vous continuer le déploiement ? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "ℹ️  Déploiement annulé. Commitez vos changements d'abord."
            exit 0
        fi
    fi
    
    # Créer les répertoires nécessaires sur Hostinger
    log "📁 Création des répertoires sur Hostinger..."
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "
        mkdir -p ${REMOTE_PATH}/{nginx,monitoring/grafana/provisioning/{datasources,dashboards},scripts}
    "
    
    # Docker Compose et environnement
    deploy_file "./docker-compose.ghcr-complete.yml" "docker-compose.ghcr-complete.yml"
    deploy_file "./dealtobook-ghcr.env" ".env"
    
    # Configurations Nginx
    deploy_file "./nginx/nginx.http.conf" "nginx/nginx.http.conf"
    deploy_file "./nginx/nginx.simple.conf" "nginx/nginx.simple.conf" || true
    deploy_file "./nginx/nginx.prod.conf" "nginx/nginx.prod.conf" || true
    
    # Scripts de base de données
    deploy_file "./scripts/init-multiple-databases.sh" "scripts/init-multiple-databases.sh" || true
    
    # Configurations de monitoring
    deploy_file "./monitoring/prometheus.yml" "monitoring/prometheus.yml" || true
    
    # Configurations Grafana
    if [ -d "./monitoring/grafana" ]; then
        deploy_directory "./monitoring/grafana" "monitoring/grafana"
    fi
    
    # Redémarrer les services si demandé
    if [ "$restart_flag" = "--restart" ] || [ "$restart_flag" = "-r" ]; then
        restart_services
    else
        log "ℹ️  Pour redémarrer les services, utilisez: $0 --restart"
    fi
    
    success "🎉 Déploiement terminé avec succès !"
    
    log "🌐 URLs d'accès:"
    echo "  - Administration: http://administration-dev.dealtobook.com"
    echo "  - Website: http://website-dev.dealtobook.com"
    echo "  - Keycloak: http://keycloak-dev.dealtobook.com"
    echo "  - Direct IP: http://${HOSTINGER_IP}"
}

# Vérifier si nous sommes dans le bon répertoire
if [ ! -f "docker-compose.ghcr.yml" ] && [ ! -f "docker-compose.ghcr-complete.yml" ]; then
    error "❌ Veuillez exécuter ce script depuis le répertoire racine du projet"
fi

main "$@"
