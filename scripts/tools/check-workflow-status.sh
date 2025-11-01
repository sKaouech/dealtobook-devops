#!/bin/bash
set -euo pipefail

# Script pour diagnostiquer les problèmes de workflows GitHub Actions

# Configuration
REPO_NAME="${1:-}"

if [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo-name>"
    echo "Example: $0 dealtobook-deal_setting"
    exit 1
fi

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🔍 Diagnostic Workflow GitHub Actions                       ║"
echo "║  Repo: $REPO_NAME"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Vérifier que le repo existe
if [ ! -d "$REPO_NAME" ]; then
    echo "❌ Erreur: Répertoire $REPO_NAME n'existe pas"
    exit 1
fi

cd "$REPO_NAME"
echo "📂 Répertoire: $(pwd)"
echo ""

# 1. Vérifier la branche actuelle
echo "1️⃣  BRANCHE ACTUELLE"
echo "════════════════════"
CURRENT_BRANCH=$(git branch --show-current)
echo "   Branche actuelle: $CURRENT_BRANCH"
echo ""

# 2. Vérifier si le workflow existe sur develop
echo "2️⃣  WORKFLOW SUR DEVELOP"
echo "═══════════════════════"
git checkout develop 2>/dev/null || {
    echo "   ❌ Branche develop n'existe pas localement"
    echo "   Récupération depuis origin..."
    git fetch origin develop:develop 2>/dev/null || echo "   ❌ Impossible de récupérer develop"
}

if [ -f ".github/workflows/build-and-push.yml" ]; then
    echo "   ✅ Workflow trouvé sur develop"
    echo "   Fichier: .github/workflows/build-and-push.yml"
    
    # Afficher la date du dernier commit
    LAST_COMMIT=$(git log -1 --format="%h - %s (%ar)" -- .github/workflows/build-and-push.yml)
    echo "   Dernier commit: $LAST_COMMIT"
else
    echo "   ❌ Workflow NON trouvé sur develop"
    echo "   Le fichier .github/workflows/build-and-push.yml n'existe pas"
    echo ""
    echo "   🔧 Solution:"
    echo "      git checkout main -- .github/workflows/build-and-push.yml"
    echo "      git add .github/workflows/build-and-push.yml"
    echo "      git commit -m 'feat: add workflow to develop'"
    echo "      git push origin develop"
fi
echo ""

# 3. Vérifier si le workflow existe sur main
echo "3️⃣  WORKFLOW SUR MAIN"
echo "════════════════════"
git checkout main 2>/dev/null || {
    echo "   ❌ Impossible de basculer sur main"
}

if [ -f ".github/workflows/build-and-push.yml" ]; then
    echo "   ✅ Workflow trouvé sur main"
    LAST_COMMIT=$(git log -1 --format="%h - %s (%ar)" -- .github/workflows/build-and-push.yml)
    echo "   Dernier commit: $LAST_COMMIT"
else
    echo "   ❌ Workflow NON trouvé sur main"
fi
echo ""

# 4. Vérifier la syntaxe YAML
echo "4️⃣  SYNTAXE YAML"
echo "═══════════════"
git checkout develop 2>/dev/null || true

if [ -f ".github/workflows/build-and-push.yml" ]; then
    # Test basique de syntaxe YAML
    if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build-and-push.yml'))" 2>/dev/null; then
        echo "   ✅ Syntaxe YAML valide"
    else
        echo "   ⚠️  Impossible de valider la syntaxe (python3/yaml manquant)"
        
        # Vérification basique
        if grep -q "^on:" .github/workflows/build-and-push.yml && \
           grep -q "^jobs:" .github/workflows/build-and-push.yml; then
            echo "   ✅ Structure de base présente (on:, jobs:)"
        else
            echo "   ❌ Structure YAML incorrecte"
        fi
    fi
else
    echo "   ⏭️  Pas de workflow à vérifier"
fi
echo ""

# 5. Vérifier les fichiers nécessaires
echo "5️⃣  FICHIERS REQUIS"
echo "══════════════════"
FILES=("pom.xml" "mvnw" "src/main/java")

for file in "${FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file manquant"
    fi
done
echo ""

# 6. Vérifier mvnw permissions
echo "6️⃣  PERMISSIONS MVNW"
echo "═══════════════════"
if [ -f "mvnw" ]; then
    if [ -x "mvnw" ]; then
        echo "   ✅ mvnw est exécutable"
    else
        echo "   ❌ mvnw n'est PAS exécutable"
        echo "   🔧 Solution: chmod +x mvnw"
    fi
else
    echo "   ❌ mvnw n'existe pas"
fi
echo ""

# 7. Vérifier le profil prod dans pom.xml
echo "7️⃣  PROFIL MAVEN 'prod'"
echo "══════════════════════"
if [ -f "pom.xml" ]; then
    if grep -q "<id>prod</id>" pom.xml; then
        echo "   ✅ Profil 'prod' trouvé dans pom.xml"
    else
        echo "   ⚠️  Profil 'prod' non trouvé dans pom.xml"
        echo "   Le workflow utilise -Pprod, vérifiez que ce profil existe"
    fi
else
    echo "   ❌ pom.xml n'existe pas"
fi
echo ""

# 8. Vérifier Jib plugin
echo "8️⃣  JIB PLUGIN"
echo "═════════════"
if [ -f "pom.xml" ]; then
    if grep -q "jib-maven-plugin" pom.xml; then
        echo "   ✅ Jib plugin configuré dans pom.xml"
    else
        echo "   ❌ Jib plugin NON trouvé dans pom.xml"
        echo "   Le workflow utilise jib:dockerBuild"
    fi
fi
echo ""

# 9. Historique des runs GitHub Actions
echo "9️⃣  DERNIERS COMMITS SUR develop"
echo "═══════════════════════════════"
git checkout develop 2>/dev/null || true
echo "   Derniers commits:"
git log --oneline -5 | sed 's/^/   /'
echo ""

# Résumé
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                        RÉSUMÉ                                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

ISSUES=0

# Check workflow on develop
if [ ! -f ".github/workflows/build-and-push.yml" ]; then
    echo "❌ PROBLÈME: Workflow absent de la branche develop"
    ISSUES=$((ISSUES + 1))
fi

# Check mvnw
if [ ! -x "mvnw" ]; then
    echo "❌ PROBLÈME: mvnw n'est pas exécutable"
    ISSUES=$((ISSUES + 1))
fi

if [ $ISSUES -eq 0 ]; then
    echo "✅ Aucun problème détecté!"
    echo ""
    echo "Si le workflow ne démarre toujours pas:"
    echo "1. Vérifiez sur GitHub: Settings > Actions > General"
    echo "2. Workflow permissions: Read and write"
    echo "3. Actions: Allow all actions"
    echo "4. Après clic sur 'Run workflow', rafraîchissez la page (F5)"
else
    echo "⚠️  $ISSUES problème(s) détecté(s)"
    echo ""
    echo "Suivez les recommandations ci-dessus pour corriger"
fi

echo ""
echo "Pour voir les logs des runs précédents:"
echo "→ Allez sur GitHub Actions et cliquez sur les runs échoués"
echo ""

# Retour à la branche initiale
git checkout "$CURRENT_BRANCH" 2>/dev/null || true

