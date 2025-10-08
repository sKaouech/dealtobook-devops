#!/bin/bash
set -e

# 🧪 Script de test pour le déploiement GHCR DealToBook

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

log() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

test_prerequisites() {
    log "🔍 Test des prérequis..."
    
    local errors=0
    
    # Test Docker
    if command -v docker &> /dev/null; then
        success "Docker installé"
    else
        error "Docker non installé"
        ((errors++))
    fi
    
    # Test Docker Compose
    if command -v docker-compose &> /dev/null; then
        success "Docker Compose installé"
    else
        error "Docker Compose non installé"
        ((errors++))
    fi
    
    # Test variable CR_PAT
    if [ -n "$CR_PAT" ]; then
        success "Variable CR_PAT définie"
    else
        error "Variable CR_PAT non définie"
        ((errors++))
    fi
    
    # Test SSH vers Hostinger
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${HOSTINGER_USER}@${HOSTINGER_IP}" "echo 'SSH OK'" &> /dev/null; then
        success "Connexion SSH vers Hostinger OK"
    else
        error "Impossible de se connecter à Hostinger via SSH"
        ((errors++))
    fi
    
    return $errors
}

test_ghcr_connectivity() {
    log "🔑 Test de connexion à GHCR..."
    
    if echo "$CR_PAT" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin &> /dev/null; then
        success "Connexion à GHCR réussie"
        return 0
    else
        error "Échec de connexion à GHCR"
        return 1
    fi
}

test_images_availability() {
    log "📦 Test de disponibilité des images GHCR..."
    
    local images=(
        "dealdealgenerator"
        "dealsecurity" 
        "dealsetting"
        "dealtobook-deal-webui"
        "dealtobook-deal-website"
    )
    
    local errors=0
    
    for image in "${images[@]}"; do
        if docker manifest inspect "$REGISTRY/$GITHUB_USERNAME/$image:latest" &> /dev/null; then
            success "Image $image disponible"
        else
            error "Image $image non disponible"
            ((errors++))
        fi
    done
    
    return $errors
}

test_docker_compose_syntax() {
    log "📋 Test de la syntaxe Docker Compose..."
    
    if [ -f "docker-compose.ghcr.yml" ]; then
        if docker-compose -f docker-compose.ghcr.yml config &> /dev/null; then
            success "Syntaxe Docker Compose valide"
            return 0
        else
            error "Syntaxe Docker Compose invalide"
            return 1
        fi
    else
        error "Fichier docker-compose.ghcr.yml non trouvé"
        return 1
    fi
}

test_environment_file() {
    log "🌍 Test du fichier d'environnement..."
    
    if [ -f "dealtobook-ghcr.env" ]; then
        success "Fichier dealtobook-ghcr.env trouvé"
        
        # Vérifier les variables critiques
        local critical_vars=(
            "POSTGRES_PASSWORD"
            "KEYCLOAK_ADMIN_PASSWORD"
            "GRAFANA_ADMIN_PASSWORD"
            "GITHUB_USERNAME"
            "REGISTRY"
        )
        
        local errors=0
        
        for var in "${critical_vars[@]}"; do
            if grep -q "^$var=" dealtobook-ghcr.env; then
                success "Variable $var définie"
            else
                error "Variable $var manquante"
                ((errors++))
            fi
        done
        
        return $errors
    else
        error "Fichier dealtobook-ghcr.env non trouvé"
        return 1
    fi
}

test_deployment_script() {
    log "🚀 Test du script de déploiement..."
    
    if [ -f "deploy-ghcr-production.sh" ] && [ -x "deploy-ghcr-production.sh" ]; then
        success "Script deploy-ghcr-production.sh exécutable"
        
        # Test de la syntaxe bash
        if bash -n deploy-ghcr-production.sh; then
            success "Syntaxe du script valide"
            return 0
        else
            error "Erreur de syntaxe dans le script"
            return 1
        fi
    else
        error "Script deploy-ghcr-production.sh manquant ou non exécutable"
        return 1
    fi
}

test_nginx_config() {
    log "🌐 Test de la configuration Nginx..."
    
    if [ -f "nginx/nginx.prod.conf" ]; then
        success "Configuration Nginx trouvée"
        
        # Test de la syntaxe Nginx avec Docker
        if docker run --rm -v "$(pwd)/nginx/nginx.prod.conf:/etc/nginx/nginx.conf:ro" nginx:alpine nginx -t &> /dev/null; then
            success "Syntaxe Nginx valide"
            return 0
        else
            error "Erreur de syntaxe Nginx"
            return 1
        fi
    else
        warning "Configuration Nginx non trouvée (optionnel)"
        return 0
    fi
}

