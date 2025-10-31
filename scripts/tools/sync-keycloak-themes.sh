#!/bin/bash
# Script pour synchroniser les fichiers keycloak-themes locaux vers le serveur

HOSTINGER_IP="${HOSTINGER_IP:-148.230.114.13}"
PROJECT_NAME="${PROJECT_NAME:-dealtobook-dev}"
CONFIG_DIR="$(cd "$(dirname "$0")/../../config" && pwd)"
THEMES_DIR="${CONFIG_DIR}/keycloak-themes"

if [ ! -d "$THEMES_DIR" ]; then
    echo "❌ Répertoire $THEMES_DIR non trouvé"
    exit 1
fi

echo "🔄 Synchronisation des thèmes Keycloak vers le serveur..."
echo ""
echo "📍 Source locale: $THEMES_DIR"
echo "📍 Destination serveur: root@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/keycloak-themes"
echo ""

# Vérifier les fichiers modifiés récemment
echo "📋 Fichiers modifiés récemment (dernières 24h):"
find "$THEMES_DIR" -type f -mtime -1 -ls | head -10 || echo "Aucun fichier modifié récemment"
echo ""

# Synchroniser les fichiers
echo "📤 Synchronisation en cours..."
rsync -avz --delete \
    -e "ssh -o StrictHostKeyChecking=no" \
    "${THEMES_DIR}/" \
    "root@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/keycloak-themes/" \
    || {
    echo "⚠️  rsync non disponible, utilisation de scp..."
    scp -r -o StrictHostKeyChecking=no "${THEMES_DIR}/" "root@${HOSTINGER_IP}:/opt/${PROJECT_NAME}/" || {
        echo "❌ Échec du transfert"
        exit 1
    }
}

echo ""
echo "✅ Fichiers synchronisés!"
echo ""

# Vérifier que le fichier spécifique existe sur le serveur
if [ -n "$1" ]; then
    echo "🔍 Vérification du fichier: $1"
    ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "test -f /opt/${PROJECT_NAME}/keycloak-themes/$1 && echo '✅ Fichier présent' || echo '❌ Fichier absent'"
fi

# Vérifier dans le conteneur
echo ""
echo "🔍 Vérification dans le conteneur Keycloak..."
ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "docker exec dealtobook-keycloak test -f /opt/keycloak/themes/dealtobook/login/template.ftl && echo '✅ template.ftl présent dans le conteneur' || echo '❌ template.ftl absent'"

echo ""
echo "⚠️  IMPORTANT: Redémarrer Keycloak pour prendre en compte les changements:"
echo "   ssh root@${HOSTINGER_IP} 'docker restart dealtobook-keycloak'"
echo ""
echo "Voulez-vous redémarrer Keycloak maintenant? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo "🔄 Redémarrage de Keycloak..."
    ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "docker restart dealtobook-keycloak"
    echo "✅ Keycloak redémarré!"
    echo "⏳ Attente de 30 secondes..."
    sleep 30
    echo "✅ Keycloak devrait être redémarré et le thème rechargé"
fi

