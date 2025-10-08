# 🧹 Plan de Nettoyage et CI/CD Moderne

## 📋 **Architecture Actuelle Identifiée**

### **Repositories Séparés :**
- `dealtobook-deal_generator` (Backend Spring Boot)
- `dealtobook-deal_security` (Backend Spring Boot)  
- `dealtobook-deal_setting` (Backend Spring Boot)
- `dealtobook-deal_website` (Frontend Angular)
- `dealtobook-deal_webui` (Frontend Angular)
- `dealtobook-devops` (Infrastructure & Deployment)

### **État Actuel :**
- ✅ Version stable déployée sur Hostinger
- ✅ Communication inter-services fonctionnelle
- ✅ HTTPS configuré avec Let's Encrypt
- ✅ Keycloak avec thème personnalisé

## 🧹 **Plan de Nettoyage**

### **1. Fichiers à Supprimer**
```bash
# Dossiers de build Maven
./dealtobook-deal_*/target/

# Fichiers temporaires Node.js (garder package-lock.json)
./dealtobook-deal_webui/node_modules/
./dealtobook-deal_website/node_modules/

# Fichiers de backup et temporaires
**/*.backup
**/*.bak
**/*.tmp
**/*~
```

### **2. Fichiers à Déplacer vers dealtobook-devops**
```bash
# Scripts de déploiement
./scripts/fix-keycloak-clients.sh
./RESOLUTION-*.md
./THEME-*.md

# Configurations Docker
./keycloak-themes/
./nginx/
```

### **3. Fichiers à Garder dans Chaque Service**
```bash
# Backend Services
- src/
- pom.xml
- README.md
- Dockerfile (à créer)
- .github/workflows/ (à créer)

# Frontend Services  
- src/
- package.json
- angular.json
- README.md
- Dockerfile (à créer)
- .github/workflows/ (à créer)
```

## 🚀 **Architecture CI/CD Proposée**

### **Stratégie : GitOps avec Déploiement Automatique**

```mermaid
graph LR
    A[Push Code] --> B[GitHub Actions]
    B --> C[Build & Test]
    C --> D[Build Docker Image]
    D --> E[Push to GHCR]
    E --> F[Deploy to Hostinger]
    F --> G[Health Check]
```

### **1. Par Service (Repos Individuels)**
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
      - name: Build & Test
      - name: Build Docker Image
      - name: Push to GHCR
      - name: Deploy to Hostinger (if main branch)
      - name: Health Check
```

### **2. Orchestration Centrale (dealtobook-devops)**
```yaml
# Workflow pour déployer tous les services
# Trigger manuel ou webhook depuis les autres repos
name: Full Stack Deployment
on:
  workflow_dispatch:
  repository_dispatch:
```

## 🔧 **Configuration Technique**

### **Secrets GitHub (par repo) :**
```bash
# Secrets communs à tous les repos
GHCR_TOKEN=ghp_xxx
HOSTINGER_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
HOSTINGER_HOST=148.230.114.13
HOSTINGER_USER=root

# Secrets spécifiques par environnement
PROD_DATABASE_URL=xxx
PROD_KEYCLOAK_SECRET=xxx
```

### **Variables d'Environnement :**
```bash
# Par environnement (dev, staging, prod)
ENVIRONMENT=prod
REGISTRY=ghcr.io/skaouech
IMAGE_TAG=${GITHUB_SHA::8}
```

### **Tags Docker :**
```bash
# Stratégie de tagging
latest                    # Dernière version stable
${GITHUB_SHA::8}         # SHA court du commit
v1.2.3                   # Version sémantique (tags Git)
main-${GITHUB_SHA::8}    # Branche + SHA
```

## 📁 **Structure Finale Proposée**

### **Chaque Repo de Service :**
```
dealtobook-deal_generator/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── src/
├── Dockerfile
├── pom.xml
├── README.md
└── .gitignore
```

### **Repo DevOps :**
```
dealtobook-devops/
├── .github/
│   └── workflows/
│       ├── full-deployment.yml
│       └── infrastructure.yml
├── docker-compose/
│   ├── docker-compose.prod.yml
│   └── docker-compose.staging.yml
├── nginx/
├── keycloak-themes/
├── scripts/
├── monitoring/
└── docs/
```

## 🎯 **Workflow de Développement**

### **1. Développement Feature :**
```bash
# Developer workflow
git checkout -b feature/new-feature
# ... développement ...
git push origin feature/new-feature
# → Déclenche CI (build + test uniquement)
```

### **2. Déploiement Staging :**
```bash
git checkout develop
git merge feature/new-feature
git push origin develop
# → Déclenche CI/CD vers staging
```

### **3. Déploiement Production :**
```bash
git checkout main
git merge develop
git tag v1.2.3
git push origin main --tags
# → Déclenche CI/CD vers production
```

## 🔄 **Actions Immédiates**

### **Phase 1 : Nettoyage (30 min)**
1. Supprimer les dossiers `target/`
2. Déplacer les fichiers vers `dealtobook-devops`
3. Créer les `.gitignore` appropriés

### **Phase 2 : CI/CD Backend (1h)**
1. Créer les Dockerfiles pour chaque service backend
2. Créer les workflows GitHub Actions
3. Configurer les secrets

### **Phase 3 : CI/CD Frontend (45 min)**
1. Créer les Dockerfiles pour les frontends
2. Créer les workflows GitHub Actions
3. Tester le déploiement

### **Phase 4 : Orchestration (30 min)**
1. Configurer le repo devops
2. Créer le workflow de déploiement complet
3. Tests end-to-end

## ❓ **Questions pour Finaliser :**

1. **Environnements** : Voulez-vous dev/staging/prod ou juste prod ?
2. **Déclencheurs** : Auto-deploy sur `main` ou manuel ?
3. **Tests** : Intégrer des tests automatisés dans la CI ?
4. **Rollback** : Stratégie de rollback automatique ?
5. **Notifications** : Slack/Discord pour les déploiements ?

**Prêt à commencer par le nettoyage ?** 🚀
