# 🚀 Processus Complet CI/CD - DealToBook

Guide complet expliquant comment fonctionne la CI/CD de A à Z avec tous les scénarios.

## 📊 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                    ARCHITECTURE MULTI-REPO                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  github.com/skaouech/                                          │
│  ├── dealtobook-deal_generator    [Repo 1 - Service]          │
│  ├── dealtobook-deal_security     [Repo 2 - Service]          │
│  ├── dealtobook-deal_setting      [Repo 3 - Service]          │
│  ├── dealtobook-deal_website      [Repo 4 - Service]          │
│  ├── dealtobook-deal_webui        [Repo 5 - Service]          │
│  └── dealtobook-devops            [Repo 6 - Orchestration]    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## 🎯 Principe Général

### 2 Types de Workflows

**1. Workflows de BUILD (dans chaque repo de service)**
- Rôle: Builder l'image Docker du service
- Déclenchement: Push sur `main` ou `develop`
- Résultat: Image Docker dans GHCR

**2. Workflow de DEPLOY (dans dealtobook-devops)**
- Rôle: Déployer les services sur le serveur
- Déclenchement: Manuel via GitHub Actions UI
- Résultat: Services déployés et running

---

## 🔄 Processus Complet par Scénario

### 📋 SCÉNARIO 1: Développement Normal d'un Service

```
┌─────────────────────────────────────────────────────────────────┐
│  1. DÉVELOPPEUR modifie le code                                │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repo: dealtobook-deal_generator                                │
│                                                                 │
│  $ git add .                                                    │
│  $ git commit -m "feat: nouvelle fonctionnalité"               │
│  $ git push origin develop                                     │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  GITHUB ACTIONS - Workflow Build                               │
│  (.github/workflows/build-and-push.yml)                        │
│                                                                 │
│  Étapes:                                                        │
│  1️⃣  Checkout code                                             │
│  2️⃣  Setup JDK 17                                              │
│  3️⃣  Maven build: ./mvnw clean package -Pprod -DskipTests     │
│  4️⃣  Jib build: ./mvnw -Pprod jib:dockerBuild                 │
│  5️⃣  Tag images:                                               │
│      - ghcr.io/skaouech/dealdealgenerator:develop             │
│      - ghcr.io/skaouech/dealdealgenerator:sha-abc123          │
│      - ghcr.io/skaouech/dealdealgenerator:develop-branch      │
│  6️⃣  Login GHCR avec GITHUB_TOKEN                             │
│  7️⃣  Push vers GHCR                                            │
│                                                                 │
│  Durée: ~5 minutes                                              │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  GITHUB CONTAINER REGISTRY (GHCR)                              │
│                                                                 │
│  Image disponible:                                              │
│  📦 ghcr.io/skaouech/dealdealgenerator:develop                 │
│                                                                 │
│  Visible sur:                                                   │
│  https://github.com/skaouech/dealtobook-deal_generator/pkgs    │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  DÉPLOIEMENT MANUEL                                             │
│                                                                 │
│  Développeur va sur:                                            │
│  github.com/skaouech/dealtobook-devops                         │
│  > Actions > Deploy All Services > Run workflow                │
│                                                                 │
│  Paramètres:                                                    │
│  - Environment: development                                     │
│  - Services: generator (ou all)                                │
│  - Image tag: develop                                           │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  GITHUB ACTIONS - Workflow Deploy                              │
│  (dealtobook-devops/.github/workflows/deploy-all-services.yml) │
│                                                                 │
│  Étapes:                                                        │
│  1️⃣  Checkout dealtobook-devops                               │
│  2️⃣  Configure SSH (secrets.SSH_PRIVATE_KEY)                  │
│  3️⃣  Prepare services list                                     │
│  4️⃣  SSH vers serveur Hostinger                               │
│  5️⃣  Transfer config files                                     │
│  6️⃣  Pull images GHCR sur le serveur                          │
│  7️⃣  docker-compose up avec tag 'develop'                     │
│  8️⃣  Health checks                                             │
│  9️⃣  Verify deployment                                         │
│                                                                 │
│  Durée: ~4 minutes                                              │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  SERVEUR HOSTINGER (development)                                │
│                                                                 │
│  /opt/dealtobook-dev/                                          │
│  └── docker-compose up                                          │
│      ├── dealtobook-generator-backend (develop) ✅ Healthy     │
│      ├── dealtobook-security-backend (develop) ✅ Healthy      │
│      ├── dealtobook-setting-backend (develop) ✅ Healthy       │
│      ├── dealtobook-webui-frontend (develop) ✅ Running        │
│      ├── dealtobook-website-frontend (develop) ✅ Running      │
│      ├── dealtobook-keycloak ✅ Healthy                        │
│      ├── dealtobook-postgres ✅ Healthy                        │
│      ├── dealtobook-nginx-ssl ✅ Healthy                       │
│      └── dealtobook-zipkin ✅ Healthy                          │
│                                                                 │
│  URLs:                                                          │
│  • https://administration-dev.dealtobook.com                   │
│  • https://website-dev.dealtobook.com                          │
│  • https://keycloak-dev.dealtobook.com                         │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
            ✅ DÉPLOIEMENT TERMINÉ !
```

