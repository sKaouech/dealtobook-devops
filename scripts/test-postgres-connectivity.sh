#!/bin/bash
set -e

# 🔍 Script de test de connectivité PostgreSQL
# Teste les connexions Azure et Hostinger avant migration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
AZURE_HOST="dev-dealtobook-postgres.postgres.database.azure.com"
AZURE_PORT="5432"
AZURE_USER="${AZURE_USER:-dealtobook}"
AZURE_PASSWORD="${AZURE_PASSWORD:-OTAxNWNhY2JmMWZlMDAzYTY}"
AZURE_DATABASES=("deal_generator" "keycloak" "deal_setting")

HOSTINGER_IP="148.230.114.13"
HOSTINGER_USER="root"
HOSTINGER_POSTGRES_USER="dealtobook"
HOSTINGER_POSTGRES_DB="dealtobook_db"

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

test_prerequisites() {
    log "🔍 Test des prérequis..."
    
    local errors=0
    
    # Test pg_dump
    if command -v pg_dump &> /dev/null; then
        success "pg_dump installé"
    else
        error "pg_dump non installé"
        ((errors++))
    fi
    
    # Test psql
    if command -v psql &> /dev/null; then
        success "psql installé"
    else
        error "psql non installé"
        ((errors++))
    fi
    
    # Test variables d'environnement
    if [ -n "$AZURE_PASSWORD" ]; then
        success "Variable AZURE_PASSWORD définie"
    else
        error "Variable AZURE_PASSWORD non définie"
        ((errors++))
    fi
    
    return $errors
}

