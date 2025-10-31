#!/bin/bash
# Script rapide pour recharger le thème Keycloak
# NOTE: Le volume est monté en read-only, donc on ne peut pas toucher les fichiers
# La seule solution est de redémarrer Keycloak

HOSTINGER_IP="${HOSTINGER_IP:-148.230.114.13}"
CONTAINER_NAME="dealtobook-keycloak"
THEME_PATH="/opt/keycloak/themes/dealtobook"

echo "🔄 Rechargement du thème Keycloak..."
echo ""
echo "ℹ️  Le volume est monté en read-only (pour la sécurité)"
echo "   La seule façon de forcer le rechargement est de redémarrer Keycloak"
echo ""

# Compter les fichiers pour info
echo "📊 Nombre de fichiers dans le thème:"
login_total=$(ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "docker exec ${CONTAINER_NAME} sh << 'EOF'
count=0
count_all() {
    dir=\$1
    [ ! -d \"\$dir\" ] && return
    for item in \${dir}/* \${dir}/.*; do
        if [ ! -e \"\$item\" ] || [ \"\$(basename \"\$item\")\" = \".\" ] || [ \"\$(basename \"\$item\")\" = \"..\" ]; then
            continue
        fi
        if [ -f \"\$item\" ]; then
            count=\$((count + 1))
        elif [ -d \"\$item\" ]; then
            count_all \"\$item\"
        fi
    done
}
count_all \"${THEME_PATH}/login\"
echo \$count
EOF
" 2>/dev/null || echo "0")

email_total=$(ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "docker exec ${CONTAINER_NAME} sh << 'EOF'
count=0
count_all() {
    dir=\$1
    [ ! -d \"\$dir\" ] && return
    for item in \${dir}/* \${dir}/.*; do
        if [ ! -e \"\$item\" ] || [ \"\$(basename \"\$item\")\" = \".\" ] || [ \"\$(basename \"\$item\")\" = \"..\" ]; then
            continue
        fi
        if [ -f \"\$item\" ]; then
            count=\$((count + 1))
        elif [ -d \"\$item\" ]; then
            count_all \"\$item\"
        fi
    done
}
count_all \"${THEME_PATH}/email\"
echo \$count
EOF
" 2>/dev/null || echo "0")

echo "  Login: ${login_total} fichiers"
echo "  Email: ${email_total} fichiers"
echo ""

# Proposer de redémarrer
echo "Voulez-vous redémarrer Keycloak maintenant pour recharger le thème? (y/n)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo "🔄 Redémarrage de Keycloak..."
    ssh -o StrictHostKeyChecking=no root@${HOSTINGER_IP} "docker restart ${CONTAINER_NAME}"
    echo "✅ Keycloak redémarré!"
    echo ""
    echo "⏳ Attente de 30 secondes pour que Keycloak redémarre complètement..."
    sleep 30
    echo "✅ Keycloak devrait être redémarré et le thème rechargé"
else
    echo ""
    echo "Pour recharger le thème manuellement, exécutez:"
    echo "  ssh root@${HOSTINGER_IP} 'docker restart ${CONTAINER_NAME}'"
fi