test_monitoring_config() {
    log "📊 Test de la configuration monitoring..."
    
    local errors=0
    
    # Test Prometheus
    if [ -f "monitoring/prometheus.yml" ]; then
        success "Configuration Prometheus trouvée"
    else
        error "Configuration Prometheus manquante"
        ((errors++))
    fi
    
    # Test Grafana
    if [ -d "monitoring/grafana/provisioning" ]; then
        success "Configuration Grafana trouvée"
    else
        error "Configuration Grafana manquante"
        ((errors++))
    fi
    
    return $errors
}

test_remote_deployment() {
    log "🔄 Test de déploiement sur Hostinger..."
    
    # Test de création du répertoire
    if ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "mkdir -p /tmp/dealtobook-test && echo 'Directory created'" &> /dev/null; then
        success "Création de répertoire sur Hostinger OK"
        
        # Nettoyage
        ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "rm -rf /tmp/dealtobook-test" &> /dev/null
        
        return 0
    else
        error "Impossible de créer un répertoire sur Hostinger"
        return 1
    fi
}

test_dns_resolution() {
    log "🌐 Test de résolution DNS..."
    
    local domains=(
        "administration-dev.dealtobook.com"
        "website-dev.dealtobook.com"
        "keycloak-dev.dealtobook.com"
    )
    
    local errors=0
    
    for domain in "${domains[@]}"; do
        if nslookup "$domain" &> /dev/null; then
            success "DNS $domain résolu"
        else
            error "DNS $domain non résolu"
            ((errors++))
        fi
    done
    
    return $errors
}

test_ssl_certificates() {
    log "🔒 Test des certificats SSL..."
    
    local domains=(
        "administration-dev.dealtobook.com"
        "website-dev.dealtobook.com"
        "keycloak-dev.dealtobook.com"
    )
    
    local errors=0
    
    for domain in "${domains[@]}"; do
        if timeout 10 openssl s_client -connect "$domain:443" -servername "$domain" </dev/null 2>/dev/null | grep -q "Verify return code: 0"; then
            success "Certificat SSL $domain valide"
        else
            warning "Certificat SSL $domain invalide ou non accessible"
            # Ne pas compter comme erreur critique
        fi
    done
    
    return 0
}

run_integration_test() {
    log "🧪 Test d'intégration complet..."
    
    info "Démarrage d'un test de déploiement local..."
    
    # Test avec un docker-compose local
    if docker-compose -f docker-compose.ghcr.yml --env-file dealtobook-ghcr.env config > /tmp/docker-compose-test.yml; then
        success "Configuration Docker Compose générée"
        
        # Test de pull des images
        if docker-compose -f /tmp/docker-compose-test.yml pull --quiet; then
            success "Images Docker pullées avec succès"
        else
            error "Échec du pull des images Docker"
            return 1
        fi
        
        # Nettoyage
        rm -f /tmp/docker-compose-test.yml
        
        return 0
    else
        error "Échec de génération de la configuration Docker Compose"
        return 1
    fi
}

show_test_summary() {
    local total_errors=$1
    
    echo ""
    echo "=================================================="
    if [ $total_errors -eq 0 ]; then
        echo -e "${GREEN}🎉 TOUS LES TESTS SONT PASSÉS !${NC}"
        echo ""
        echo -e "${BLUE}✅ Votre configuration GHCR est prête pour le déploiement${NC}"
        echo ""
        echo -e "${PURPLE}🚀 Commandes de déploiement :${NC}"
        echo "  export CR_PAT=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"
        echo "  ./deploy-ghcr-production.sh build    # Build et push des images"
        echo "  ./deploy-ghcr-production.sh deploy   # Déploiement complet"
    else
        echo -e "${RED}❌ $total_errors ERREUR(S) DÉTECTÉE(S)${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  Corrigez les erreurs avant de déployer${NC}"
        echo ""
        echo -e "${BLUE}📋 Actions recommandées :${NC}"
        echo "  1. Vérifiez les prérequis manquants"
        echo "  2. Configurez les variables d'environnement"
        echo "  3. Testez la connexion SSH vers Hostinger"
        echo "  4. Vérifiez la disponibilité des images GHCR"
    fi
    echo "=================================================="
}

main() {
    echo -e "${PURPLE}"
    echo "🧪 ===== TEST DE CONFIGURATION GHCR DEALTOBOOK ====="
    echo "===================================================="
    echo -e "${NC}"
    
    local total_errors=0
    
    # Exécuter tous les tests
    test_prerequisites || ((total_errors += $?))
    test_ghcr_connectivity || ((total_errors += $?))
    test_images_availability || ((total_errors += $?))
    test_docker_compose_syntax || ((total_errors += $?))
    test_environment_file || ((total_errors += $?))
    test_deployment_script || ((total_errors += $?))
    test_nginx_config || ((total_errors += $?))
    test_monitoring_config || ((total_errors += $?))
    test_remote_deployment || ((total_errors += $?))
    test_dns_resolution || ((total_errors += $?))
    test_ssl_certificates || ((total_errors += $?))
    run_integration_test || ((total_errors += $?))
    
    show_test_summary $total_errors
    
    exit $total_errors
}

main "$@"

