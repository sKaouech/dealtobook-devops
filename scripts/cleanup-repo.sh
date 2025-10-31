#!/bin/bash

# Script de nettoyage automatique du repo dealtobook-devops
# Supprime les fichiers obsolètes de manière sécurisée

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🧹 NETTOYAGE DU REPOSITORY DEALTOBOOK-DEVOPS                ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour supprimer en sécurité
safe_remove() {
    local file="$1"
    if [ -e "$file" ]; then
        echo -e "${GREEN}✓${NC} Suppression: $file"
        rm -rf "$file"
    else
        echo -e "${YELLOW}⊘${NC} Déjà supprimé: $file"
    fi
}

# Demander confirmation
echo "Ce script va supprimer les fichiers obsolètes suivants:"
echo ""
echo "📁 Scripts Legacy:"
echo "   - scripts/legacy/ (5 fichiers)"
echo ""
echo "📁 Doublons dans tools/:"
echo "   - scripts/tools/init-multiple-databases.sh"
echo "   - scripts/tools/pg_hba.conf"
echo "   - scripts/tools/postgresql.conf"
echo "   - scripts/tools/configure-keycloak-theme.sh"
echo ""
echo "📁 Documentation obsolète:"
echo "   - docs/CICD-ARCHITECTURE.md"
echo "   - docs/CLEANUP-AND-CICD-PLAN.md"
echo "   - docs/GUIDE-FINALISATION-CICD.md"
echo "   - docs/GUIDE-RELOAD-KEYCLOAK-THEME.md"
echo ""
echo "📁 Fichiers racine:"
echo "   - fix-security-hazelcast.sh"
echo "   - github-workflow-orchestration.yml"
echo "   - ORGANIZATION-COMPLETE.md"
echo "   - dealtobook-devops.iml"
echo ""
echo -e "${YELLOW}⚠️  ATTENTION: Cette action est irréversible!${NC}"
echo ""
read -p "Voulez-vous continuer? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Nettoyage annulé."
    exit 0
fi

echo ""
echo "🚀 Démarrage du nettoyage..."
echo ""

# ============================================
# PHASE 1: Supprimer les scripts legacy
# ============================================
echo "📦 Phase 1: Scripts Legacy"
safe_remove "scripts/legacy"

# ============================================
# PHASE 2: Supprimer les doublons dans tools/
# ============================================
echo ""
echo "📦 Phase 2: Doublons dans tools/"
safe_remove "scripts/tools/init-multiple-databases.sh"
safe_remove "scripts/tools/pg_hba.conf"
safe_remove "scripts/tools/postgresql.conf"
safe_remove "scripts/tools/configure-keycloak-theme.sh"

# ============================================
# PHASE 3: Supprimer docs obsolètes
# ============================================
echo ""
echo "📦 Phase 3: Documentation obsolète"
safe_remove "docs/CICD-ARCHITECTURE.md"
safe_remove "docs/CLEANUP-AND-CICD-PLAN.md"
safe_remove "docs/GUIDE-FINALISATION-CICD.md"
safe_remove "docs/GUIDE-RELOAD-KEYCLOAK-THEME.md"

# ============================================
# PHASE 4: Supprimer fichiers racine obsolètes
# ============================================
echo ""
echo "📦 Phase 4: Fichiers racine"
safe_remove "fix-security-hazelcast.sh"
safe_remove "github-workflow-orchestration.yml"
safe_remove "ORGANIZATION-COMPLETE.md"
safe_remove "dealtobook-devops.iml"

# ============================================
# PHASE 5: Scripts sync (optionnel)
# ============================================
echo ""
echo "📦 Phase 5: Scripts de synchronisation (optionnel)"
echo ""
read -p "Supprimer sync-from-hostinger.sh et sync-to-hostinger.sh? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    safe_remove "sync-from-hostinger.sh"
    safe_remove "sync-to-hostinger.sh"
else
    echo -e "${YELLOW}⊘${NC} Scripts sync conservés"
fi

# ============================================
# PHASE 6: Archives (optionnel)
# ============================================
echo ""
echo "📦 Phase 6: Archives historiques"
echo ""
echo "Le dossier docs/archive/ contient 8 fichiers d'historique."
read -p "Supprimer docs/archive/? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    safe_remove "docs/archive"
else
    echo -e "${YELLOW}⊘${NC} Archives conservées"
fi

# ============================================
# Résumé
# ============================================
echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  ✅ NETTOYAGE TERMINÉ                                         ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Vérification des fichiers restants..."
echo ""

# Vérifier les fichiers importants
echo "✅ Fichiers essentiels présents:"
[ -f "scripts/deploy-ssl-production-v2.sh" ] && echo "   ✓ deploy-ssl-production-v2.sh"
[ -f "config/docker-compose.ssl-complete.yml" ] && echo "   ✓ docker-compose.ssl-complete.yml"
[ -d "config/scripts" ] && echo "   ✓ config/scripts/"
[ -d "docs/cicd" ] && echo "   ✓ docs/cicd/"
[ -d "docs/deployment" ] && echo "   ✓ docs/deployment/"

echo ""
echo "📋 Prochaines étapes:"
echo "   1. Vérifier que tout fonctionne: ./scripts/test-deploy-v2.sh"
echo "   2. Commiter les changements:"
echo "      git add -A"
echo "      git commit -m \"chore: cleanup obsolete files\""
echo "      git push"
echo ""
echo "🎉 Repository nettoyé avec succès!"

