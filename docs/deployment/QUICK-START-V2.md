# ⚡ Guide de Démarrage Rapide - Deploy Script V2

## 🚀 Installation et Configuration

### 1. Prérequis

```bash
# Vérifier les outils nécessaires
docker --version          # Docker 20.10+
docker-compose --version  # Docker Compose 1.29+
java -version            # Java 17
ssh -V                   # OpenSSH
```

### 2. Configuration Initiale

```bash
# Naviguer vers le dossier des scripts
cd /Users/seyfkaoueche/Documents/work/project/dealtobook/workspace/dealtobook-devops/scripts

# Créer votre fichier de configuration (ne pas commiter!)
cat > ~/.dealtobook-deploy.env << 'EOF'
# GitHub Container Registry
export CR_PAT="ghp_your_github_personal_access_token_here"
export GITHUB_USERNAME="skaouech"

# Environnement par défaut
export DEPLOY_ENV="development"  # ou "production"

# Serveurs (optionnel si valeurs par défaut OK)
export HOSTINGER_DEV_HOST="148.230.114.13"
export HOSTINGER_DEV_USER="root"
export HOSTINGER_PROD_HOST="148.230.114.13"
export HOSTINGER_PROD_USER="root"

# Timeouts (optionnel)
export DB_READY_TIMEOUT="60"
export KEYCLOAK_READY_TIMEOUT="90"
export SERVICE_STABILIZATION_TIMEOUT="30"
EOF

# Charger la configuration
source ~/.dealtobook-deploy.env
```

### 3. Configuration SSH

```bash
# Générer une clé SSH si nécessaire
ssh-keygen -t ed25519 -C "dealtobook-deploy" -f ~/.ssh/dealtobook_deploy

# Copier la clé sur le serveur
ssh-copy-id -i ~/.ssh/dealtobook_deploy.pub root@148.230.114.13

# Tester la connexion
ssh -i ~/.ssh/dealtobook_deploy root@148.230.114.13 "echo 'SSH OK'"
```

---

## 📋 Commandes Essentielles

### Déploiement Complet

```bash
# Development
export DEPLOY_ENV=development
source ~/.dealtobook-deploy.env
./deploy-ssl-production-v2.sh deploy

# Production
export DEPLOY_ENV=production
source ~/.dealtobook-deploy.env
./deploy-ssl-production-v2.sh deploy
```

### Build Seulement

```bash
# Tous les services
./deploy-ssl-production-v2.sh build

# Services spécifiques
./deploy-ssl-production-v2.sh build deal_security,deal_generator
./deploy-ssl-production-v2.sh build webui  # Utilise l'alias
```

### Gestion des Services

```bash
# Démarrer
./deploy-ssl-production-v2.sh start
./deploy-ssl-production-v2.sh start deal_generator

# Arrêter
./deploy-ssl-production-v2.sh stop
./deploy-ssl-production-v2.sh stop deal_security

# Redémarrer
./deploy-ssl-production-v2.sh restart
./deploy-ssl-production-v2.sh restart deal_webui,deal_website
```

### Monitoring

```bash
# Health check complet
./deploy-ssl-production-v2.sh health

# Status des conteneurs
./deploy-ssl-production-v2.sh ps

# Logs en temps réel
./deploy-ssl-production-v2.sh logs
./deploy-ssl-production-v2.sh logs deal_security
```

---

## 🎯 Scénarios Courants

### Scénario 1: Déployer un Hotfix

```bash
# 1. Créer et pousser votre hotfix sur GitHub
git checkout -b hotfix/security-patch
# ... faire vos modifications ...
git commit -m "Security patch"
git push origin hotfix/security-patch

# 2. Builder avec un tag custom
export CUSTOM_TAG="hotfix-security-patch"
source ~/.dealtobook-deploy.env
./deploy-ssl-production-v2.sh build deal_security

# 3. Déployer uniquement ce service
./deploy-ssl-production-v2.sh deploy-only deal_security

# 4. Vérifier
./deploy-ssl-production-v2.sh logs deal_security
./deploy-ssl-production-v2.sh health
```