test_azure_connection() {
    log "🔗 Test de connexion Azure PostgreSQL..."
    
    local errors=0
    
    # Test connexion de base
    if PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d postgres -c "SELECT version();" &> /dev/null; then
        success "Connexion Azure PostgreSQL réussie"
    else
        error "Impossible de se connecter à Azure PostgreSQL"
        ((errors++))
        return $errors
    fi
    
    # Test des bases de données
    for db in "${AZURE_DATABASES[@]}"; do
        if PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d "$db" -c "SELECT 1;" &> /dev/null; then
            success "Base Azure $db accessible"
            
            # Compter les tables
            local table_count=$(PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d "$db" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
            success "  → $table_count tables dans $db"
            
            # Taille de la base
            local db_size=$(PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d "$db" -t -c "SELECT pg_size_pretty(pg_database_size('$db'));" 2>/dev/null | tr -d ' ')
            success "  → Taille: $db_size"
            
        else
            error "Base Azure $db inaccessible"
            ((errors++))
        fi
    done
    
    return $errors
}

test_hostinger_ssh() {
    log "🔗 Test de connexion SSH Hostinger..."
    
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${HOSTINGER_USER}@${HOSTINGER_IP}" "echo 'SSH OK'" &> /dev/null; then
        success "Connexion SSH Hostinger réussie"
        return 0
    else
        error "Impossible de se connecter à Hostinger via SSH"
        return 1
    fi
}

test_hostinger_postgres() {
    log "🔗 Test PostgreSQL sur Hostinger..."
    
    local errors=0
    
    # Vérifier si le container PostgreSQL existe
    local postgres_status=$(ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
        "docker ps --filter name=dealtobook-postgres --format '{{.Status}}'" 2>/dev/null || echo "Not found")
    
    if [[ "$postgres_status" == *"Up"* ]]; then
        success "Container PostgreSQL en cours d'exécution"
    else
        warning "Container PostgreSQL non démarré ($postgres_status)"
        
        # Essayer de le démarrer
        log "  Tentative de démarrage de PostgreSQL..."
        if ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
           "cd /opt/dealtobook && docker-compose -f docker-compose.ghcr.yml up -d postgres" &> /dev/null; then
            success "PostgreSQL démarré"
            sleep 10  # Attendre le démarrage
        else
            error "Impossible de démarrer PostgreSQL"
            ((errors++))
            return $errors
        fi
    fi
    
    # Test de connexion PostgreSQL
    if ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
       "docker exec dealtobook-postgres psql -U $HOSTINGER_POSTGRES_USER -d $HOSTINGER_POSTGRES_DB -c 'SELECT version();'" &> /dev/null; then
        success "Connexion PostgreSQL Hostinger réussie"
    else
        error "Impossible de se connecter à PostgreSQL Hostinger"
        ((errors++))
        return $errors
    fi
    
    # Lister les bases existantes
    local existing_dbs=$(ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
        "docker exec dealtobook-postgres psql -U $HOSTINGER_POSTGRES_USER -d $HOSTINGER_POSTGRES_DB -t -c \"SELECT datname FROM pg_database WHERE datistemplate = false;\"" 2>/dev/null | grep -v "^$" | tr -d ' ')
    
    success "Bases existantes sur Hostinger:"
    echo "$existing_dbs" | while read -r db; do
        if [ -n "$db" ]; then
            success "  → $db"
        fi
    done
    
    return $errors
}

test_network_performance() {
    log "🚀 Test de performance réseau..."
    
    # Test de latence vers Azure
    local azure_ping=$(ping -c 3 dev-dealtobook-postgres.postgres.database.azure.com 2>/dev/null | tail -1 | awk -F '/' '{print $5}' || echo "N/A")
    success "Latence Azure: ${azure_ping}ms"
    
    # Test de latence vers Hostinger
    local hostinger_ping=$(ping -c 3 148.230.114.13 2>/dev/null | tail -1 | awk -F '/' '{print $5}' || echo "N/A")
    success "Latence Hostinger: ${hostinger_ping}ms"
    
    # Test de bande passante SSH
    log "  Test de bande passante SSH..."
    local start_time=$(date +%s)
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" "dd if=/dev/zero bs=1M count=10 2>/dev/null" > /dev/null
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local bandwidth=$((10 / duration))
    success "Bande passante SSH: ~${bandwidth}MB/s"
}

estimate_migration_time() {
    log "⏱️  Estimation du temps de migration..."
    
    local total_size_mb=0
    
    for db in "${AZURE_DATABASES[@]}"; do
        if [ -n "$AZURE_PASSWORD" ]; then
            local db_size_bytes=$(PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d "$db" -t -c "SELECT pg_database_size('$db');" 2>/dev/null | tr -d ' ' || echo "0")
            local db_size_mb=$((db_size_bytes / 1024 / 1024))
            total_size_mb=$((total_size_mb + db_size_mb))
            success "  $db: ${db_size_mb}MB"
        fi
    done
    
    # Estimation basée sur 5MB/s en moyenne (dump + transfert + restore)
    local estimated_minutes=$((total_size_mb / 5 / 60 + 1))
    if [ $estimated_minutes -lt 1 ]; then
        estimated_minutes=1
    fi
    
    success "Taille totale: ${total_size_mb}MB"
    success "Temps estimé: ~${estimated_minutes} minutes"
}

show_migration_readiness() {
    local total_errors=$1
    
    echo ""
    echo "=================================================="
    if [ $total_errors -eq 0 ]; then
        echo -e "${GREEN}🎉 PRÊT POUR LA MIGRATION !${NC}"
        echo ""
        echo -e "${BLUE}✅ Tous les tests sont passés${NC}"
        echo ""
        echo -e "${BLUE}🚀 Commandes de migration :${NC}"
        echo "  # Migration complète"
        echo "  ./migrate-postgres-azure-to-hostinger.sh migrate"
        echo ""
        echo "  # Ou étape par étape"
        echo "  ./migrate-postgres-azure-to-hostinger.sh backup"
        echo "  ./migrate-postgres-azure-to-hostinger.sh restore"
    else
        echo -e "${RED}❌ $total_errors ERREUR(S) DÉTECTÉE(S)${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  Corrigez les erreurs avant de migrer${NC}"
        echo ""
        echo -e "${BLUE}📋 Actions recommandées :${NC}"
        echo "  1. Installez PostgreSQL client (pg_dump, psql)"
        echo "  2. Configurez les variables d'environnement"
        echo "  3. Vérifiez les connexions réseau"
        echo "  4. Démarrez PostgreSQL sur Hostinger"
    fi
    echo "=================================================="
}

main() {
    echo -e "${BLUE}"
    echo "🔍 ===== TEST DE CONNECTIVITÉ POSTGRESQL ====="
    echo "=============================================="
    echo -e "${NC}"
    
    local total_errors=0
    
    # Exécuter tous les tests
    test_prerequisites || ((total_errors += $?))
    test_azure_connection || ((total_errors += $?))
    test_hostinger_ssh || ((total_errors += $?))
    test_hostinger_postgres || ((total_errors += $?))
    test_network_performance || true  # Ne pas compter comme erreur
    estimate_migration_time || true   # Ne pas compter comme erreur
    
    show_migration_readiness $total_errors
    
    exit $total_errors
}

main "$@"