**Temps Total:** ~10 minutes (5 min build + 4 min deploy)

---

### 📋 SCÉNARIO 2: Release en Production

```
┌─────────────────────────────────────────────────────────────────┐
│  1. Tous les tests passent en DEVELOPMENT                      │
│  2. Prêt pour la production                                     │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  MERGE develop → main                                           │
│                                                                 │
│  Pour CHAQUE service:                                           │
│  $ git checkout main                                            │
│  $ git merge develop                                            │
│  $ git tag v1.2.3                                              │
│  $ git push origin main --tags                                  │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  GITHUB ACTIONS - Build (sur CHAQUE repo de service)           │
│                                                                 │
│  Branch: main                                                   │
│  Tag créé: latest                                               │
│                                                                 │
│  Images créées:                                                 │
│  📦 ghcr.io/skaouech/dealdealgenerator:latest                  │
│  📦 ghcr.io/skaouech/dealdealgenerator:v1.2.3                  │
│  📦 ghcr.io/skaouech/dealdealgenerator:sha-xyz                 │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  DÉPLOIEMENT EN PRODUCTION                                      │
│                                                                 │
│  github.com/skaouech/dealtobook-devops                         │
│  > Actions > Deploy All Services > Run workflow                │
│                                                                 │
│  Paramètres:                                                    │
│  - Environment: PRODUCTION ⚠️                                   │
│  - Services: all                                                │
│  - Image tag: latest                                            │
│                                                                 │
│  ⚠️  Peut nécessiter une APPROBATION manuelle                  │
│      (si configuré dans GitHub Environments)                    │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  SERVEUR HOSTINGER (production)                                 │
│                                                                 │
│  /opt/dealtobook/                                              │
│  └── docker-compose up                                          │
│      ├── Images avec tag: latest ✅                            │
│      ├── Domaines: administration.dealtobook.com              │
│      └── Certificats SSL: production                           │
└─────────────────────────────────────────────────────────────────┘
```

---

### 📋 SCÉNARIO 3: Hotfix Urgent en Production

```
┌─────────────────────────────────────────────────────────────────┐
│  ❌ BUG CRITIQUE détecté en PRODUCTION                         │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  OPTION A: Fix rapide + Rebuild                                │
│                                                                 │
│  1. Créer hotfix branch depuis main:                           │
│     $ git checkout main                                         │
│     $ git checkout -b hotfix/fix-critical-bug                  │
│                                                                 │
│  2. Fix le bug + commit                                         │
│     $ git add .                                                 │
│     $ git commit -m "fix: critical bug"                        │
│     $ git push origin hotfix/fix-critical-bug                  │
│                                                                 │
│  3. Merge dans main:                                            │
│     GitHub > Pull Request > Merge                              │
│                                                                 │
│  4. Workflow auto-build sur main                               │
│     → Image latest mise à jour                                 │
│                                                                 │
│  5. Deploy manuel:                                              │
│     Actions > Deploy > production > latest                     │
│                                                                 │
│  Temps: ~15 minutes                                             │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  OPTION B: Rollback vers version stable                        │
│                                                                 │
│  1. Identifier la dernière version stable:                     │
│     GitHub > Actions > Historique                              │
│     → Trouver le SHA du dernier déploiement OK                 │
│                                                                 │
│  2. Rollback workflow:                                          │
│     Actions > Rollback > Run workflow                          │
│     - Environment: production                                   │
│     - Rollback tag: sha-abc123def                              │
│     - Services: all (ou service spécifique)                    │
│                                                                 │
│  3. Le workflow:                                                │
│     - Pull l'image avec le tag stable                          │
│     - Redéploie avec cette version                             │
│     - Vérifie le déploiement                                    │
│                                                                 │
│  Temps: ~2 minutes ⚡                                           │
└─────────────────────────────────────────────────────────────────┘
```