### Scénario 2: Debug en Production

```bash
# 1. Inspecter le service
./deploy-ssl-production-v2.sh inspect deal_generator

# 2. Voir les logs récents
./deploy-ssl-production-v2.sh logs deal_generator

# 3. Accéder au conteneur
./deploy-ssl-production-v2.sh exec deal_generator bash

# Dans le conteneur:
ps aux                              # Processus
netstat -tuln                       # Ports
env | grep SPRING                   # Variables d'environnement
cat logs/spring.log | tail -100     # Logs applicatifs
```

### Scénario 3: Mise à Jour Progressive

```bash
# 1. Build toutes les nouvelles versions
export CUSTOM_TAG="v2.0.0"
./deploy-ssl-production-v2.sh build

# 2. Pull les images sur le serveur (sans restart)
./deploy-ssl-production-v2.sh pull

# 3. Déployer service par service
./deploy-ssl-production-v2.sh deploy-only deal_generator
sleep 60  # Attendre et monitorer
./deploy-ssl-production-v2.sh health

./deploy-ssl-production-v2.sh deploy-only deal_security
sleep 60
./deploy-ssl-production-v2.sh health

./deploy-ssl-production-v2.sh deploy-only deal_setting
sleep 60
./deploy-ssl-production-v2.sh health

# 4. Déployer les frontends
./deploy-ssl-production-v2.sh deploy-only deal_webui,deal_website
./deploy-ssl-production-v2.sh health
```

### Scénario 4: Rollback Rapide

```bash
# Redéployer la version précédente
export CUSTOM_TAG="v1.9.9"  # Version stable précédente
./deploy-ssl-production-v2.sh deploy-only

# Ou rollback un seul service
./deploy-ssl-production-v2.sh deploy-only deal_security
```

### Scénario 5: Test de Charge

```bash
# 1. Scaler les services
export DEPLOY_ENV=development
./deploy-ssl-production-v2.sh scale deal_generator 3
./deploy-ssl-production-v2.sh scale deal_security 3

# 2. Vérifier
./deploy-ssl-production-v2.sh ps

# 3. Lancer vos tests (externe)
# ... load testing ...

# 4. Monitorer les ressources
./deploy-ssl-production-v2.sh exec deal_generator top -b -n 1
./deploy-ssl-production-v2.sh logs deal_generator

# 5. Redescendre après les tests
./deploy-ssl-production-v2.sh scale deal_generator 1
./deploy-ssl-production-v2.sh scale deal_security 1
```

---

## 🔧 Alias Bash Pratiques

Ajoutez ces alias dans votre `~/.bashrc` ou `~/.zshrc`:

```bash
# Alias de base
alias dt-cd='cd /Users/seyfkaoueche/Documents/work/project/dealtobook/workspace/dealtobook-devops/scripts'
alias dt-source='source ~/.dealtobook-deploy.env'
alias dt-deploy='dt-cd && dt-source && ./deploy-ssl-production-v2.sh'

# Raccourcis pour commandes fréquentes
alias dt-dev='export DEPLOY_ENV=development && dt-source'
alias dt-prod='export DEPLOY_ENV=production && dt-source'
alias dt-logs='dt-deploy logs'
alias dt-health='dt-deploy health'
alias dt-ps='dt-deploy ps'
alias dt-restart='dt-deploy restart'

# Utilisation:
# dt-dev              # Passer en dev
# dt-deploy build     # Builder
# dt-logs webui       # Voir les logs du webui
# dt-health           # Health check
```

Après avoir ajouté ces alias:

```bash
# Recharger votre shell
source ~/.zshrc  # ou ~/.bashrc

# Exemples d'utilisation
dt-dev
dt-deploy build deal_security
dt-logs deal_security
dt-health
```

