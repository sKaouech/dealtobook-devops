#!/bin/bash
set -e

echo "🔧 Entrypoint PostgreSQL personnalisé - Application de pg_hba.conf..."

# Fonction pour copier et appliquer pg_hba.conf
apply_pg_hba() {
    # Attendre que le répertoire data soit monté (peut prendre quelques secondes)
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if [ -d /var/lib/postgresql/data ]; then
            break
        fi
        sleep 0.5
        attempt=$((attempt + 1))
    done
    
    if [ ! -d /var/lib/postgresql/data ]; then
        echo "❌ ERREUR: /var/lib/postgresql/data non accessible après ${max_attempts} tentatives"
        return 1
    fi
    
    # Vérifier que le fichier source existe
    if [ ! -f /tmp/pg_hba_custom.conf ]; then
        echo "⚠️  WARNING: /tmp/pg_hba_custom.conf non trouvé, utilisation de la config par défaut"
        return 0
    fi
    
    echo "📋 Fichier pg_hba.conf personnalisé trouvé, application en cours..."
    
    # Si pg_hba.conf existe déjà (base existante), le remplacer immédiatement
    if [ -f /var/lib/postgresql/data/pg_hba.conf ]; then
        echo "   ✓ Base existante détectée, remplacement de pg_hba.conf..."
        # Utiliser su/sudo pour copier le fichier en tant que postgres (meilleure garantie de permissions)
        # D'abord copier vers un emplacement temporaire avec permissions postgres
        cp -f /tmp/pg_hba_custom.conf /tmp/pg_hba_new.conf
        chmod 600 /tmp/pg_hba_new.conf
        chown postgres:postgres /tmp/pg_hba_new.conf 2>/dev/null || true
        
        # Supprimer l'ancien fichier et déplacer le nouveau
        rm -f /var/lib/postgresql/data/pg_hba.conf
        # Copier en utilisant runuser pour garantir que le fichier appartient à postgres
        if command -v runuser >/dev/null 2>&1; then
            runuser -u postgres -- cp /tmp/pg_hba_new.conf /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || \
            cp /tmp/pg_hba_new.conf /var/lib/postgresql/data/pg_hba.conf && \
            chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf && \
            chmod 600 /var/lib/postgresql/data/pg_hba.conf
        else
            # Si runuser n'est pas disponible, copier et corriger les permissions
            cp -f /tmp/pg_hba_new.conf /var/lib/postgresql/data/pg_hba.conf
            chmod 600 /var/lib/postgresql/data/pg_hba.conf
            # S'assurer que le répertoire data appartient à postgres
            chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || {
                echo "   🔧 Correction des permissions du répertoire data..."
                chown -R postgres:postgres /var/lib/postgresql/data 2>/dev/null || true
            }
        fi
        rm -f /tmp/pg_hba_new.conf
        
        # Vérifier les permissions finales
        if ls -l /var/lib/postgresql/data/pg_hba.conf 2>/dev/null | grep -q "postgres postgres"; then
            echo "   ✅ pg_hba.conf remplacé avec permissions correctes (propriétaire: postgres)"
        else
            echo "   ⚠️  Permissions peuvent être incorrectes - affichage:"
            ls -l /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || echo "   ❌ Fichier non trouvé"
        fi
        
        # Vérification immédiate du contenu
        echo "   📄 Vérification du contenu copié:"
        if grep -q "172.16.0.0/12" /var/lib/postgresql/data/pg_hba.conf 2>/dev/null; then
            echo "      ✓ Règle Docker network (172.16.0.0/12) présente"
        else
            echo "      ❌ Règle Docker network ABSENTE!"
        fi
        if grep -q "0.0.0.0/0" /var/lib/postgresql/data/pg_hba.conf 2>/dev/null; then
            echo "      ✓ Règle toutes IPs (0.0.0.0/0) présente"
        else
            echo "      ❌ Règle toutes IPs ABSENTE!"
        fi
    fi
    
    # L'entrypoint standard de PostgreSQL va créer/initialiser la base si nécessaire
    # On utilisera un hook après l'init pour remplacer pg_hba.conf si c'est une première init
}

# Appliquer pg_hba.conf maintenant
apply_pg_hba

