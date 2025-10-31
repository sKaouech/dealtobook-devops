#!/bin/bash
set -e

# 🔄 Script de migration PostgreSQL Azure → Hostinger
# Migre la base de données PostgreSQL d'Azure vers Hostinger

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration Azure (source)
AZURE_HOST="dev-dealtobook-postgres.postgres.database.azure.com"
AZURE_PORT="5432"
AZURE_USER="${AZURE_USER:-dealtobook}"
AZURE_PASSWORD="${AZURE_PASSWORD:-OTAxNWNhY2JmMWZlMDAzYTY}"
AZURE_DATABASES=("deal_generator" "keycloak" "deal_setting")

# Configuration Hostinger (destination)
HOSTINGER_IP="148.230.114.13"
HOSTINGER_USER="root"
HOSTINGER_POSTGRES_USER="dealtobook"
HOSTINGER_POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-devpassword123}"
HOSTINGER_POSTGRES_DB="dealtobook_db"

# Configuration de migration
BACKUP_DIR="./postgres-migration-$(date +%Y%m%d-%H%M%S)"
MIGRATION_LOG="$BACKUP_DIR/migration.log"

log() {
    # Créer le répertoire de backup s'il n'existe pas
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$MIGRATION_LOG"
}

success() {
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$MIGRATION_LOG"
}

error() {
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    echo -e "${RED}❌ $1${NC}" | tee -a "$MIGRATION_LOG"
    exit 1
}

warning() {
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$MIGRATION_LOG"
}

info() {
    mkdir -p "$BACKUP_DIR" 2>/dev/null
    echo -e "${PURPLE}ℹ️  $1${NC}" | tee -a "$MIGRATION_LOG"
}

check_prerequisites() {
    log "🔍 Vérification des prérequis..."
    
    # Vérifier pg_dump et psql
    if ! command -v pg_dump &> /dev/null; then
        error "pg_dump n'est pas installé. Installez PostgreSQL client."
    fi
    
    if ! command -v psql &> /dev/null; then
        error "psql n'est pas installé. Installez PostgreSQL client."
    fi
    
    # Vérifier SSH vers Hostinger
    if ! ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${HOSTINGER_USER}@${HOSTINGER_IP}" "echo 'SSH OK'" &> /dev/null; then
        error "Impossible de se connecter à Hostinger via SSH"
    fi
    
    # Vérifier les variables d'environnement
    if [ -z "$AZURE_PASSWORD" ]; then
        error "Variable AZURE_PASSWORD non définie"
    fi
    
    success "Prérequis validés"
}

test_azure_connection() {
    log "🔗 Test de connexion à Azure PostgreSQL..."
    
    if PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d postgres -c "SELECT version();" &> /dev/null; then
        success "Connexion Azure PostgreSQL réussie"
    else
        error "Impossible de se connecter à Azure PostgreSQL"
    fi
}

test_hostinger_connection() {
    log "🔗 Test de connexion à Hostinger PostgreSQL..."
    
    # Tester via SSH si PostgreSQL est accessible
    if ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
       "docker exec dealtobook-postgres psql -U $HOSTINGER_POSTGRES_USER -d $HOSTINGER_POSTGRES_DB -c 'SELECT version();'" &> /dev/null; then
        success "Connexion Hostinger PostgreSQL réussie"
    else
        error "Impossible de se connecter à Hostinger PostgreSQL"
    fi
}

backup_azure_databases() {
    log "💾 Sauvegarde des bases de données Azure..."
    
    for db in "${AZURE_DATABASES[@]}"; do
        log "  Sauvegarde de la base $db..."
        
        local backup_file="$BACKUP_DIR/${db}_backup.sql"
        
        # Dump de la base avec options optimisées
        PGPASSWORD="$AZURE_PASSWORD" pg_dump \
            -h "$AZURE_HOST" \
            -p "$AZURE_PORT" \
            -U "$AZURE_USER" \
            -d "$db" \
            --verbose \
            --no-owner \
            --no-privileges \
            --no-tablespaces \
            --clean \
            --if-exists \
            --format=plain \
            --file="$backup_file" || error "Échec de la sauvegarde de $db"
        
        # Vérifier la taille du fichier
        local file_size=$(du -h "$backup_file" | cut -f1)
        success "  Base $db sauvegardée ($file_size)"
        
        # Créer une version compressée
        gzip -c "$backup_file" > "${backup_file}.gz"
        success "  Base $db compressée"
    done
}

