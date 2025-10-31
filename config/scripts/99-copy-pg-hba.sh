#!/bin/bash
# Script exécuté après l'initialisation PostgreSQL (PREMIERE INIT SEULEMENT)
# Copie le pg_hba.conf personnalisé dans le répertoire data

set -e

echo "=========================================="
echo "Application de pg_hba.conf personnalisé"
echo "=========================================="

if [ -f /tmp/pg_hba_custom.conf ]; then
    # Attendre que pg_hba.conf soit créé par PostgreSQL
    local max_wait=30
    local waited=0
    while [ ! -f /var/lib/postgresql/data/pg_hba.conf ] && [ $waited -lt $max_wait ]; do
        sleep 1
        waited=$((waited + 1))
    done
    
    if [ -f /var/lib/postgresql/data/pg_hba.conf ]; then
        echo "📋 Remplacement de pg_hba.conf par la configuration personnalisée..."
        cp -f /tmp/pg_hba_custom.conf /var/lib/postgresql/data/pg_hba.conf
        chmod 600 /var/lib/postgresql/data/pg_hba.conf
        # S'assurer que le propriétaire est postgres pour permettre le reload
        chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf 2>/dev/null || true
        echo "✅ pg_hba.conf personnalisé appliqué"
        
        echo "📄 Règles pg_hba.conf actives:"
        grep -E "^host|^local" /var/lib/postgresql/data/pg_hba.conf | head -10 || head -5 /var/lib/postgresql/data/pg_hba.conf
    else
        echo "⚠️  pg_hba.conf non trouvé dans /var/lib/postgresql/data/"
    fi
else
    echo "⚠️  /tmp/pg_hba_custom.conf non trouvé"
fi

echo "=========================================="