---

## 📊 Tableau de Référence Rapide

### Mapping des Services

| Nom Complet | Alias Courts | Description |
|-------------|--------------|-------------|
| `deal-generator` | `deal_generator`, `generator` | Service de génération de deals |
| `deal-security` | `deal_security`, `security` | Service de sécurité et auth |
| `deal-setting` | `deal_setting`, `setting` | Service de configuration |
| `deal-webui` | `deal_webui`, `webui`, `admin` | Interface d'administration |
| `deal-website` | `deal_website`, `website` | Site web public |
| `postgres` | `db`, `postgresql` | Base de données PostgreSQL |
| `keycloak` | `keycloak` | Serveur d'authentification |
| `nginx` | `nginx` | Reverse proxy |
| `redis` | `redis` | Cache Redis |

### Commandes par Catégorie

#### 🏗️ Build & Deploy
| Commande | Description | Exemple |
|----------|-------------|---------|
| `build` | Build et push vers GHCR | `./... build deal_security` |
| `build-only` | Build sans déployer | `./... build-only` |
| `deploy` | Déploiement complet | `./... deploy` |
| `deploy-only` | Deploy sans rebuild | `./... deploy-only webui` |
| `update` | Build + redeploy sélectif | `./... update generator` |
| `redeploy` | Redeploy rapide | `./... redeploy` |

#### 🔧 Gestion Services
| Commande | Description | Exemple |
|----------|-------------|---------|
| `start` | Démarrer | `./... start security` |
| `stop` | Arrêter | `./... stop webui` |
| `restart` | Redémarrer | `./... restart` |
| `down` | Tout arrêter | `./... down` |
| `pull` | Télécharger images | `./... pull` |
| `scale` | Scaler un service | `./... scale generator 3` |

#### 📊 Monitoring
| Commande | Description | Exemple |
|----------|-------------|---------|
| `ps` / `list` | Liste conteneurs | `./... ps` |
| `logs` | Voir les logs | `./... logs deal_security` |
| `health` | Health check | `./... health` |
| `status` | Status du deploy | `./... status` |
| `inspect` | Inspecter service | `./... inspect generator` |

#### 🛠️ Avancé
| Commande | Description | Exemple |
|----------|-------------|---------|
| `exec` | Exécuter commande | `./... exec db psql -U dealtobook` |
| `ssl-setup` | Config SSL | `./... ssl-setup` |
| `config` | Deploy config seule | `./... config` |
| `test-ssl` | Tester HTTPS | `./... test-ssl` |

---

## ⚠️ Points d'Attention

### Sécurité

```bash
# ❌ JAMAIS faire ça
export CR_PAT="ghp_xyz123"
git add ~/.bashrc
git commit -m "Add deploy config"  # Le token sera commité!

# ✅ Toujours faire ça
echo "export CR_PAT='ghp_xyz123'" > ~/.dealtobook-deploy.env
echo "~/.dealtobook-deploy.env" >> ~/.gitignore
source ~/.dealtobook-deploy.env
```

### Performance

```bash
# ❌ Éviter: Build complet à chaque fois
./deploy-ssl-production-v2.sh deploy  # ~15 minutes

# ✅ Préférer: Build sélectif + deploy rapide
./deploy-ssl-production-v2.sh build deal_security        # ~3 minutes
./deploy-ssl-production-v2.sh deploy-only deal_security  # ~1 minute
```

### Production

```bash
# ❌ Éviter: Deploy direct en prod sans tests
export DEPLOY_ENV=production
./deploy-ssl-production-v2.sh deploy

# ✅ Préférer: Tester en dev d'abord
export DEPLOY_ENV=development
./deploy-ssl-production-v2.sh deploy
./deploy-ssl-production-v2.sh health  # Vérifier
# ... Tests manuels/automatiques ...

# Puis deploy en prod
export DEPLOY_ENV=production
./deploy-ssl-production-v2.sh deploy
```

---

## 🐛 Troubleshooting Rapide

### Problème: "Command not found"

```bash
# Solution: Rendre le script exécutable
chmod +x deploy-ssl-production-v2.sh
```

### Problème: "SSH connection failed"

```bash
# Vérifier la connexion SSH
ssh root@148.230.114.13 "echo SSH OK"

# Vérifier les clés SSH
ssh-add -l

# Re-copier la clé si nécessaire
ssh-copy-id root@148.230.114.13
```

### Problème: "Docker login failed"

```bash
# Vérifier le token GHCR
echo $CR_PAT  # Doit afficher votre token

# Tester la connexion manuellement
echo "$CR_PAT" | docker login ghcr.io -u $GITHUB_USERNAME --password-stdin

# Régénérer un token si nécessaire sur GitHub
# Settings → Developer settings → Personal access tokens → Generate new token
# Permissions: write:packages, read:packages, delete:packages
```

### Problème: "Java 17 not found"

```bash
# Sur macOS avec Homebrew
brew install openjdk@17
sudo ln -sfn $(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk \
    /Library/Java/JavaVirtualMachines/openjdk-17.jdk

# Vérifier
/usr/libexec/java_home -V
java -version
```

### Problème: "Build failed"

```bash
# Voir les détails de l'erreur
cd ../dealtobook-deal_security
./mvnw clean compile -X  # Mode debug Maven

# Vérifier les dépendances
./mvnw dependency:tree

# Nettoyer le cache Maven
./mvnw clean
rm -rf ~/.m2/repository/com/dealtobook
```

---

## 📚 Ressources

### Documentation Complète

- [DEPLOY-SCRIPT-V2-IMPROVEMENTS.md](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md) - Documentation détaillée
- [deploy-ssl-production-v2.sh](./scripts/deploy-ssl-production-v2.sh) - Script principal

### Liens Utiles

- GitHub Packages: https://github.com/skaouech?tab=packages
- Docker Hub: https://hub.docker.com/
- Let's Encrypt: https://letsencrypt.org/

### Support

- Issues GitHub: https://github.com/skaouech/dealtobook/issues
- Slack: #devops-support
- Email: devops@dealtobook.com

---

## ✅ Checklist de Déploiement

### Avant le Déploiement

- [ ] Code mergé et testé localement
- [ ] Tests unitaires passent
- [ ] Variables d'environnement configurées
- [ ] Connexion SSH testée
- [ ] Token GHCR valide
- [ ] Java 17 installé
- [ ] Docker et Docker Compose fonctionnels

### Pendant le Déploiement

- [ ] Build réussi sans erreurs
- [ ] Images poussées vers GHCR
- [ ] Configuration transférée
- [ ] Services démarrés
- [ ] Health check OK

### Après le Déploiement

- [ ] Endpoints HTTPS accessibles
- [ ] Logs sans erreurs critiques
- [ ] Monitoring actif (Grafana, Prometheus)
- [ ] Tests fonctionnels OK
- [ ] Performance acceptable
- [ ] Documentation mise à jour

---

## 🎓 Prochaines Étapes

1. **Tester en Development**
   ```bash
   dt-dev
   dt-deploy deploy
   ```

2. **Maîtriser les Commandes de Base**
   ```bash
   dt-deploy ps
   dt-deploy logs
   dt-deploy health
   ```

3. **Explorer les Commandes Avancées**
   ```bash
   dt-deploy scale deal_generator 2
   dt-deploy inspect deal_security
   dt-deploy exec postgres psql
   ```

4. **Automatiser avec Scripts**
   - Créer vos propres scripts de déploiement
   - Intégrer dans CI/CD
   - Ajouter des tests automatiques

5. **Contribuer**
   - Proposer des améliorations
   - Signaler des bugs
   - Partager vos cas d'usage

---

**Bon déploiement ! 🚀**