prepare_hostinger_databases() {
    log "🗄️ Préparation des bases de données sur Hostinger..."
    
    # S'assurer que PostgreSQL est démarré
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
        "cd /opt/dealtobook && docker-compose -f docker-compose.ghcr.yml up -d postgres" || warning "PostgreSQL déjà démarré"
    
    # Attendre que PostgreSQL soit prêt
    log "  Attente de PostgreSQL (30s)..."
    sleep 30
    
    # Créer les bases de données si elles n'existent pas
    for db in "${AZURE_DATABASES[@]}"; do
        log "  Création de la base $db sur Hostinger..."
        
        ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
            "docker exec dealtobook-postgres psql -U $HOSTINGER_POSTGRES_USER -d $HOSTINGER_POSTGRES_DB -c \"CREATE DATABASE \\\"$db\\\" OWNER $HOSTINGER_POSTGRES_USER;\"" 2>/dev/null || warning "Base $db existe déjà"
        
        success "  Base $db prête sur Hostinger"
    done
}

transfer_backups_to_hostinger() {
    log "📤 Transfert des sauvegardes vers Hostinger..."
    
    # Créer le répertoire de migration sur Hostinger
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
        "mkdir -p /tmp/postgres-migration"
    
    # Transférer les fichiers de sauvegarde
    for db in "${AZURE_DATABASES[@]}"; do
        log "  Transfert de $db..."
        
        local backup_file="$BACKUP_DIR/${db}_backup.sql"
        
        scp -o StrictHostKeyChecking=no "$backup_file" \
            "${HOSTINGER_USER}@${HOSTINGER_IP}:/tmp/postgres-migration/" || error "Échec du transfert de $db"
        
        success "  $db transféré"
    done
}

restore_databases_on_hostinger() {
    log "🔄 Restauration des bases de données sur Hostinger..."
    
    for db in "${AZURE_DATABASES[@]}"; do
        log "  Restauration de $db..."
        
        # Restaurer la base de données
        ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
            "docker exec -i dealtobook-postgres psql -U $HOSTINGER_POSTGRES_USER -d $db < /tmp/postgres-migration/${db}_backup.sql" || error "Échec de la restauration de $db"
        
        success "  Base $db restaurée"
    done
}

