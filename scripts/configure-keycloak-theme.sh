#!/bin/bash

# Script pour configurer le thème Keycloak dealtobook
# Usage: ./configure-keycloak-theme.sh

set -e

KEYCLOAK_URL="https://keycloak-dev.dealtobook.com"
ADMIN_USER="admin"
ADMIN_PASSWORD="DealToBook2024AdminSecure!"
REALM_NAME="dealtobook"
THEME_NAME="dealtobook"

echo "🎨 Configuration du thème Keycloak dealtobook..."
echo ""

# Fonction pour obtenir le token admin
get_admin_token() {
    local token=$(curl -k -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=$ADMIN_USER" \
        -d "password=$ADMIN_PASSWORD" \
        -d "grant_type=password" \
        -d "client_id=admin-cli" | jq -r ".access_token // empty")
    
    if [ -n "$token" ] && [ "$token" != "null" ] && [ "$token" != "empty" ]; then
        echo "$token"
    else
        return 1
    fi
}

# Fonction pour configurer le thème
configure_theme() {
    local token=$1
    
    echo "=== Configuration du thème $THEME_NAME pour le realm $REALM_NAME ==="
    
    # Obtenir la configuration actuelle du realm
    local current_config=$(curl -k -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token")
    
    # Mettre à jour avec les thèmes
    local updated_config=$(echo "$current_config" | jq ".loginTheme = \"$THEME_NAME\" | .emailTheme = \"$THEME_NAME\"")
    
    # Appliquer la configuration
    curl -k -s -X PUT "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "$updated_config"
    
    echo "✅ Thème configuré avec succès!"
}

# Fonction pour vérifier la configuration
verify_theme() {
    local token=$1
    
    echo "=== Vérification de la configuration ==="
    local themes=$(curl -k -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token" | jq -r ".loginTheme, .emailTheme")
    
    echo "Thèmes configurés: $themes"
}

# Script principal
main() {
    echo "🔍 Tentative d'obtention du token admin..."
    
    # Essayer plusieurs fois d'obtenir le token
    for i in {1..5}; do
        if ADMIN_TOKEN=$(get_admin_token); then
            echo "✅ Token admin obtenu (tentative $i)"
            break
        else
            echo "❌ Échec de l'obtention du token (tentative $i/5)"
            if [ $i -eq 5 ]; then
                echo ""
                echo "❌ Impossible d'obtenir le token admin après 5 tentatives"
                echo ""
                echo "🌐 Configuration manuelle requise:"
                echo "1. Accédez à: $KEYCLOAK_URL"
                echo "2. Connectez-vous avec: $ADMIN_USER / $ADMIN_PASSWORD"
                echo "3. Sélectionnez le realm '$REALM_NAME'"
                echo "4. Allez dans 'Realm Settings' > 'Themes'"
                echo "5. Configurez:"
                echo "   - Login theme: $THEME_NAME"
                echo "   - Email theme: $THEME_NAME"
                echo "6. Cliquez sur 'Save'"
                exit 1
            fi
            sleep 10
        fi
    done
    
    # Configurer le thème
    configure_theme "$ADMIN_TOKEN"
    
    # Vérifier la configuration
    verify_theme "$ADMIN_TOKEN"
    
    echo ""
    echo "🎉 Configuration du thème terminée!"
    echo "🌐 Testez la page de connexion: $KEYCLOAK_URL/realms/$REALM_NAME/account"
}

# Exécuter le script principal
main "$@"
