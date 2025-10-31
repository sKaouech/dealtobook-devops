# 🚀 Guide d'Utilisation CI/CD GitHub Actions

Guide complet pour utiliser la CI/CD automatisée de DealToBook.

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Workflows Disponibles](#workflows-disponibles)
- [Déclenchement Automatique](#déclenchement-automatique)
- [Déclenchement Manuel](#déclenchement-manuel)
- [Stratégie de Branching](#stratégie-de-branching)
- [Gestion des Images Docker](#gestion-des-images-docker)
- [Scénarios d'Utilisation](#scénarios-dutilisation)
- [Monitoring et Logs](#monitoring-et-logs)
- [Troubleshooting](#troubleshooting)

## 🎯 Vue d'ensemble

L'architecture CI/CD est conçue selon les principes DevOps modernes:

```
┌─────────────────────────────────────────────────────────────────┐
│                      GITHUB REPOSITORY                          │
│                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Backend  │  │ Backend  │  │ Backend  │  │ Frontend │      │
│  │Generator │  │Security  │  │ Setting  │  │  WebUI   │      │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘      │
│       │             │             │             │             │
│       └─────────────┴─────────────┴─────────────┘             │
│                          │                                     │
│                    ┌─────▼─────┐                              │
│                    │  Workflows │                              │
│                    │   (CI/CD)  │                              │
│                    └─────┬─────┘                              │
└──────────────────────────┼─────────────────────────────────────┘
                           │
                    ┌──────▼──────┐
                    │   Build     │
                    │   Test      │
                    │   Docker    │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    GHCR     │
                    │ (Registry)  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Deploy    │
                    │  Hostinger  │
                    └─────────────┘
```

### Principes

1. **Immutabilité**: Les images Docker sont immutables et taguées
2. **Traçabilité**: Chaque build est lié à un commit SHA
3. **Isolation**: Chaque service peut être buildé/déployé indépendamment
4. **Automatisation**: Push sur `develop`/`main` déclenche le pipeline
5. **Flexibilité**: Possibilité de déclencher manuellement avec options

## 📦 Workflows Disponibles

### 1. Workflows Individuels par Service

Chaque service a son propre workflow:

| Workflow | Service | Triggers |
|----------|---------|----------|
| `backend-deal-generator.yml` | Deal Generator | Push/PR sur `dealtobook-deal_generator/**` |
| `backend-deal-security.yml` | Deal Security | Push/PR sur `dealtobook-deal_security/**` |
| `backend-deal-setting.yml` | Deal Setting | Push/PR sur `dealtobook-deal_setting/**` |
| `backend-deal-website.yml` | Deal Website | Push/PR sur `dealtobook-deal_website/**` |
| `frontend-deal-webui.yml` | Deal WebUI | Push/PR sur `dealtobook-deal_webui/**` |

**Caractéristiques:**
- ✅ Build uniquement le service modifié
- ✅ Tests unitaires (activables/désactivables)
- ✅ Build Docker avec Jib (backend) ou Buildx (frontend)
- ✅ Push vers GHCR avec tags multiples
- ✅ Cache Maven/npm pour builds rapides

### 2. Workflow Orchestrateur

**`build-and-deploy-all.yml`** - Build et déploie tous les services

**Triggers:**
- Push sur `main` ou `develop` (auto-detection des changements)
- Manuel (via GitHub Actions UI)

**Fonctionnalités:**
- 🎯 Détection intelligente des services modifiés
- 🔄 Build en parallèle de tous les services modifiés
- 🚀 Déploiement automatique après build réussi
- 📊 Rapport détaillé dans GitHub Summary

### 3. Workflow Deploy-Only

**`deploy-only.yml`** - Déploie sans rebuild

**Utilisation:**
- Redéploiement rapide
- Utilisation d'images existantes
- Tests de déploiement

### 4. Workflow Rollback

**`rollback.yml`** - Retour à une version précédente

**Utilisation:**
- En cas de problème en production
- Restauration rapide d'une version stable

## ⚡ Déclenchement Automatique

### Branche `develop`

```bash
# Modifier un service
cd dealtobook-deal_generator
# ... faire des modifications ...
git add .
git commit -m "feat: nouvelle fonctionnalité"
git push origin develop
```

**Ce qui se passe:**
1. GitHub détecte le push sur `develop`
2. Le workflow `backend-deal-generator.yml` se déclenche
3. Build, tests, Docker build
4. Push de l'image avec tag `develop`
5. Le workflow `build-and-deploy-all.yml` se déclenche
6. Détection: seul `generator` a changé
7. Build de `generator` uniquement
8. Déploiement sur l'environnement de développement

### Branche `main`

```bash
# Merger develop vers main
git checkout main
git merge develop
git push origin main
```

**Ce qui se passe:**
1. Workflow déclenché sur `main`
2. Build avec tag `latest`
3. Analyse SonarQube (si configuré)
4. Déploiement sur l'environnement de production (avec approbation si configurée)

## 🎮 Déclenchement Manuel

### Via GitHub UI

1. Aller sur **Actions**
2. Sélectionner le workflow désiré
3. Cliquer sur **Run workflow**
4. Remplir les paramètres
5. Cliquer sur **Run workflow**

### Build & Deploy All

**Paramètres:**
- **Environment**: `development` ou `production`
- **Services**: `all`, `backends`, `frontends`, ou liste personnalisée
- **Skip tests**: `true`/`false`
- **Deploy after build**: `true`/`false`

**Exemples:**

#### Déployer tous les services en dev
```
Environment: development
Services: all
Skip tests: false
Deploy after build: true
```

#### Builder uniquement les backends
```
Services: backends
Skip tests: true
Deploy after build: false
```

#### Builder services spécifiques
```
Services: generator,security
Skip tests: false
Deploy after build: true
```

### Deploy Only

**Paramètres:**
- **Environment**: `development` ou `production`
- **Services**: Liste des services à déployer
- **Image tag**: Tag de l'image à utiliser (default: `latest`)

**Exemple: Redéployer avec une version spécifique**
```
Environment: production
Services: all
Image tag: sha-abc123def456
```

### Rollback

**Paramètres:**
- **Environment**: `development` ou `production`
- **Rollback tag**: Tag de l'image à restaurer
- **Services**: Services à rollback

**Exemple: Rollback du service security**
```
Environment: production
Rollback tag: sha-abc123def456
Services: security
```

## 🌳 Stratégie de Branching

```
main (production)
  ├── v1.0.0 (tag)
  ├── v1.1.0 (tag)
  │
develop (development)
  ├── feature/nouvelle-fonctionnalité
  ├── fix/correction-bug
  └── hotfix/correction-urgente
```

### Workflow de Développement

1. **Feature Branch**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/ma-nouvelle-fonctionnalité
   # ... développement ...
   git add .
   git commit -m "feat: ma nouvelle fonctionnalité"
   git push origin feature/ma-nouvelle-fonctionnalité
   ```

2. **Pull Request vers develop**
   - Créer une PR sur GitHub
   - Les tests s'exécutent automatiquement
   - Review du code
   - Merge dans `develop`

3. **Déploiement automatique en dev**
   - Le merge dans `develop` déclenche le build et déploiement
   - Vérification en environnement de développement

4. **Release vers production**
   ```bash
   git checkout main
   git merge develop
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin main --tags
   ```

### Hotfix en Production

```bash
# Créer une branche hotfix depuis main
git checkout main
git checkout -b hotfix/fix-critique
# ... correction ...
git add .
git commit -m "fix: correction critique"
git push origin hotfix/fix-critique

# Créer une PR vers main ET develop
# Après merge, le déploiement se fait automatiquement
```

## 🏷️ Gestion des Images Docker

### Tags Automatiques

Chaque build crée plusieurs tags:

| Tag | Description | Exemple |
|-----|-------------|---------|
| `latest` | Dernière version de `main` | `ghcr.io/skaouech/dealdealgenerator:latest` |
| `develop` | Dernière version de `develop` | `ghcr.io/skaouech/dealdealgenerator:develop` |
| `sha-*` | Commit SHA spécifique | `ghcr.io/skaouech/dealdealgenerator:sha-abc123` |
| Branche | Nom de la branche | `ghcr.io/skaouech/dealdealgenerator:feature-xyz` |
| Version | Tag git | `ghcr.io/skaouech/dealdealgenerator:v1.2.0` |

### Visualiser les Images

```bash
# Via GitHub
https://github.com/skaouech?tab=packages

# Via Docker CLI (après login)
docker pull ghcr.io/skaouech/dealdealgenerator:latest
docker images | grep dealdealgenerator
```

### Nettoyer les Images Anciennes

Les images sont automatiquement nettoyées sur le runner après le push.
Sur GHCR, vous pouvez configurer une politique de rétention:

1. Aller sur le package dans GitHub
2. Settings > Manage versions
3. Configurer la rétention (ex: garder les 10 dernières versions)

## 🎬 Scénarios d'Utilisation

### Scénario 1: Développement Normal

```
Développeur modifie deal-generator ➜ Push sur feature branch
   ↓
Crée une PR vers develop
   ↓
Tests automatiques s'exécutent
   ↓
Review + Merge dans develop
   ↓
Build automatique + Deploy en dev
   ↓
Tests en environnement de dev
```

### Scénario 2: Release en Production

```
Tous les tests passent en dev
   ↓
Merge develop vers main
   ↓
Build automatique avec tag 'latest'
   ↓
Analyse SonarQube
   ↓
(Optionnel) Approbation manuelle
   ↓
Deploy automatique en production
```

### Scénario 3: Hotfix Urgent

```
Bug critique détecté en production
   ↓
Créer hotfix branch depuis main
   ↓
Fix + commit
   ↓
Workflow manuel: Build & Deploy
   • Environment: production
   • Services: service-concerné
   • Skip tests: false
   ↓
Merge hotfix dans main ET develop
```

### Scénario 4: Rollback

```
Problème détecté après déploiement
   ↓
Identifier le dernier commit stable
   ↓
Workflow manuel: Rollback
   • Environment: production
   • Rollback tag: sha-xxxxx (commit stable)
   • Services: all
   ↓
Services restaurés immédiatement
   ↓
Investigation du problème en parallèle
```

### Scénario 5: Test d'une Nouvelle Image

```
Build réussi, image poussée vers GHCR
   ↓
Workflow manuel: Deploy Only
   • Environment: development
   • Services: generator
   • Image tag: sha-abc123 (nouveau build)
   ↓
Test de l'image en isolation
   ↓
Si OK, promouvoir vers production
```

## 📊 Monitoring et Logs

### Voir l'Exécution des Workflows

1. Aller sur **Actions** dans GitHub
2. Sélectionner le workflow désiré
3. Cliquer sur une exécution

### GitHub Summary

Chaque workflow génère un résumé:

```
## 🎉 Deployment Successful!

**Environment:** production
**Image Tag:** latest
**Services Deployed:** generator security setting website webui
**Commit:** abc123def456
**Branch:** main
```

### Logs Détaillés

Chaque step du workflow a des logs détaillés:
- Build output
- Test results
- Docker build logs
- Deploy logs

### Artifacts

Les résultats de tests sont uploadés en tant qu'artifacts:
- Rapports de tests unitaires
- Couverture de code
- Logs de build

**Télécharger:**
1. Aller sur l'exécution du workflow
2. Section **Artifacts**
3. Télécharger l'artifact désiré

## 🆘 Troubleshooting

### Workflow ne se déclenche pas

**Vérifier:**
1. Les paths dans le workflow correspondent aux fichiers modifiés
2. Le workflow file est valide (syntaxe YAML)
3. Les permissions GitHub Actions sont activées (Settings > Actions)

### Build échoue

**Erreurs communes:**

#### Erreur: "Maven build failed"
```
Solution:
- Vérifier les dépendances dans pom.xml
- Vérifier la version Java utilisée
- Checker les logs Maven détaillés
```

#### Erreur: "Docker login failed"
```
Solution:
- Vérifier que GITHUB_TOKEN est disponible
- Vérifier les permissions du token
- Essayer de re-run le workflow
```

#### Erreur: "Tests failed"
```
Solution:
- Consulter les artifacts de tests
- Corriger les tests en échec
- Ou skip les tests temporairement (skip-tests: true)
```

### Déploiement échoue

**Erreurs communes:**

#### Erreur: "SSH connection failed"
```
Solution:
- Vérifier le secret SSH_PRIVATE_KEY
- Vérifier HOSTINGER_IP
- Tester la connexion SSH manuellement
```

#### Erreur: "Docker pull failed"
```
Solution:
- L'image existe-t-elle dans GHCR?
- Le serveur peut-il accéder à GHCR?
- Vérifier les credentials Docker sur le serveur
```

#### Erreur: "Service failed to start"
```
Solution:
- SSH sur le serveur
- docker-compose logs <service>
- Vérifier les variables d'environnement
- Vérifier les dépendances (DB, Keycloak, etc.)
```

### Images Docker trop grosses

**Optimisations:**

1. **Backend (Jib):**
   - Jib utilise déjà des layers optimisés
   - Vérifier les dépendances inutiles dans pom.xml

2. **Frontend:**
   - Utiliser multi-stage builds
   - Minimiser les dépendances dans l'image finale
   - Utiliser `.dockerignore`

### Cache ne fonctionne pas

```yaml
# Vérifier que le cache est bien configuré
- name: Cache Maven
  uses: actions/cache@v4
  with:
    path: ~/.m2/repository
    key: ${{ runner.os }}-maven-${{ hashFiles('**/pom.xml') }}
```

## 📚 Commandes Utiles

### Voir les workflows en cours
```bash
gh workflow list
gh run list
```

### Déclencher un workflow via CLI
```bash
gh workflow run build-and-deploy-all.yml \
  -f environment=development \
  -f services=all \
  -f skip-tests=false
```

### Voir les logs d'un workflow
```bash
gh run view <run-id> --log
```

### Annuler un workflow en cours
```bash
gh run cancel <run-id>
```

## 🔗 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Jib Maven Plugin](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Setup Secrets](./GITHUB-SECRETS-SETUP.md)

## 🎓 Best Practices

1. **Toujours tester en develop avant main**
2. **Utiliser des PR pour review le code**
3. **Tagger les releases** (`git tag v1.2.3`)
4. **Monitorer les workflows** régulièrement
5. **Garder les workflows simples** et lisibles
6. **Documenter les changements** dans les commits
7. **Utiliser semantic versioning** (v1.2.3)
8. **Faire des rollbacks rapides** si nécessaire
9. **Activer les protections** sur main
10. **Require approvals** pour production

