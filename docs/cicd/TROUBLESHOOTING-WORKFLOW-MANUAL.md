# 🔧 Troubleshooting: Workflow Manuel ne Démarre Pas

Guide pour résoudre le problème "Je clique sur Run workflow mais rien ne se passe"

## 🎯 Symptôme

- Vous allez sur GitHub Actions
- Vous cliquez sur "Run workflow"
- Vous sélectionnez la branche et les paramètres
- Vous cliquez sur le bouton vert "Run workflow"
- **Rien ne se passe** ou **Le workflow n'apparaît pas**

## ✅ Diagnostic Automatique

Utilisez le script de diagnostic :

```bash
cd /Users/seyfkaoueche/Documents/work/project/dealtobook/workspace
./dealtobook-devops/scripts/tools/check-workflow-status.sh dealtobook-deal_setting
```

Ce script vérifie automatiquement :
- ✅ Présence du workflow sur `develop` et `main`
- ✅ Fichiers requis (pom.xml, mvnw, etc.)
- ✅ Permissions mvnw
- ✅ Configuration Maven (profil prod, Jib plugin)
- ✅ Syntaxe YAML

## 🔍 Causes Possibles & Solutions

### 1️⃣ Permissions GitHub Actions Désactivées

**Symptôme:** Le workflow ne démarre jamais, même après plusieurs tentatives.

**Vérification:**
```
1. Allez sur GitHub.com
2. Votre repo > Settings > Actions > General
3. Section "Actions permissions"
```

**Solution:**
- ✅ Sélectionnez: **"Allow all actions and reusable workflows"**
- ❌ Ne pas sélectionner: "Disable actions"

---

### 2️⃣ Workflow Permissions Insuffisantes

**Symptôme:** Le workflow démarre mais échoue lors du push vers GHCR avec une erreur de permission.

**Erreur typique:**
```
Error: failed to push image: Permission denied
denied: permission_denied: write_package
```

**Vérification:**
```
1. Settings > Actions > General
2. Section "Workflow permissions"
```

**Solution:**
- ✅ Sélectionnez: **"Read and write permissions"**
- ✅ Cochez: **"Allow GitHub Actions to create and approve pull requests"**
- ❌ Ne pas sélectionner: "Read repository contents and packages permissions"

**Puis cliquez sur "Save"**

---

### 3️⃣ Workflow Absent de la Branche Sélectionnée

**Symptôme:** Vous sélectionnez "Branch: develop" mais le workflow ne démarre pas.

**Cause:** Le fichier `.github/workflows/build-and-push.yml` n'existe pas sur la branche `develop`.

**Vérification:**
```bash
cd dealtobook-deal_setting
git checkout develop
git pull
ls -la .github/workflows/build-and-push.yml
```

**Solution si absent:**
```bash
# Copier le workflow depuis main
git checkout develop
git checkout main -- .github/workflows/build-and-push.yml
git add .github/workflows/build-and-push.yml
git commit -m "feat: add CI/CD workflow to develop"
git push origin develop
```

---

### 4️⃣ Vous N'Avez Pas Rafraîchi la Page

**Symptôme:** Le workflow démarre mais n'apparaît pas immédiatement.

**Solution:**
1. Cliquez sur "Run workflow"
2. **ATTENDEZ 5-10 secondes**
3. **RAFRAÎCHISSEZ la page** (F5 ou Ctrl+R)
4. Le run devrait maintenant apparaître en haut de la liste

---

### 5️⃣ Syntaxe YAML Invalide

**Symptôme:** Le workflow n'apparaît pas du tout dans la liste des workflows.

**Vérification:**
```bash
cd dealtobook-deal_setting

# Vérifier que le fichier existe
cat .github/workflows/build-and-push.yml

# Vérifier la syntaxe basique
grep "^on:" .github/workflows/build-and-push.yml
grep "^jobs:" .github/workflows/build-and-push.yml
grep "workflow_dispatch:" .github/workflows/build-and-push.yml
```

**Solution si invalide:**
- Utilisez un validateur YAML en ligne : https://www.yamllint.com/
- Ou réutilisez le template correct depuis `dealtobook-devops/docs/cicd/workflow-per-service/backend-build-template.yml`

---

## 📊 Procédure Complète de Vérification

### Étape 1: Vérifier les Permissions GitHub

```
1. https://github.com/skaouech/dealtobook-deal_setting/settings/actions
2. Actions permissions: "Allow all actions and reusable workflows" ✅
3. Workflow permissions: "Read and write permissions" ✅
4. Cliquez sur "Save"
```

### Étape 2: Vérifier que le Workflow Existe

```bash
cd dealtobook-deal_setting
git checkout develop
git pull
ls -la .github/workflows/build-and-push.yml
```

Si le fichier n'existe pas, copiez-le depuis `main` :

```bash
git checkout main -- .github/workflows/build-and-push.yml
git add .github/workflows/build-and-push.yml
git commit -m "feat: add workflow to develop"
git push origin develop
```

### Étape 3: Tester le Workflow Manuellement

