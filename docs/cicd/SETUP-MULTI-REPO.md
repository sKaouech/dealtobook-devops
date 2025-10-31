# 🚀 Setup CI/CD Multi-Repository

Guide pas-à-pas pour configurer la CI/CD avec plusieurs repositories.

## 📋 Vue d'Ensemble

```
Repositories GitHub:
  ├── dealtobook-deal_generator    [Service - Build son image]
  ├── dealtobook-deal_security     [Service - Build son image]
  ├── dealtobook-deal_setting      [Service - Build son image]
  ├── dealtobook-deal_website      [Service - Build son image]
  ├── dealtobook-deal_webui        [Service - Build son image]
  └── dealtobook-devops            [Orchestration - Déploie tout]
```

## 🔧 Étape 1: Configurer les Workflows de Service

Pour **chaque repo de service** (generator, security, setting, website, webui):

### 1.1 Créer le dossier .github/workflows

```bash
# Dans chaque repo de service
mkdir -p .github/workflows
```

### 1.2 Copier le workflow approprié

**Pour les services backend** (generator, security, setting, website):

```bash
# Copier depuis dealtobook-devops/docs/cicd/workflow-per-service/
cp backend-build-template.yml .github/workflows/build-and-push.yml
```

**Pour le service frontend** (webui):

```bash
# Copier depuis dealtobook-devops/docs/cicd/workflow-per-service/
cp frontend-build-template.yml .github/workflows/build-and-push.yml
```

### 1.3 Adapter les variables

Éditer `.github/workflows/build-and-push.yml` et modifier:

**Pour deal-generator:**
```yaml
env:
  SERVICE_NAME: deal-generator
  GHCR_IMAGE: ghcr.io/skaouech/dealdealgenerator
  JAVA_VERSION: '17'
  MAVEN_PROFILE: prod
```

**Pour deal-security:**
```yaml
env:
  SERVICE_NAME: deal-security
  GHCR_IMAGE: ghcr.io/skaouech/dealsecurity
  JAVA_VERSION: '17'
  MAVEN_PROFILE: prod
```

**Pour deal-setting:**
```yaml
env:
  SERVICE_NAME: deal-setting
  GHCR_IMAGE: ghcr.io/skaouech/dealsetting
  JAVA_VERSION: '17'
  MAVEN_PROFILE: prod
```

**Pour deal-website:**
```yaml
env:
  SERVICE_NAME: deal-website
  GHCR_IMAGE: ghcr.io/skaouech/deal-website
  JAVA_VERSION: '11'  # ⚠️ Java 11 pour website
  MAVEN_PROFILE: prod
```

**Pour deal-webui:**
```yaml
env:
  SERVICE_NAME: deal-webui
  GHCR_IMAGE: ghcr.io/skaouech/deal-webui
  NODE_VERSION: '18'
  DOCKERFILE: Dockerfile2
```

### 1.4 Commit et Push

```bash
# Dans chaque repo de service
git add .github/workflows/build-and-push.yml
git commit -m "ci: add GitHub Actions workflow"
git push origin develop
```

### 1.5 Vérifier

Aller sur GitHub Actions dans chaque repo:
```
https://github.com/skaouech/dealtobook-deal_generator/actions
https://github.com/skaouech/dealtobook-deal_security/actions
https://github.com/skaouech/dealtobook-deal_setting/actions
https://github.com/skaouech/dealtobook-deal_website/actions
https://github.com/skaouech/dealtobook-deal_webui/actions
```

## 🔧 Étape 2: Configurer le Workflow d'Orchestration

Dans le repo **dealtobook-devops**:

### 2.1 Créer le workflow de déploiement

```bash
# Dans dealtobook-devops
mkdir -p .github/workflows
cp docs/cicd/workflow-devops/deploy-all-services.yml .github/workflows/
```

### 2.2 Configurer les secrets

Dans `dealtobook-devops` > Settings > Secrets > Actions:

| Secret | Valeur | Description |
|--------|--------|-------------|
| `SSH_PRIVATE_KEY` | Votre clé SSH privée | Pour se connecter au serveur |
| `HOSTINGER_USER` | `root` | Utilisateur SSH |
| `HOSTINGER_IP` | L'IP du serveur | Adresse IP Hostinger |

### 2.3 Commit et Push

```bash
# Dans dealtobook-devops
git add .github/workflows/deploy-all-services.yml
git commit -m "ci: add deployment workflow"
git push origin main
```

## 🚀 Étape 3: Tester le Workflow

### Test 1: Build d'un Service

1. Modifier un fichier dans un repo de service (ex: deal-generator)
2. Commit et push
3. Aller sur Actions du repo
4. Vérifier que le workflow "Build and Push Docker Image" se déclenche
5. Vérifier que l'image est poussée vers GHCR

