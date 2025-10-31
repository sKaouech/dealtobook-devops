#!/bin/bash
# Script pour vérifier que Keycloak utilise bien le thème et forcer le rechargement si nécessaire

set -e

HOSTINGER_IP="${HOSTINGER_IP:-148.230.114.13}"
CONTAINER_NAME="dealtobook-keycloak"
KEYCLOAK_URL="${KEYCLOAK_URL:-https://keycloak-dev.dealtobook.com}"
ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-admin123}"
REALM_NAME="dealtobook"
THEME_NAME="dealtobook"
THEME_PATH="/opt/keycloak/themes/dealtobook"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

error() {
    echo -e "${RED}❌${NC} $1"
}

# Fonction pour obtenir le token admin
get_admin_token() {
    log "Authentification admin..."
    local token=$(curl -k -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=$ADMIN_USER" \
        -d "password=$ADMIN_PASSWORD" \
        -d "grant_type=password" \
        -d "client_id=admin-cli" | jq -r ".access_token // empty" 2>/dev/null)
    
    if [ -n "$token" ] && [ "$token" != "null" ] && [ "$token" != "empty" ]; then
        echo "$token"
    else
        error "Impossible d'obtenir le token admin"
        return 1
    fi
}

# Vérifier que le volume est monté
check_volume_mounted() {
    log "Vérification du montage du volume..."
    
    ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "
        docker exec ${CONTAINER_NAME} test -d ${THEME_PATH}/login && \
            echo 'login' || echo 'NOT_MOUNTED'
        docker exec ${CONTAINER_NAME} test -d ${THEME_PATH}/email && \
            echo 'email' || echo 'NOT_MOUNTED'
    " | while read result; do
        if [ "$result" = "login" ]; then
            success "Thème login monté"
        elif [ "$result" = "email" ]; then
            success "Thème email monté"
        elif [ "$result" = "NOT_MOUNTED" ]; then
            error "Thème non monté!"
            return 1
        fi
    done
}

# Vérifier la configuration du thème dans le realm
check_theme_configuration() {
    local token=$1
    
    log "Vérification de la configuration du thème dans le realm..."
    
    local realm_config=$(curl -k -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token")
    
    local login_theme=$(echo "$realm_config" | jq -r ".loginTheme // empty" 2>/dev/null)
    local email_theme=$(echo "$realm_config" | jq -r ".emailTheme // empty" 2>/dev/null)
    
    echo ""
    log "Configuration actuelle:"
    echo "  Login theme: ${login_theme:-'non configuré'}"
    echo "  Email theme: ${email_theme:-'non configuré'}"
    echo ""
    
    if [ "$login_theme" = "$THEME_NAME" ] && [ "$email_theme" = "$THEME_NAME" ]; then
        success "Thème correctement configuré dans le realm"
        return 0
    else
        warning "Thème non configuré ou incorrect dans le realm"
        echo ""
        echo "Voulez-vous configurer le thème automatiquement? (y/n)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            configure_theme "$token"
        else
            warning "Configuration manuelle requise:"
            echo "  1. Accédez à: $KEYCLOAK_URL/admin"
            echo "  2. Realm Settings > Themes"
            echo "  3. Login theme: $THEME_NAME"
            echo "  4. Email theme: $THEME_NAME"
            echo "  5. Save"
        fi
        return 1
    fi
}

# Configurer le thème
configure_theme() {
    local token=$1
    
    log "Configuration du thème $THEME_NAME pour le realm $REALM_NAME..."
    
    local current_config=$(curl -k -s -X GET "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token")
    
    local updated_config=$(echo "$current_config" | jq ".loginTheme = \"$THEME_NAME\" | .emailTheme = \"$THEME_NAME\"")
    
    local http_code=$(curl -k -s -w "%{http_code}" -o /dev/null -X PUT "$KEYCLOAK_URL/admin/realms/$REALM_NAME" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "$updated_config")
    
    if [ "$http_code" = "204" ] || [ "$http_code" = "200" ]; then
        success "Thème configuré avec succès!"
        return 0
    else
        error "Erreur lors de la configuration (HTTP $http_code)"
        return 1
    fi
}

# Forcer le rechargement du thème
force_reload_theme() {
    log "Forçage du rechargement du thème..."
    
    # Option 1: Toucher TOUS les fichiers du thème pour forcer le rechargement
    log "Touching ALL theme files to force reload..."
    ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "
        # Toucher tous les fichiers dans les dossiers login et email (boucle shell native)
        docker exec ${CONTAINER_NAME} sh -c '
            for file in ${THEME_PATH}/login/**/* ${THEME_PATH}/login/*; do
                [ -f \"\$file\" ] && touch \"\$file\" 2>/dev/null
            done
        '
        docker exec ${CONTAINER_NAME} sh -c '
            for file in ${THEME_PATH}/email/**/* ${THEME_PATH}/email/*; do
                [ -f \"\$file\" ] && touch \"\$file\" 2>/dev/null
            done
        '
        echo 'All theme files touched'
    " && success "Tous les fichiers du thème ont été touchés (FTL, CSS, JS, images, etc.)"
    
    # Option 2: Redémarrer Keycloak (plus efficace mais downtime)
    echo ""
    warning "Pour un rechargement complet, vous devez redémarrer Keycloak:"
    echo "  ssh root@${HOSTINGER_IP} 'docker restart ${CONTAINER_NAME}'"
    echo ""
    echo "Voulez-vous redémarrer Keycloak maintenant? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log "Redémarrage de Keycloak..."
        ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "docker restart ${CONTAINER_NAME}"
        success "Keycloak redémarré. Attente de 30 secondes..."
        sleep 30
        success "Keycloak devrait être redémarré"
    fi
}

# Fonction pour toucher tous les fichiers du thème (commande standalone)
touch_all_theme_files() {
    log "Toucher tous les fichiers du thème..."
    ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "
        docker exec ${CONTAINER_NAME} sh -c '
            for file in ${THEME_PATH}/login/**/* ${THEME_PATH}/login/*; do
                [ -f \"\$file\" ] && touch \"\$file\" 2>/dev/null
            done
        '
        docker exec ${CONTAINER_NAME} sh -c '
            for file in ${THEME_PATH}/email/**/* ${THEME_PATH}/email/*; do
                [ -f \"\$file\" ] && touch \"\$file\" 2>/dev/null
            done
        '
    " && success "Tous les fichiers du thème ont été touchés"
}

# Vérifier si les fichiers locaux diffèrent du serveur
check_file_differences() {
    log "Vérification des différences entre fichiers locaux et serveur..."
    
    # Comparer theme.properties
    local local_file="dealtobook-devops/config/keycloak-themes/dealtobook/login/theme.properties"
    if [ -f "$local_file" ]; then
        local local_hash=$(md5sum "$local_file" 2>/dev/null | cut -d' ' -f1 || md5 -q "$local_file" 2>/dev/null)
        local remote_hash=$(ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} \
            "docker exec ${CONTAINER_NAME} md5sum ${THEME_PATH}/login/theme.properties" 2>/dev/null | cut -d' ' -f1)
        
        if [ "$local_hash" != "$remote_hash" ]; then
            warning "Fichiers theme.properties diffèrent entre local et serveur"
            echo "  Local:  $local_hash"
            echo "  Remote: $remote_hash"
            echo ""
            echo "Voulez-vous synchroniser? (y/n)"
            read -r response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                log "Synchronisation des fichiers..."
                ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "
                    docker exec ${CONTAINER_NAME} touch ${THEME_PATH}/login/theme.properties
                "
                success "Fichiers synchronisés"
            fi
        else
            success "Fichiers synchronisés"
        fi
    fi
}

# Main
main() {
    echo "🎨 Vérification et rechargement du thème Keycloak"
    echo "=================================================="
    echo ""
    
    # 1. Vérifier le volume
    check_volume_mounted || exit 1
    
    # 2. Obtenir le token
    TOKEN=$(get_admin_token) || exit 1
    
    # 3. Vérifier la configuration
    check_theme_configuration "$TOKEN"
    
    # 4. Vérifier les différences
    echo ""
    check_file_differences
    
    # 5. Proposer le rechargement
    echo ""
    echo "Voulez-vous forcer le rechargement du thème? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        force_reload_theme
    fi
    
    echo ""
    success "Vérification terminée!"
    echo ""
    log "Pour tester le thème, accédez à:"
    echo "  $KEYCLOAK_URL/realms/$REALM_NAME/account"
}

# Exécution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi

