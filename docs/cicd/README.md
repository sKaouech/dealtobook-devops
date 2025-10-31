# 🚀 CI/CD Documentation DealToBook

Documentation complète de l'infrastructure CI/CD avec GitHub Actions.

## 📚 Documents

| Document | Description |
|----------|-------------|
| [CICD-USAGE-GUIDE.md](./CICD-USAGE-GUIDE.md) | Guide complet d'utilisation de la CI/CD |
| [GITHUB-SECRETS-SETUP.md](./GITHUB-SECRETS-SETUP.md) | Configuration des secrets GitHub |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Architecture technique détaillée |

## ⚡ Quick Start

### 1. Configuration Initiale

```bash
# 1. Configurer les secrets GitHub (voir GITHUB-SECRETS-SETUP.md)
#    - SSH_PRIVATE_KEY
#    - HOSTINGER_USER
#    - HOSTINGER_IP

# 2. Vérifier que les workflows sont dans .github/workflows/
ls -la .github/workflows/

# 3. Push vers GitHub
git add .github/workflows/
git commit -m "ci: add GitHub Actions workflows"
git push origin develop
```

### 2. Premier Déploiement

#### Option A: Automatique (Push)
```bash
# Modifier un service
cd dealtobook-deal_generator
# ... faire des modifications ...
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin develop

# Le workflow se déclenche automatiquement! 🚀
```

#### Option B: Manuel (GitHub UI)
1. Aller sur **Actions** > **Build & Deploy All**
2. Cliquer sur **Run workflow**
3. Sélectionner:
   - Environment: `development`
   - Services: `all`
   - Skip tests: `false`
   - Deploy after build: `true`
4. Cliquer sur **Run workflow**

### 3. Vérification

```bash
# Se connecter au serveur
ssh root@<VOTRE_IP>

# Vérifier les services
cd /opt/dealtobook-dev
docker-compose ps

# Voir les logs
docker-compose logs -f deal-generator
```

## 🎯 Workflows Disponibles

### Workflows Individuels
- `backend-deal-generator.yml` - Build Deal Generator
- `backend-deal-security.yml` - Build Deal Security
- `backend-deal-setting.yml` - Build Deal Setting
- `backend-deal-website.yml` - Build Deal Website
- `frontend-deal-webui.yml` - Build Deal WebUI

### Workflows Orchestrateurs
- `build-and-deploy-all.yml` - Build et déploie tous les services
- `deploy-only.yml` - Déploie sans rebuild
- `rollback.yml` - Rollback vers une version précédente

### Workflows Réutilisables (Shared)
- `_shared-build-backend.yml` - Template pour backends Spring Boot
- `_shared-build-frontend.yml` - Template pour frontends Angular

## 📋 Architecture Simplifiée

```
Push Code (develop/main)
         │
         ▼
  ┌──────────────┐
  │   Trigger    │
  │   Workflow   │
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │     Build    │
  │   + Tests    │
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │ Docker Build │
  │  (Jib/Buildx)│
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │  Push GHCR   │
  │  (Registry)  │
  └──────┬───────┘
         │
         ▼
  ┌──────────────┐
  │    Deploy    │
  │  Hostinger   │
  └──────────────┘
```

## 🔑 Configuration Minimale Requise

### Secrets GitHub

| Secret | Valeur |
|--------|--------|
| `SSH_PRIVATE_KEY` | Clé SSH privée pour se connecter au serveur |
| `HOSTINGER_USER` | `root` (ou votre utilisateur) |
| `HOSTINGER_IP` | Adresse IP du serveur |

### Permissions GitHub Actions

1. **Settings** > **Actions** > **General**
2. **Workflow permissions:** "Read and write permissions"
3. **Allow GitHub Actions to create and approve pull requests:** ✅

## 🎬 Cas d'Usage Communs

### Déployer un seul service

```bash
# Via GitHub UI
Actions > Backend - Deal Generator > Run workflow
```

### Déployer tous les services

