#!/bin/bash
set -e

# 🔄 Script de synchronisation depuis Hostinger vers le repository local
# Récupère tous les fichiers modifiés sur le serveur de production

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

sync_file() {
    local remote_file="$1"
    local local_file="$2"
    
    log "Synchronisation: ${remote_file} -> ${local_file}"
    
    if scp -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}:${REMOTE_PATH}/${remote_file}" "${local_file}"; then
        success "✅ ${local_file} synchronisé"
    else
        warning "⚠️  Échec de synchronisation: ${local_file}"
    fi
}

sync_directory() {
    local remote_dir="$1"
    local local_dir="$2"
    
    log "Synchronisation du répertoire: ${remote_dir} -> ${local_dir}"
    
    # Créer le répertoire local s'il n'existe pas
    mkdir -p "${local_dir}"
    
    if scp -r -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}:${REMOTE_PATH}/${remote_dir}/" "${local_dir}/"; then
        success "✅ Répertoire ${local_dir} synchronisé"
    else
        warning "⚠️  Échec de synchronisation du répertoire: ${local_dir}"
    fi
}

main() {
    log "🔄 Début de la synchronisation depuis Hostinger..."
    
    # Docker Compose et environnement
    sync_file "docker-compose.ghcr-complete.yml" "./docker-compose.ghcr-complete.yml"
    sync_file ".env" "./dealtobook-ghcr.env"
    
    # Configurations Nginx
    sync_file "nginx/nginx.http.conf" "./nginx/nginx.http.conf"
    sync_file "nginx/nginx.simple.conf" "./nginx/nginx.simple.conf"
    sync_file "nginx/nginx.prod.conf" "./nginx/nginx.prod.conf"
    
    # Scripts de base de données (s'ils existent)
    sync_file "scripts/init-multiple-databases.sh" "./scripts/init-multiple-databases.sh" || true
    
    # Configurations de monitoring (s'ils existent)
    sync_file "monitoring/prometheus.yml" "./monitoring/prometheus.yml" || true
    
    # Synchroniser les configurations Grafana si elles existent
    if ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "test -d ${REMOTE_PATH}/monitoring/grafana"; then
        sync_directory "monitoring/grafana" "./monitoring/grafana"
    fi
    
    log "📊 Vérification des différences..."
    
    # Vérifier s'il y a des changements
    if git status --porcelain | grep -q .; then
        warning "📝 Changements détectés dans le repository:"
        git status --short
        
        echo ""
        read -p "Voulez-vous commiter ces changements ? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "💾 Commit des changements..."
            git add .
            git commit -m "🔄 Sync from Hostinger - $(date '+%Y-%m-%d %H:%M:%S')

- Updated docker-compose.ghcr-complete.yml
- Updated environment variables
- Updated Nginx configurations
- Synced monitoring configs"
            success "✅ Changements commitées"
            
            read -p "Voulez-vous pousser vers le repository distant ? (y/N): " -n 1 -r
            echo
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log "🚀 Push vers le repository distant..."
                git push
                success "✅ Changements poussés vers le repository distant"
            fi
        else
            log "ℹ️  Changements non commitées. Vous pouvez les réviser manuellement."
        fi
    else
        success "✅ Aucun changement détecté - Repository déjà synchronisé"
    fi
    
    success "🎉 Synchronisation terminée avec succès !"
}

# Vérifier si nous sommes dans le bon répertoire
if [ ! -f "docker-compose.ghcr.yml" ] && [ ! -f "docker-compose.ghcr-complete.yml" ]; then
    error "❌ Veuillez exécuter ce script depuis le répertoire racine du projet"
fi

main "$@"
