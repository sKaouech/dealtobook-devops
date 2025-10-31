# 🐛 Erreurs CI/CD et Solutions

Guide des erreurs rencontrées lors de la mise en place de la CI/CD et leurs solutions.

## 📋 Table des Matières

1. [Erreur: Invalid workflow file - env.SERVICE_NAME](#erreur-1)
2. [Erreur: docker tag requires 2 arguments](#erreur-2)
3. [Workflow ne démarre pas manuellement](#erreur-3)
4. [Permission denied: push to GHCR](#erreur-4)

---

## Erreur 1: Invalid workflow file - env.SERVICE_NAME {#erreur-1}

### 🐛 Symptôme

```
Invalid workflow file: .github/workflows/build-and-push.yml#L1
(Line: 34, Col: 11): Unrecognized named-value: 'env'. 
Located at position 1 within expression: env.SERVICE_NAME
```

Le workflow échoue immédiatement sans même démarrer.

### 🔍 Cause

GitHub Actions **ne permet pas** d'utiliser les variables d'environnement (`env`) dans certains contextes, notamment :
- Le nom du job (`jobs.*.name`)
- Les conditions au niveau job (`jobs.*.if`)

### ✅ Solution

**Avant ❌:**
```yaml
jobs:
  build-and-push:
    name: Build ${{ env.SERVICE_NAME }}  # ❌ INTERDIT
    runs-on: ubuntu-latest
```

**Après ✅:**
```yaml
jobs:
  build-and-push:
    name: Build and Push Docker Image  # ✅ OK
    runs-on: ubuntu-latest
```

**Alternative avec contexte GitHub:**
```yaml
jobs:
  build-and-push:
    name: Build - ${{ github.ref_name }}  # ✅ OK aussi
    runs-on: ubuntu-latest
```

### 📚 Où peut-on utiliser `env` ?

**✅ Autorisé:**
- Dans les steps : `${{ env.VAR }}`
- Dans les commandes shell : `echo ${{ env.VAR }}`
- Dans les conditions au niveau step : `if: env.VAR == 'value'`

**❌ Interdit:**
- Nom du job : `jobs.*.name`
- Conditions au niveau job : `jobs.*.if`
- Certains champs de configuration

### 🔗 Références

- [GitHub Actions: Contexts](https://docs.github.com/en/actions/learn-github-actions/contexts)
- [GitHub Actions: Environment variables](https://docs.github.com/en/actions/learn-github-actions/variables)

---

## Erreur 2: docker tag requires 2 arguments {#erreur-2}

### 🐛 Symptôme

```
Local image: 
docker: 'docker tag' requires 2 arguments
Usage:  docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
Error: Process completed with exit code 1.
```

Le workflow échoue lors du tagging des images Docker.

### 🔍 Cause

Le script utilise `grep` pour trouver l'image buildée par Jib :

```bash
LOCAL_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "^(deal)" | head -n1)
```

**Problème:** Jib crée une image avec le nom **complet** depuis le `pom.xml` :
```xml
<to>
    <image>ghcr.io/skaouech/dealsetting:latest</image>
</to>
```

L'image créée est `ghcr.io/skaouech/dealsetting:latest`, qui **ne commence pas** par "deal", donc le `grep ^(deal)` ne la trouve pas.

Résultat : `LOCAL_IMAGE` est vide → `docker tag` échoue.

### ✅ Solution

Utiliser directement le nom de l'image depuis les variables d'environnement au lieu de chercher avec `grep`.

**Avant ❌:**
```yaml
- name: 🏷️ Tag Docker Images
  run: |
    # Chercher l'image avec grep
    LOCAL_IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "^(deal)" | head -n1)
    echo "Local image: $LOCAL_IMAGE"
    
    docker tag $LOCAL_IMAGE ${{ env.GHCR_IMAGE }}:${{ steps.tag.outputs.tag }}
```

**Après ✅:**
```yaml
- name: 🏷️ Tag Docker Images
  run: |
    # Utiliser directement l'image GHCR depuis la config Jib
    LOCAL_IMAGE="${{ env.GHCR_IMAGE }}:latest"
    echo "🔍 Image locale utilisée: $LOCAL_IMAGE"
    
    # Lister les images pour debug
    echo "📦 Images Docker disponibles:"
    docker images | head -5
    
    # Tag avec le tag déterminé (develop, latest, etc.)
    if [ "${{ steps.tag.outputs.tag }}" != "latest" ]; then
      echo "🏷️  Tag: ${{ steps.tag.outputs.tag }}"
      docker tag $LOCAL_IMAGE ${{ env.GHCR_IMAGE }}:${{ steps.tag.outputs.tag }}
    fi
    
    # Tag avec le SHA pour traçabilité
    echo "🏷️  Tag SHA: sha-${{ github.sha }}"
    docker tag $LOCAL_IMAGE ${{ env.GHCR_IMAGE }}:sha-${{ github.sha }}
    
    # Tag avec la branche
    BRANCH_TAG=$(echo "${{ github.ref_name }}" | sed 's/\//-/g')
    if [ "$BRANCH_TAG" != "latest" ]; then
      echo "🏷️  Tag branche: $BRANCH_TAG"
      docker tag $LOCAL_IMAGE ${{ env.GHCR_IMAGE }}:$BRANCH_TAG
    fi
```

### 💡 Avantages de cette solution

1. **Plus fiable** : Pas besoin de deviner le nom de l'image
2. **Plus simple** : Une seule source de vérité (`GHCR_IMAGE`)
3. **Debug facile** : Affichage des images disponibles
4. **Évite duplications** : Conditions pour éviter de tagger 2 fois le même tag

### 🔗 Liens Utiles

- [Jib Maven Plugin Configuration](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin)
- [Docker Tag Command](https://docs.docker.com/engine/reference/commandline/tag/)

---

## Erreur 3: Workflow ne démarre pas manuellement {#erreur-3}

### 🐛 Symptôme

Vous cliquez sur "Run workflow", mais rien ne se passe. Le workflow n'apparaît pas dans la liste.

### 🔍 Causes Possibles

1. **GitHub Actions désactivé**
2. **Permissions insuffisantes**
3. **Workflow absent de la branche sélectionnée**
4. **Page non rafraîchie**
5. **Syntaxe YAML invalide**

### ✅ Solutions

#### Solution 1: Vérifier les Permissions GitHub

```
1. Allez sur: GitHub > Repo > Settings > Actions > General

2. Section "Actions permissions":
   ✅ Sélectionnez: "Allow all actions and reusable workflows"

3. Section "Workflow permissions":
   ✅ Sélectionnez: "Read and write permissions"
   ✅ Cochez: "Allow GitHub Actions to create and approve pull requests"

4. Cliquez sur "Save"
```

#### Solution 2: Vérifier que le Workflow Existe sur la Branche

```bash
cd dealtobook-deal_setting
git checkout develop
git pull
ls -la .github/workflows/build-and-push.yml
```

Si le fichier n'existe pas:
```bash
# Copier depuis main
git checkout main -- .github/workflows/build-and-push.yml
git add .github/workflows/build-and-push.yml
git commit -m "feat: add workflow to develop"
git push origin develop
```

#### Solution 3: Rafraîchir la Page

Après avoir cliqué sur "Run workflow":
1. **ATTENDEZ 5-10 secondes**
2. **RAFRAÎCHISSEZ** la page (F5 ou Ctrl+R)
3. Le run devrait maintenant apparaître

#### Solution 4: Vérifier la Syntaxe YAML

Utilisez le script de diagnostic:
```bash
cd /path/to/workspace
./dealtobook-devops/scripts/tools/check-workflow-status.sh dealtobook-deal_setting
```

### 📋 Checklist de Vérification

- [ ] GitHub Actions activé
- [ ] Workflow permissions: "Read and write"
- [ ] Fichier `.github/workflows/build-and-push.yml` existe sur la branche
- [ ] Fichier `mvnw` est exécutable
- [ ] Syntaxe YAML valide
- [ ] Page rafraîchie après clic

### 🔗 Documentation

Voir le guide complet: [TROUBLESHOOTING-WORKFLOW-MANUAL.md](./TROUBLESHOOTING-WORKFLOW-MANUAL.md)

---

## Erreur 4: Permission denied: push to GHCR {#erreur-4}

### 🐛 Symptôme

```
Error: failed to push image
denied: permission_denied: write_package
requested access to the resource is denied
```

Le build réussit mais le push vers GitHub Container Registry échoue.

### 🔍 Cause

Les permissions du workflow ne permettent pas d'écrire des packages (images Docker) vers GHCR.

### ✅ Solution

**Étape 1: Vérifier les Workflow Permissions**

```
1. GitHub > Repo > Settings > Actions > General
2. Section "Workflow permissions"
3. ✅ Sélectionnez: "Read and write permissions"
4. Cliquez sur "Save"
```

**Étape 2: Vérifier le Package Visibility**

Si l'image existe déjà dans GHCR mais est privée:

```
1. Allez sur: https://github.com/USERNAME?tab=packages
2. Cliquez sur votre image (ex: dealsetting)
3. Package settings > Change visibility
4. Sélectionnez "Public" (ou ajustez les permissions)
5. Confirmez
```

**Étape 3: Vérifier le Login GHCR dans le Workflow**

Le workflow doit avoir cette étape **AVANT** le push:

```yaml
- name: 🔐 Login to GitHub Container Registry
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}  # ✅ GITHUB_TOKEN auto-fourni
```

### 💡 Note Importante

`GITHUB_TOKEN` est **automatiquement fourni** par GitHub Actions. Vous n'avez **pas besoin** de créer ce secret manuellement.

Cependant, ses permissions dépendent des "Workflow permissions" configurées dans Settings > Actions > General.

### 🔗 Références

- [GitHub Container Registry Authentication](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GITHUB_TOKEN Permissions](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)

---

## 🛠️ Outils de Diagnostic

### Script de Diagnostic Automatique

```bash
cd /path/to/workspace
./dealtobook-devops/scripts/tools/check-workflow-status.sh <service-name>
```

Ce script vérifie automatiquement:
- ✅ Présence du workflow sur `develop` et `main`
- ✅ Fichiers requis (pom.xml, mvnw, etc.)
- ✅ Permissions mvnw
- ✅ Configuration Maven (profil prod, Jib plugin)
- ✅ Syntaxe YAML (si Python/yaml disponible)

### Vérification Manuelle

```bash
# Vérifier que le workflow existe
ls -la .github/workflows/build-and-push.yml

# Vérifier que mvnw est exécutable
ls -l mvnw | grep "rwx"

# Vérifier la syntaxe YAML (si Python installé)
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/build-and-push.yml'))"

# Voir les derniers commits
git log --oneline -5 .github/workflows/build-and-push.yml
```

---

## 📚 Documentation Associée

- [PROCESS-COMPLET-CICD.md](./PROCESS-COMPLET-CICD.md) - Vue d'ensemble complète du processus CI/CD
- [TROUBLESHOOTING-WORKFLOW-MANUAL.md](./TROUBLESHOOTING-WORKFLOW-MANUAL.md) - Guide détaillé de troubleshooting
- [GITHUB-SECRETS-SETUP.md](./GITHUB-SECRETS-SETUP.md) - Configuration des secrets GitHub

---

## 🎓 Leçons Apprises

### 1. Limites de GitHub Actions

- Les variables `env` ne peuvent pas être utilisées partout
- Toujours vérifier la documentation pour les contextes disponibles

### 2. Jib Maven Plugin

- Jib crée des images avec le nom **complet** depuis `pom.xml`
- Ne pas utiliser de `grep` fragile pour trouver les images
- Utiliser les variables d'environnement comme source de vérité

### 3. Permissions GHCR

- `GITHUB_TOKEN` est automatique mais ses permissions dépendent des settings
- Toujours vérifier "Workflow permissions" dans Settings > Actions
- "Read and write permissions" est requis pour push vers GHCR

### 4. Debugging

- Ajouter des `echo` pour voir les valeurs des variables
- Lister les images Docker disponibles avec `docker images`
- Ne pas hésiter à afficher le contexte pour comprendre les erreurs

---

**Version:** 1.0  
**Date:** 2025-10-31  
**Auteur:** DevOps Team  
**Status:** ✅ Testé et validé