### Test 2: Déploiement depuis dealtobook-devops

1. Aller sur `dealtobook-devops` > Actions
2. Sélectionner "Deploy All Services"
3. Cliquer sur "Run workflow"
4. Paramètres:
   - Environment: `development`
   - Services: `all`
   - Image tag: `develop`
5. Cliquer sur "Run workflow"
6. Vérifier les logs

## 📊 Flux de Travail

### Développement Normal

```
1. Developer modifie code dans dealtobook-deal_generator
   ↓
2. git push vers dealtobook-deal_generator
   ↓
3. Workflow "Build and Push" se déclenche AUTOMATIQUEMENT
   ↓
4. Image buildée et poussée vers GHCR avec tag "develop"
   ↓
5. Dans dealtobook-devops:
   Actions > Deploy All Services > Run workflow
   • Environment: development
   • Services: generator (ou all)
   • Image tag: develop
   ↓
6. Service déployé sur le serveur
```

### Release en Production

```
1. Merge develop → main dans chaque repo de service
   ↓
2. Workflows se déclenchent AUTOMATIQUEMENT
   ↓
3. Images buildées avec tag "latest"
   ↓
4. Dans dealtobook-devops:
   Actions > Deploy All Services > Run workflow
   • Environment: production
   • Services: all
   • Image tag: latest
   ↓
5. Tous les services déployés en production
```

## 🔄 Workflow Complet par Service

### Exemple: deal-generator

```yaml
# Dans dealtobook-deal_generator/.github/workflows/build-and-push.yml
name: Build and Push Docker Image

on:
  push:
    branches: [main, develop]
  workflow_dispatch:

env:
  SERVICE_NAME: deal-generator
  GHCR_IMAGE: ghcr.io/skaouech/dealdealgenerator
  JAVA_VERSION: '17'
  MAVEN_PROFILE: prod

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'maven'
      - name: Build
        run: ./mvnw clean package -Pprod -DskipTests
      - name: Jib Build
        run: ./mvnw -Pprod jib:dockerBuild -DskipTests
      - name: Tag & Push
        run: |
          # Tag images
          docker tag <local> $GHCR_IMAGE:develop
          docker tag <local> $GHCR_IMAGE:sha-${{ github.sha }}
          # Login GHCR
          echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          # Push
          docker push $GHCR_IMAGE:develop
          docker push $GHCR_IMAGE:sha-${{ github.sha }}
```

## ✅ Checklist

### Pour chaque repo de service:
- [ ] Créer `.github/workflows/build-and-push.yml`
- [ ] Adapter les variables (SERVICE_NAME, GHCR_IMAGE, etc.)
- [ ] Commit et push
- [ ] Vérifier que Actions est activé
- [ ] Tester le workflow manuellement

### Pour dealtobook-devops:
- [ ] Créer `.github/workflows/deploy-all-services.yml`
- [ ] Configurer les secrets (SSH_PRIVATE_KEY, etc.)
- [ ] Commit et push
- [ ] Tester le déploiement manuel

## 🎯 Résumé

| Repo | Rôle | Workflow | Déclenché quand |
|------|------|----------|-----------------|
| `deal-generator` | Build | `build-and-push.yml` | Push sur main/develop |
| `deal-security` | Build | `build-and-push.yml` | Push sur main/develop |
| `deal-setting` | Build | `build-and-push.yml` | Push sur main/develop |
| `deal-website` | Build | `build-and-push.yml` | Push sur main/develop |
| `deal-webui` | Build | `build-and-push.yml` | Push sur main/develop |
| `dealtobook-devops` | Deploy | `deploy-all-services.yml` | Manuel ou webhook |

## 🆘 Troubleshooting

### Workflow ne se déclenche pas
- Vérifier que Actions est activé dans Settings > Actions
- Vérifier que le fichier est dans `.github/workflows/`
- Vérifier la syntaxe YAML

### Build échoue
- Vérifier les logs détaillés dans Actions
- Vérifier que Maven/npm fonctionne localement
- Vérifier les versions Java/Node

### Push vers GHCR échoue
- GITHUB_TOKEN est fourni automatiquement, pas besoin de secret
- Vérifier que le package GHCR existe ou que vous avez les permissions
- Vérifier le nom de l'image (minuscules uniquement)

### Déploiement échoue
- Vérifier les secrets SSH dans dealtobook-devops
- Tester la connexion SSH manuellement
- Vérifier que les images existent dans GHCR

## 📚 Prochaines Étapes

1. Configurer les workflows dans chaque repo (Étape 1)
2. Configurer le workflow d'orchestration (Étape 2)
3. Tester le build d'un service
4. Tester le déploiement
5. Configurer les environnements GitHub (optionnel)
6. Ajouter des notifications (optionnel)