---

### 📋 SCÉNARIO 4: Développement Parallèle (Feature Branch)

```
┌─────────────────────────────────────────────────────────────────┐
│  ÉQUIPE A travaille sur Feature X                              │
│  ÉQUIPE B travaille sur Feature Y                              │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  Repo: dealtobook-deal_generator                                │
│                                                                 │
│  Équipe A:                                                      │
│  $ git checkout -b feature/feature-x                           │
│  $ git push origin feature/feature-x                           │
│                                                                 │
│  Équipe B:                                                      │
│  $ git checkout -b feature/feature-y                           │
│  $ git push origin feature/feature-y                           │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  GITHUB ACTIONS - Build automatique                            │
│                                                                 │
│  Équipe A: Image créée                                          │
│  📦 ghcr.io/skaouech/dealdealgenerator:feature-feature-x       │
│                                                                 │
│  Équipe B: Image créée                                          │
│  📦 ghcr.io/skaouech/dealdealgenerator:feature-feature-y       │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  TESTS ISOLÉS                                                   │
│                                                                 │
│  Équipe A peut déployer:                                        │
│  - Environment: development                                     │
│  - Services: generator                                          │
│  - Image tag: feature-feature-x                                │
│                                                                 │
│  Équipe B peut déployer:                                        │
│  - Environment: development                                     │
│  - Services: generator                                          │
│  - Image tag: feature-feature-y                                │
│                                                                 │
│  Les deux équipes testent indépendamment!                      │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  MERGE vers develop                                             │
│                                                                 │
│  Quand les features sont prêtes:                               │
│  1. Pull Request feature-x → develop                           │
│  2. Pull Request feature-y → develop                           │
│  3. Tests automatiques                                          │
│  4. Code review                                                 │
│  5. Merge                                                       │
│  6. Image develop mise à jour                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

### 📋 SCÉNARIO 5: Déploiement de Tous les Services

```
┌─────────────────────────────────────────────────────────────────┐
│  SITUATION: Nouvelle version majeure                            │
│  Tous les services ont été mis à jour                          │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  BUILDS PARALLÈLES                                              │
│                                                                 │
│  Dans chaque repo (en parallèle):                              │
│  1. dealtobook-deal_generator → build                          │
│  2. dealtobook-deal_security → build                           │
│  3. dealtobook-deal_setting → build                            │
│  4. dealtobook-deal_website → build                            │
│  5. dealtobook-deal_webui → build                              │
│                                                                 │
│  Tous les workflows s'exécutent en même temps!                 │
│  Temps total: ~5 minutes (parallèle)                           │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  TOUTES LES IMAGES SONT PRÊTES DANS GHCR                       │
│                                                                 │
│  📦 ghcr.io/skaouech/dealdealgenerator:latest                  │
│  📦 ghcr.io/skaouech/dealsecurity:latest                       │
│  📦 ghcr.io/skaouech/dealsetting:latest                        │
│  📦 ghcr.io/skaouech/dealtobook-deal-website:latest            │
│  📦 ghcr.io/skaouech/dealtobook-deal-webui:latest              │
└─────────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  DÉPLOIEMENT ORCHESTRÉ                                          │
│                                                                 │
│  dealtobook-devops > Actions > Deploy All Services             │
│                                                                 │
│  Paramètres:                                                    │
│  - Environment: production                                      │
│  - Services: all ← TOUS LES SERVICES                           │
│  - Image tag: latest                                            │
│                                                                 │
│  Le workflow déploie dans l'ordre:                             │
│  1. PostgreSQL + Zipkin                                        │
│  2. Keycloak                                                    │
│  3. Backend services (generator, security, setting)            │
│  4. Frontend services (webui, website)                         │
│  5. Nginx (reverse proxy)                                      │
│                                                                 │
│  Temps: ~4 minutes                                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Commandes et Workflows Détaillés

