#!/bin/bash
set -e

function create_database() {
    local database=$1
    echo "Vérification/création de la base de données '$database'..."
    
    # Vérifier si la base existe, sinon la créer
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        DO \$\$
        BEGIN
            IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$database') THEN
                CREATE DATABASE $database;
            END IF;
        END
        \$\$;
        
        -- S'assurer que l'utilisateur a tous les droits
        GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRES_USER;
EOSQL
    
    echo "✅ Base de données '$database' prête"
}

# Databases nécessaires pour l'application DealToBook
REQUIRED_DATABASES="keycloak deal_generator deal_setting"

echo "================================================"
echo "Initialization des bases de données PostgreSQL"
echo "================================================"

# Créer les bases de données requises
for db in $REQUIRED_DATABASES; do
    create_database "$db"
done

# Si POSTGRES_MULTIPLE_DATABASES est défini, créer aussi ces bases additionnelles
if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "Création des bases de données additionnelles: $POSTGRES_MULTIPLE_DATABASES"
    for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        # Ignorer les bases déjà créées
        if ! echo "$REQUIRED_DATABASES" | grep -q "$db"; then
            create_database "$db"
        fi
    done
    echo "Bases de données additionnelles créées"
fi

echo "================================================"
echo "Initialization terminée avec succès"
echo "================================================"