# Hook pour copier pg_hba.conf après l'initialisation ET recharger PostgreSQL
hook_after_init_and_reload() {
    # Attendre que PostgreSQL soit démarré
    local max_wait=120
    local waited=0
    
    # Attendre que le fichier pg_hba.conf existe
    while [ ! -f /var/lib/postgresql/data/pg_hba.conf ] && [ $waited -lt $max_wait ]; do
        sleep 1
        waited=$((waited + 1))
    done
    
    # Attendre que PostgreSQL soit prêt à recevoir des commandes
    waited=0
    while [ $waited -lt 60 ]; do
        if pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; then
            break
        fi
        sleep 2
        waited=$((waited + 1))
    done
    
    # Appliquer pg_hba.conf si nécessaire
    if [ -f /tmp/pg_hba_custom.conf ] && [ -f /var/lib/postgresql/data/pg_hba.conf ]; then
        # Vérifier si le fichier doit être remplacé
        if ! diff -q /tmp/pg_hba_custom.conf /var/lib/postgresql/data/pg_hba.conf >/dev/null 2>&1; then
            echo "📋 Remplacement du pg_hba.conf par défaut par notre configuration..."
            # Préparer le fichier temporaire avec les bonnes permissions
            cp -f /tmp/pg_hba_custom.conf /tmp/pg_hba_new.conf
            chmod 600 /tmp/pg_hba_new.conf
            chown postgres:postgres /tmp/pg_hba_new.conf 2>/dev/null || true
            
            # Supprimer l'ancien fichier
            rm -f /var/lib/postgresql/data/pg_hba.conf
            
            # Copier en tant que postgres si possible
            if command -v runuser >/dev/null 2>&1; then
                runuser -u postgres -- cp /tmp/pg_hba_new.conf /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || {
                    # Fallback: copier et corriger les permissions
                    cp /tmp/pg_hba_new.conf /var/lib/postgresql/data/pg_hba.conf
                    chmod 600 /var/lib/postgresql/data/pg_hba.conf
                    chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf
                }
            else
                # Pas de runuser, copier directement et corriger
                cp -f /tmp/pg_hba_new.conf /var/lib/postgresql/data/pg_hba.conf
                chmod 600 /var/lib/postgresql/data/pg_hba.conf
                chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || {
                    echo "   🔧 Correction des permissions du répertoire data..."
                    chown -R postgres:postgres /var/lib/postgresql/data 2>/dev/null || true
                }
            fi
            rm -f /tmp/pg_hba_new.conf
            
            # Vérifier les permissions
            if ls -l /var/lib/postgresql/data/pg_hba.conf 2>/dev/null | grep -q "postgres postgres"; then
                echo "✅ pg_hba.conf personnalisé appliqué avec permissions correctes"
            else
                echo "⚠️  pg_hba.conf appliqué mais permissions peuvent être incorrectes - affichage:"
                ls -l /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || echo "   ❌ Fichier non trouvé"
            fi
            
            # Vérifier à nouveau les permissions AVANT le reload
            if ! ls -l /var/lib/postgresql/data/pg_hba.conf | grep -q "postgres postgres"; then
                echo "   🔧 Correction des permissions avant reload..."
                chmod 600 /var/lib/postgresql/data/pg_hba.conf
                chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || true
            fi
            
            # FORCER PostgreSQL à recharger la configuration
            if pg_isready -U "$POSTGRES_USER" >/dev/null 2>&1; then
                echo "🔄 Rechargement de la configuration PostgreSQL (pg_reload_conf)..."
                # Utiliser su pour exécuter en tant que postgres si nécessaire
                psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT pg_reload_conf();" 2>&1 | grep -v "could not open\|was not reloaded" || \
                psql -U "$POSTGRES_USER" -d "postgres" -c "SELECT pg_reload_conf();" 2>&1 | grep -v "could not open\|was not reloaded" || \
                    echo "⚠️  Impossible de recharger (PostgreSQL pas encore prêt ou permissions)"
                
                # Vérifier si le reload a fonctionné en vérifiant les logs
                sleep 1
                echo "✅ Tentative de rechargement effectuée"
            fi
            
            # Afficher les règles pour vérification
            echo "📄 Règles pg_hba.conf actives:"
            grep -E "^host\s+all|^local\s+all" /var/lib/postgresql/data/pg_hba.conf | head -10 || head -10 /var/lib/postgresql/data/pg_hba.conf
        else
            echo "✅ pg_hba.conf déjà à jour (pas de changement nécessaire)"
        fi
    fi
}

# Démarrer le hook en arrière-plan pour appliquer et recharger après le démarrage
(hook_after_init_and_reload) &

# Exécuter l'entrypoint PostgreSQL standard
# PostgreSQL va lire pg_hba.conf depuis /var/lib/postgresql/data/pg_hba.conf
exec docker-entrypoint.sh "$@"

