# 🏗️ Stratégie CI/CD Multi-Repository

## 📦 Architecture

Vous avez **plusieurs repositories GitHub séparés** :

```
github.com/skaouech/
  ├── dealtobook-deal_generator    (Repo service 1)
  ├── dealtobook-deal_security     (Repo service 2)
  ├── dealtobook-deal_setting      (Repo service 3)
  ├── dealtobook-deal_website      (Repo service 4)
  ├── dealtobook-deal_webui        (Repo service 5)
  └── dealtobook-devops            (Repo orchestration)
```

## 🎯 Stratégie CI/CD

### Option 1: Workflows Individuels dans Chaque Repo (Recommandé)

**Avantages:**
- ✅ Autonomie de chaque service
- ✅ Build uniquement quand le service change
- ✅ Équipes peuvent travailler indépendamment
- ✅ Simple à configurer

**Comment:**
1. Chaque repo de service contient son propre `.github/workflows/build.yml`
2. Build et push l'image Docker vers GHCR
3. Optionnel : notifier le repo devops pour déclencher le déploiement

### Option 2: Orchestration Centralisée depuis dealtobook-devops

**Avantages:**
- ✅ Contrôle centralisé
- ✅ Déploiement coordonné de tous les services
- ✅ Un seul endroit pour gérer la CI/CD

**Comment:**
1. `dealtobook-devops` déclenche les workflows des autres repos
2. Utilise `repository_dispatch` ou Personal Access Token (PAT)
3. Attend que tous les builds soient terminés
4. Déploie tous les services ensemble

### Option 3: Hybride (Best Practice)

**Recommandation:**
- Workflows individuels pour le build (Option 1)
- Workflow central pour le déploiement (Option 2)

## 📋 Structure Recommandée

```
┌─────────────────────────────────────────────────────┐
│  Repo: dealtobook-deal_generator                    │
│  .github/workflows/                                 │
│    └── build-and-push.yml   [Build + Push GHCR]    │
└─────────────────────────────────────────────────────┘
                    │
                    │ Push image
                    ▼
         ┌──────────────────────┐
         │       GHCR           │
         │  (Image Registry)    │
         └──────────────────────┘
                    │
                    │ Pull image
                    ▼
┌─────────────────────────────────────────────────────┐
│  Repo: dealtobook-devops                            │
│  .github/workflows/                                 │
│    ├── deploy-all.yml        [Deploy tous services]│
│    ├── deploy-single.yml     [Deploy 1 service]    │
│    └── rollback.yml          [Rollback]            │
└─────────────────────────────────────────────────────┘
```

## 🚀 Implémentation

### Étape 1: Workflows dans chaque Repo de Service

Créer `.github/workflows/build-and-push.yml` dans **chaque repo de service**.

### Étape 2: Workflows dans dealtobook-devops

Créer les workflows d'orchestration dans `dealtobook-devops`.

### Étape 3: Configurer les Secrets

Chaque repo de service a besoin de :
- `GITHUB_TOKEN` (fourni automatiquement)

Le repo `dealtobook-devops` a besoin de :
- `SSH_PRIVATE_KEY`
- `HOSTINGER_USER`
- `HOSTINGER_IP`
- `GHCR_TOKEN` ou `PAT_TOKEN` (pour repository_dispatch si nécessaire)

## 🔄 Flux de Travail

### Scénario 1: Développement d'un Service

```
Developer modifie deal-generator
     │
     ▼
git push vers dealtobook-deal_generator
     │
     ▼
Workflow build-and-push.yml se déclenche
     │
     ▼
Build Maven + Jib
     │
     ▼
Push image vers GHCR
     │
     ▼
(Optionnel) Déclenche deploy dans dealtobook-devops
     │
     ▼
Déploiement automatique
```

### Scénario 2: Déploiement Coordonné

```
Dans dealtobook-devops
     │
     ▼
Actions > Deploy All > Run workflow
     │
     ▼
Pull toutes les images latest depuis GHCR
     │
     ▼
SSH vers serveur
     │
     ▼
docker-compose up avec nouvelles images
```

## 📁 Fichiers à Créer

Voir les fichiers individuels dans ce dossier :
- `workflow-per-service/` - Templates pour chaque service
- `workflow-devops/` - Workflows pour dealtobook-devops