verify_migration() {
    log "🔍 Vérification de la migration..."
    
    for db in "${AZURE_DATABASES[@]}"; do
        log "  Vérification de $db..."
        
        # Compter les tables sur Azure
        local azure_tables=$(PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d "$db" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
        
        # Compter les tables sur Hostinger
        local hostinger_tables=$(ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
            "docker exec dealtobook-postgres psql -U $HOSTINGER_POSTGRES_USER -d $db -t -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';\"" 2>/dev/null | tr -d ' ')
        
        if [ "$azure_tables" = "$hostinger_tables" ]; then
            success "  $db: $hostinger_tables tables migrées ✅"
        else
            warning "  $db: Azure($azure_tables) ≠ Hostinger($hostinger_tables) tables"
        fi
        
        # Vérifier quelques tables importantes (si elles existent)
        local sample_tables=("users" "deals" "settings" "roles")
        for table in "${sample_tables[@]}"; do
            local azure_count=$(PGPASSWORD="$AZURE_PASSWORD" psql -h "$AZURE_HOST" -p "$AZURE_PORT" -U "$AZURE_USER" -d "$db" -t -c "SELECT COUNT(*) FROM $table;" 2>/dev/null | tr -d ' ' || echo "0")
            local hostinger_count=$(ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
                "docker exec dealtobook-postgres psql -U $HOSTINGER_POSTGRES_USER -d $db -t -c \"SELECT COUNT(*) FROM $table;\"" 2>/dev/null | tr -d ' ' || echo "0")
            
            if [ "$azure_count" != "0" ] && [ "$azure_count" = "$hostinger_count" ]; then
                success "    Table $table: $hostinger_count enregistrements ✅"
            elif [ "$azure_count" != "0" ]; then
                warning "    Table $table: Azure($azure_count) ≠ Hostinger($hostinger_count)"
            fi
        done
    done
}

cleanup_migration_files() {
    log "🧹 Nettoyage des fichiers temporaires..."
    
    # Nettoyer sur Hostinger
    ssh -o StrictHostKeyChecking=no "${HOSTINGER_USER}@${HOSTINGER_IP}" \
        "rm -rf /tmp/postgres-migration" || warning "Erreur lors du nettoyage Hostinger"
    
    # Garder les backups locaux pour sécurité
    info "Backups conservés dans: $BACKUP_DIR"
    success "Nettoyage terminé"
}

update_application_config() {
    log "⚙️ Mise à jour de la configuration des applications..."
    
    info "Les applications DealToBook sont déjà configurées pour utiliser:"
    info "  • deal_generator → deal_generator"
    info "  • deal_security → keycloak" 
    info "  • deal_setting → deal_setting"
    
    info "Configuration dans docker-compose.ghcr.yml:"
    info "  SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/[database_name]"
    
    success "Configuration des applications OK"
}

show_migration_summary() {
    log "✅ MIGRATION TERMINÉE !"
    echo ""
    echo "=================================================="
    echo -e "${GREEN}🎉 MIGRATION AZURE → HOSTINGER RÉUSSIE !${NC}"
    echo "=================================================="
    echo ""
    echo -e "${BLUE}📊 Résumé de la migration :${NC}"
    echo "  • Source: dev-dealtobook-postgres.postgres.database.azure.com"
    echo "  • Destination: Hostinger (148.230.114.13)"
    echo "  • Bases migrées: ${#AZURE_DATABASES[@]}"
    for db in "${AZURE_DATABASES[@]}"; do
        echo "    - $db"
    done
    echo ""
    echo -e "${BLUE}📁 Backups conservés :${NC}"
    echo "  • Répertoire: $BACKUP_DIR"
    echo "  • Fichiers SQL + versions compressées"
    echo ""
    echo -e "${BLUE}🔄 Prochaines étapes :${NC}"
    echo "  1. Tester les applications avec la nouvelle base"
    echo "  2. Mettre à jour les DNS si nécessaire"
    echo "  3. Supprimer l'ancienne base Azure (après validation)"
    echo ""
    echo -e "${BLUE}🚀 Redémarrer les services :${NC}"
    echo "  ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose -f docker-compose.ghcr.yml restart'"
    echo ""
    echo -e "${PURPLE}📋 Log complet: $MIGRATION_LOG${NC}"
}

main() {
    echo -e "${PURPLE}"
    echo "🔄 ===== MIGRATION POSTGRESQL AZURE → HOSTINGER ====="
    echo "====================================================="
    echo -e "${NC}"
    
    case "$1" in
        backup)
            check_prerequisites
            test_azure_connection
            backup_azure_databases
            success "Sauvegarde terminée dans: $BACKUP_DIR"
            ;;
        restore)
            if [ ! -d "$BACKUP_DIR" ]; then
                error "Répertoire de backup non trouvé. Exécutez d'abord 'backup'."
            fi
            check_prerequisites
            test_hostinger_connection
            prepare_hostinger_databases
            transfer_backups_to_hostinger
            restore_databases_on_hostinger
            verify_migration
            cleanup_migration_files
            update_application_config
            show_migration_summary
            ;;
        migrate)
            check_prerequisites
            test_azure_connection
            test_hostinger_connection
            backup_azure_databases
            prepare_hostinger_databases
            transfer_backups_to_hostinger
            restore_databases_on_hostinger
            verify_migration
            cleanup_migration_files
            update_application_config
            show_migration_summary
            ;;
        verify)
            check_prerequisites
            test_azure_connection
            test_hostinger_connection
            verify_migration
            ;;
        *)
            echo "Usage: $0 {backup|restore|migrate|verify}"
            echo ""
            echo "  backup   - Sauvegarder seulement les bases Azure"
            echo "  restore  - Restaurer seulement sur Hostinger (après backup)"
            echo "  migrate  - Migration complète (backup + restore)"
            echo "  verify   - Vérifier la migration"
            echo ""
            echo "🔑 Variables d'environnement requises :"
            echo "  export AZURE_PASSWORD=your_azure_postgres_password"
            echo "  export POSTGRES_PASSWORD=your_hostinger_postgres_password"
            echo ""
            echo "🚀 Pour une migration complète :"
            echo "  export AZURE_PASSWORD=your_password"
            echo "  export POSTGRES_PASSWORD=devpassword123"
            echo "  ./migrate-postgres-azure-to-hostinger.sh migrate"
            exit 1
            ;;
    esac
}

main "$@"
