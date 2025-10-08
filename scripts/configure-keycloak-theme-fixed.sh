#!/bin/bash

# Script pour configurer le thème Keycloak dealtobook - Version corrigée
# Usage: ./configure-keycloak-theme-fixed.sh

set -e

KEYCLOAK_URL="https://keycloak-dev.dealtobook.com"
ADMIN_USER="admin"
ADMIN_PASSWORD="DealToBook2024AdminSecure!"
REALM_NAME="dealtobook"
THEME_NAME="dealtobook"

echo "🎨 Configuration du thème Keycloak dealtobook (version corrigée)..."
echo ""

# Fonction pour obtenir le token admin avec plusieurs tentatives
get_admin_token() {
    local max_attempts=10
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Tentative $attempt/$max_attempts d'obtention du token admin..."
        
        local response=$(curl -k -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "username=$ADMIN_USER" \
            -d "password=$ADMIN_PASSWORD" \
            -d "grant_type=password" \
            -d "client_id=admin-cli")
        
        local token=$(echo "$response" | jq -r ".access_token // empty")
        
        if [ -n "$token" ] && [ "$token" != "null" ] && [ "$token" != "empty" ]; then
            echo "$token"
            return 0
        else
            echo "Échec de l'obtention du token (tentative $attempt)"
            echo "Réponse: $response"
            
            if [ $attempt -eq $max_attempts ]; then
                return 1
            fi
            
            echo "Attente de 10 secondes avant nouvelle tentative..."
            sleep 10
            attempt=$((attempt + 1))
        fi
    done
    
    return 1
}

# Fonction pour créer l'utilisateur admin si nécessaire
create_admin_user() {
    echo "=== Tentative de création de l'utilisateur admin ==="
    
    # Essayer de créer l'admin via les variables d'environnement
    ssh root@148.230.114.13 "docker exec dealtobook-keycloak /opt/keycloak/bin/kc.sh build" || true
    
    echo "Redémarrage de Keycloak pour s'assurer que l'admin est créé..."
    ssh root@148.230.114.13 "cd /opt/dealtobook && docker-compose -f docker-compose.ssl-complete.yml restart keycloak"
    
    echo "Attente de 60 secondes pour le redémarrage complet..."
    sleep 60
}

# Fonction pour configurer le thème
configure_theme() {
    local token=$1
    
    echo "=== Configuration du thème $THEME_NAME pour le realm $REALM_NAME ==="
    
    # Obtenir la configuration actuelle du realm
    local current_config=$(curl -k -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token")
    
    if [ -z "$current_config" ] || echo "$current_config" | grep -q "error"; then
        echo "❌ Erreur lors de la récupération de la configuration du realm"
        echo "Réponse: $current_config"
        return 1
    fi
    
    # Mettre à jour avec les thèmes
    local updated_config=$(echo "$current_config" | jq ".loginTheme = \"$THEME_NAME\" | .emailTheme = \"$THEME_NAME\"")
    
    # Appliquer la configuration
    local update_response=$(curl -k -s -w "%{http_code}" -X PUT "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "$updated_config")
    
    local http_code="${update_response: -3}"
    
    if [ "$http_code" = "204" ] || [ "$http_code" = "200" ]; then
        echo "✅ Thème configuré avec succès!"
        return 0
    else
        echo "❌ Erreur lors de la configuration du thème (HTTP $http_code)"
        echo "Réponse: $update_response"
        return 1
    fi
}

# Fonction pour vérifier la configuration
verify_theme() {
    local token=$1
    
    echo "=== Vérification de la configuration ==="
    local themes=$(curl -k -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token" | jq -r ".loginTheme, .emailTheme")
    
    echo "Thèmes configurés: $themes"
    
    if echo "$themes" | grep -q "$THEME_NAME"; then
        echo "✅ Thème correctement configuré!"
        return 0
    else
        echo "❌ Thème non configuré correctement"
        return 1
    fi
}

# Script principal
main() {
    echo "🔍 Vérification de l'accès à Keycloak..."
    
    # Vérifier que Keycloak est accessible
    if ! curl -k -s "$KEYCLOAK_URL" > /dev/null; then
        echo "❌ Keycloak n'est pas accessible à $KEYCLOAK_URL"
        exit 1
    fi
    
    echo "✅ Keycloak accessible"
    
    # Essayer d'obtenir le token admin
    echo "🔑 Tentative d'obtention du token admin..."
    
    if ADMIN_TOKEN=$(get_admin_token); then
        echo "✅ Token admin obtenu avec succès!"
    else
        echo "❌ Impossible d'obtenir le token admin, tentative de création de l'utilisateur..."
        create_admin_user
        
        echo "🔑 Nouvelle tentative d'obtention du token admin..."
        if ADMIN_TOKEN=$(get_admin_token); then
            echo "✅ Token admin obtenu après création!"
        else
            echo "❌ Impossible d'obtenir le token admin même après création"
            echo ""
            echo "🌐 Configuration manuelle requise:"
            echo "1. Accédez à: $KEYCLOAK_URL/admin"
            echo "2. Connectez-vous avec: $ADMIN_USER / $ADMIN_PASSWORD"
            echo "3. Sélectionnez le realm '$REALM_NAME'"
            echo "4. Allez dans 'Realm Settings' > 'Themes'"
            echo "5. Configurez:"
            echo "   - Login theme: $THEME_NAME"
            echo "   - Email theme: $THEME_NAME"
            echo "6. Cliquez sur 'Save'"
            exit 1
        fi
    fi
    
    # Configurer le thème
    if configure_theme "$ADMIN_TOKEN"; then
        # Vérifier la configuration
        verify_theme "$ADMIN_TOKEN"
        
        echo ""
        echo "🎉 Configuration du thème terminée!"
        echo "🌐 Testez la page de connexion: $KEYCLOAK_URL/realms/$REALM_NAME/account"
    else
        echo "❌ Erreur lors de la configuration du thème"
        exit 1
    fi
}

# Exécuter le script principal
main "$@"