```
1. Allez sur: https://github.com/skaouech/dealtobook-deal_setting/actions
2. Cliquez sur "build-and-push.yml" dans la liste de gauche
3. Cliquez sur "Run workflow" (bouton en haut à droite)
4. Sélectionnez:
   - Branch: develop
   - Tag: develop (ou laissez par défaut)
5. Cliquez sur le bouton VERT "Run workflow"
6. ATTENDEZ 5 secondes
7. RAFRAÎCHISSEZ la page (F5)
8. Le nouveau run devrait apparaître avec un cercle jaune (en cours)
```

### Étape 4: Tester le Workflow Automatique

```bash
cd dealtobook-deal_setting
git checkout develop

# Faire un petit changement
echo "# Test CI/CD" >> README.md
git add README.md
git commit -m "test: trigger CI/CD pipeline"
git push origin develop
```

Puis allez sur GitHub Actions - le workflow devrait démarrer automatiquement !

---

## 🐛 Déboguer un Workflow qui Échoue

Si le workflow **démarre** mais **échoue**, voici comment voir les logs :

### Voir les Logs d'un Run Échoué

```
1. GitHub Actions > Cliquez sur le run rouge (❌)
2. Cliquez sur le job "build-and-push"
3. Cliquez sur chaque étape pour voir les logs
4. Identifiez l'erreur
```

### Erreurs Communes

#### ❌ "mvnw: Permission denied"

**Erreur:**
```
./mvnw: Permission denied
```

**Solution:**
```bash
chmod +x mvnw
git add mvnw
git commit -m "fix: make mvnw executable"
git push
```

#### ❌ "Profile 'prod' not found"

**Erreur:**
```
[ERROR] The requested profile "prod" could not be activated because it does not exist
```

**Solution:**
- Vérifiez que le profil `prod` existe dans `pom.xml`
- Ou changez `MAVEN_PROFILE: prod` en `MAVEN_PROFILE: dev` dans le workflow

#### ❌ "jib-maven-plugin not found"

**Erreur:**
```
[ERROR] Plugin com.google.cloud.tools:jib-maven-plugin not found
```

**Solution:**
Ajoutez Jib plugin dans `pom.xml` :

```xml
<build>
  <plugins>
    <plugin>
      <groupId>com.google.cloud.tools</groupId>
      <artifactId>jib-maven-plugin</artifactId>
      <version>3.4.0</version>
      <configuration>
        <from>
          <image>eclipse-temurin:17-jre</image>
        </from>
        <to>
          <image>ghcr.io/skaouech/dealsetting</image>
        </to>
      </configuration>
    </plugin>
  </plugins>
</build>
```

#### ❌ "Permission denied: push to ghcr.io"

**Erreur:**
```
denied: permission_denied: write_package
```

**Solution:**
- Allez dans Settings > Actions > General
- Section "Workflow permissions"
- Sélectionnez "Read and write permissions"
- Cliquez sur "Save"

#### ❌ "Package visibility: private"

**Erreur:**
Le push réussit mais vous ne voyez pas l'image sur GHCR.

**Solution:**
```
1. Allez sur: https://github.com/skaouech?tab=packages
2. Cliquez sur l'image (ex: dealsetting)
3. Package settings > Change visibility
4. Sélectionnez "Public"
5. Confirmez
```

---

## 📞 Aide Supplémentaire

Si le problème persiste après avoir suivi ce guide :

### Informations à Fournir

1. **Capture d'écran** de Settings > Actions > General
2. **Logs complets** d'un run échoué :
   - Actions > Cliquez sur le run rouge
   - Cliquez sur chaque étape et copiez les logs
3. **Branche utilisée** (develop ou main)
4. **Repo concerné** (deal_generator, deal_security, etc.)

### Commande de Diagnostic

```bash
cd /Users/seyfkaoueche/Documents/work/project/dealtobook/workspace
./dealtobook-devops/scripts/tools/check-workflow-status.sh dealtobook-deal_setting
```

Envoyez le résultat de cette commande.

---

## ✅ Checklist de Vérification Rapide

Avant de demander de l'aide, vérifiez :

- [ ] GitHub Actions est activé (Settings > Actions > General)
- [ ] Workflow permissions: "Read and write"
- [ ] Le fichier `.github/workflows/build-and-push.yml` existe sur la branche `develop`
- [ ] Le fichier `mvnw` est exécutable (`ls -l mvnw` montre `-rwxr-xr-x`)
- [ ] Le profil Maven `prod` existe dans `pom.xml`
- [ ] Le plugin Jib est configuré dans `pom.xml`
- [ ] Vous avez rafraîchi la page après avoir cliqué sur "Run workflow"
- [ ] Vous attendez au moins 10 secondes avant de dire "rien ne se passe"

---

## 🎓 Comprendre le Workflow Manuel

Le workflow manuel (`workflow_dispatch`) permet de :
- Déclencher le build à la demande
- Builder depuis n'importe quelle branche
- Tester le CI/CD sans faire de commit

**Différence avec le workflow automatique:**
- Automatique (`on: push`): Se déclenche à chaque push
- Manuel (`on: workflow_dispatch`): Se déclenche quand vous cliquez

**Les deux sont configurés dans le même fichier !**

```yaml
on:
  push:            # ← Automatique
    branches:
      - main
      - develop
  workflow_dispatch: # ← Manuel
    inputs:
      image-tag:
        description: 'Tag Docker'
        default: 'latest'
```

---

**Version:** 1.0  
**Date:** 2025-10-31  
**Auteur:** DevOps Team