### Workflow de BUILD (dans chaque repo de service)

**Fichier:** `.github/workflows/build-and-push.yml`

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - Checkout code
      - Setup Java/Node
      - Build (Maven/npm)
      - Build Docker (Jib/Buildx)
      - Tag images
      - Login GHCR
      - Push images
```

### Workflow de DEPLOY (dans dealtobook-devops)

**Fichier:** `.github/workflows/deploy-all-services.yml`

```yaml
name: Deploy All Services

on:
  workflow_dispatch:
    inputs:
      environment: [development, production]
      services: [all, ou liste]
      image-tag: [latest, develop, ou SHA]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - Checkout
      - Configure SSH
      - Prepare services list
      - Deploy to Server (SSH)
      - Verify Deployment
```

---

## 🎯 Matrice des Scénarios

| Scénario | Qui Déclenche | Où | Résultat | Temps |
|----------|---------------|-----|----------|-------|
| **Push sur develop** | Développeur | Repo service | Image `:develop` dans GHCR | 5 min |
| **Push sur main** | Développeur | Repo service | Image `:latest` dans GHCR | 5 min |
| **Deploy development** | Développeur | dealtobook-devops | Services en dev | 4 min |
| **Deploy production** | DevOps/Lead | dealtobook-devops | Services en prod | 4 min |
| **Rollback** | DevOps | dealtobook-devops | Services restaurés | 2 min |
| **Feature branch** | Développeur | Repo service | Image `:feature-x` | 5 min |

---

## 🔐 Secrets Requis

### Pour BUILD (dans chaque repo de service)
- ✅ `GITHUB_TOKEN` (fourni automatiquement)

### Pour DEPLOY (dans dealtobook-devops)
- ✅ `SSH_PRIVATE_KEY` - Clé SSH pour Hostinger
- ✅ `HOSTINGER_USER` - Utilisateur SSH (root)
- ✅ `HOSTINGER_IP` - IP du serveur

---

## 📊 Flux de Données

```
CODE SOURCE (GitHub Repo)
         │
         │ git push
         ▼
WORKFLOW BUILD (GitHub Actions)
         │
         │ docker build
         ▼
IMAGE DOCKER (GHCR)
         │
         │ Trigger manuel deploy
         ▼
WORKFLOW DEPLOY (GitHub Actions)
         │
         │ SSH + docker-compose
         ▼
SERVEUR (Hostinger)
         │
         ▼
APPLICATION LIVE (HTTPS)
```

---

## ✅ Avantages de Cette Architecture

1. **Autonomie des Services**
   - Chaque service peut être buildé indépendamment
   - Pas de monorepo compliqué

2. **Flexibilité**
   - Deploy 1 service ou tous
   - Deploy n'importe quel tag (develop, latest, SHA)

3. **Traçabilité**
   - Chaque image liée à un commit
   - Historique complet dans GitHub Actions

4. **Rapidité**
   - Builds en parallèle
   - Deploy en ~4 minutes

5. **Rollback Facile**
   - Retour arrière en 2 minutes
   - Aucune perte de données

6. **Sécurité**
   - Secrets chiffrés
   - SSH pour le déploiement
   - Environments GitHub avec approbation

---

## 🎓 Best Practices Implémentées

✅ **GitOps** - Infrastructure as Code
✅ **Immutable Infrastructure** - Images Docker immuables
✅ **CI/CD Séparés** - Build ≠ Deploy
✅ **Multi-environment** - dev/prod séparés
✅ **Multi-tagging** - Plusieurs tags par image
✅ **Health Checks** - Vérification automatique
✅ **Rollback** - Retour arrière rapide

---

## 📚 Documentation Associée

- [SETUP-MULTI-REPO.md](SETUP-MULTI-REPO.md) - Setup complet
- [GITHUB-SECRETS-SETUP.md](GITHUB-SECRETS-SETUP.md) - Configuration secrets
- [CICD-USAGE-GUIDE.md](CICD-USAGE-GUIDE.md) - Guide d'utilisation
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture technique

---

**Version:** 1.0  
**Date:** 2025-10-31  
**Statut:** ✅ Opérationnel