```bash
# Via GitHub UI
Actions > Build & Deploy All > Run workflow
   Environment: development
   Services: all
```

### Rollback en cas de problème

```bash
# Via GitHub UI
Actions > Rollback > Run workflow
   Environment: production
   Rollback tag: sha-abc123  # Identifier via Actions history
   Services: all
```

### Déployer avec un tag spécifique

```bash
# Via GitHub UI
Actions > Deploy Only > Run workflow
   Environment: production
   Services: all
   Image tag: v1.2.0
```

## 🔄 Workflow de Développement

```
1. Feature Branch
   ↓
2. Développement local
   ↓
3. Commit + Push
   ↓
4. Ouvrir une PR vers develop
   ↓
5. Tests automatiques (CI)
   ↓
6. Code Review
   ↓
7. Merge dans develop
   ↓
8. Déploiement automatique en dev
   ↓
9. Tests en environnement de dev
   ↓
10. Merge develop → main
   ↓
11. Déploiement automatique en prod
```

## 🛠️ Commandes Utiles

### Déclencher un workflow via CLI
```bash
# Installer GitHub CLI
brew install gh  # macOS
# ou
apt install gh   # Linux

# Se connecter
gh auth login

# Déclencher un workflow
gh workflow run build-and-deploy-all.yml \
  -f environment=development \
  -f services=all
```

### Voir l'état des workflows
```bash
# Lister les workflows
gh workflow list

# Voir les exécutions récentes
gh run list

# Voir les logs d'une exécution
gh run view <run-id> --log
```

### Annuler un workflow
```bash
gh run cancel <run-id>
```

## 📊 Monitoring

### GitHub Actions UI

1. **Actions tab** - Vue d'ensemble de tous les workflows
2. **Workflow runs** - Historique des exécutions
3. **Summary** - Résumé de chaque exécution
4. **Logs** - Logs détaillés de chaque step

### Badges (Optionnel)

Ajouter dans votre README.md:

```markdown
![Build Status](https://github.com/skaouech/dealtobook/actions/workflows/build-and-deploy-all.yml/badge.svg)
```

## 🆘 Dépannage Rapide

### Le workflow ne se déclenche pas
```bash
# Vérifier que le workflow est dans .github/workflows/
ls -la .github/workflows/

# Vérifier la syntaxe YAML
yamllint .github/workflows/backend-deal-generator.yml

# Vérifier les permissions GitHub Actions
# Settings > Actions > General > Workflow permissions
```

### Build échoue
```bash
# Voir les logs détaillés
gh run view <run-id> --log

# Re-run avec plus de verbosité
gh run rerun <run-id> --debug
```

### Déploiement échoue
```bash
# Tester la connexion SSH manuellement
ssh -i ~/.ssh/dealtobook_deploy root@<IP>

# Vérifier les secrets
# Settings > Secrets and variables > Actions
```

## 📖 Guides Détaillés

- **[CICD-USAGE-GUIDE.md](./CICD-USAGE-GUIDE.md)** - Guide complet avec tous les scénarios
- **[GITHUB-SECRETS-SETUP.md](./GITHUB-SECRETS-SETUP.md)** - Configuration des secrets pas à pas
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Architecture technique détaillée

## 🎓 Best Practices

1. ✅ Toujours tester en `develop` avant `main`
2. ✅ Utiliser des PR pour le code review
3. ✅ Tagger les releases (`git tag v1.2.3`)
4. ✅ Monitorer les workflows régulièrement
5. ✅ Faire des commits atomiques et descriptifs
6. ✅ Utiliser semantic versioning
7. ✅ Documenter les changements importants
8. ✅ Protéger la branche `main`
9. ✅ Require approval pour production
10. ✅ Faire des rollbacks rapides si nécessaire

## 📞 Support

Pour toute question:
- Consulter les guides détaillés
- Vérifier les logs des workflows
- Consulter la documentation GitHub Actions

## 🔗 Liens Utiles

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)

