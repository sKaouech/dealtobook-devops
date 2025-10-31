# 🚀 Deploy Script V2 - README

## 📖 Vue d'Ensemble

Script de déploiement amélioré pour l'application DealToBook avec gestion SSL/HTTPS, support multi-environnement (dev/prod), et flexibilité maximale pour les opérations DevOps.

---

## 🎯 Nouveautés Version 2.0

### ✨ 9 Nouvelles Commandes

| Commande | Description | Exemple |
|----------|-------------|---------|
| `pull` | Télécharger images sans restart | `./deploy-ssl-production-v2.sh pull` |
| `scale` | Scaler un service dynamiquement | `./deploy-ssl-production-v2.sh scale generator 3` |
| `exec` | Exécuter commande dans conteneur | `./deploy-ssl-production-v2.sh exec postgres psql` |
| `inspect` | Inspection détaillée d'un service | `./deploy-ssl-production-v2.sh inspect security` |
| Et plus... | Voir la documentation complète | |

### 🔧 Améliorations Majeures

- ✅ **Tags personnalisés**: Déployer des versions spécifiques avec `CUSTOM_TAG`
- ✅ **Timeouts configurables**: Adapter les délais à votre environnement
- ✅ **Mapping centralisé**: Alias naturels pour les services (`admin` → `deal-webui`)
- ✅ **Gestion d'erreurs stricte**: `set -euo pipefail` pour plus de robustesse
- ✅ **Code DRY**: Pas de duplication, maintenance simplifiée
- ✅ **100% compatible V1**: Migration sans risque

---

## 📚 Documentation

### Fichiers Disponibles

| Fichier | Description | Pour qui ? |
|---------|-------------|------------|
| **[QUICK-START-V2.md](./QUICK-START-V2.md)** | Guide de démarrage rapide | 👨‍💻 Tous |
| **[DEPLOY-SCRIPT-V2-IMPROVEMENTS.md](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md)** | Documentation technique détaillée | 🔧 DevOps |
| **[MIGRATION-V1-TO-V2.md](./MIGRATION-V1-TO-V2.md)** | Guide de migration depuis V1 | 🔄 Équipes existantes |
| **[README-DEPLOY-V2.md](./README-DEPLOY-V2.md)** | Ce fichier - Vue d'ensemble | 📖 Tous |

### Ordre de Lecture Recommandé

1. **Débutants**: Commencer par `QUICK-START-V2.md`
2. **Utilisateurs V1**: Lire `MIGRATION-V1-TO-V2.md`
3. **DevOps/Experts**: Consulter `DEPLOY-SCRIPT-V2-IMPROVEMENTS.md`

---

## ⚡ Démarrage Rapide

### Installation (5 minutes)

```bash
# 1. Naviguer vers les scripts
cd dealtobook-devops/scripts

# 2. Rendre exécutable
chmod +x deploy-ssl-production-v2.sh

# 3. Configurer l'environnement
cat > ~/.dealtobook-deploy.env << 'EOF'
export CR_PAT="your_github_token"
export DEPLOY_ENV="development"
export GITHUB_USERNAME="skaouech"
EOF

# 4. Charger la configuration
source ~/.dealtobook-deploy.env

# 5. Tester
./deploy-ssl-production-v2.sh help
```

### Premier Déploiement (30 minutes)

```bash
# Development
export DEPLOY_ENV=development
source ~/.dealtobook-deploy.env
./deploy-ssl-production-v2.sh deploy

# Production (après tests en dev)
export DEPLOY_ENV=production
./deploy-ssl-production-v2.sh deploy
```

---

## 🎓 Exemples Courants

### Déployer un Service Spécifique

```bash
# Build et deploy d'un seul service
./deploy-ssl-production-v2.sh build deal_security
./deploy-ssl-production-v2.sh deploy-only deal_security

# Ou avec alias
./deploy-ssl-production-v2.sh build security
./deploy-ssl-production-v2.sh deploy-only security
```

### Debug en Production

```bash
# Inspecter un service
./deploy-ssl-production-v2.sh inspect deal_generator

# Voir les logs
./deploy-ssl-production-v2.sh logs deal_generator

# Accéder au conteneur
./deploy-ssl-production-v2.sh exec deal_generator bash
```

### Déployer une Version Spécifique

```bash
# Déployer une release
export CUSTOM_TAG="v1.2.3"
./deploy-ssl-production-v2.sh deploy

# Déployer un hotfix
export CUSTOM_TAG="hotfix-security"
./deploy-ssl-production-v2.sh build deal_security
./deploy-ssl-production-v2.sh deploy-only deal_security
```

### Tests de Charge

```bash
# Scaler pour les tests
./deploy-ssl-production-v2.sh scale deal_generator 5

# Vérifier
./deploy-ssl-production-v2.sh ps

# Revenir à la normale
./deploy-ssl-production-v2.sh scale deal_generator 1
```

---

## 📋 Toutes les Commandes

### Build & Deploy
- `build` - Build et push vers GHCR
- `build-only` - Build sans déployer
- `deploy` - Déploiement complet
- `deploy-only` - Deploy sans rebuild
- `update` - Build + redeploy sélectif
- `redeploy` - Redeploy rapide

### Gestion Services
- `start` - Démarrer
- `stop` - Arrêter
- `restart` - Redémarrer
- `down` - Tout arrêter
- `pull` - ✨ Télécharger images
- `scale` - ✨ Scaler un service

### Monitoring
- `ps` / `list` - Liste conteneurs
- `logs` - Voir logs
- `health` - Health check
- `status` - Status
- `inspect` - ✨ Inspection détaillée

### Avancé
- `exec` - ✨ Exécuter commande
- `ssl-setup` - Config SSL
- `config` - Deploy config
- `test-ssl` - Tester HTTPS

---

## 🎯 Services et Alias

### Backend

| Nom Complet | Alias | Description |
|-------------|-------|-------------|
| `deal-generator` | `generator`, `deal_generator` | Service génération |
| `deal-security` | `security`, `deal_security` | Service sécurité |
| `deal-setting` | `setting`, `deal_setting` | Service configuration |

### Frontend

| Nom Complet | Alias | Description |
|-------------|-------|-------------|
| `deal-webui` | `webui`, `admin` | Interface admin |
| `deal-website` | `website` | Site web public |

### Infrastructure

| Nom Complet | Alias | Description |
|-------------|-------|-------------|
| `postgres` | `db`, `postgresql` | Base de données |
| `keycloak` | `keycloak` | Authentification |
| `nginx` | `nginx` | Reverse proxy |
| `redis` | `redis` | Cache |

---

## 🔐 Variables d'Environnement

### Obligatoires

```bash
export CR_PAT="your_github_token"        # Token GitHub pour GHCR
export DEPLOY_ENV="development|production"  # Environnement
```

### Optionnelles

```bash
# Tags personnalisés
export CUSTOM_TAG="v1.2.3"

# Timeouts (secondes)
export DB_READY_TIMEOUT="60"
export KEYCLOAK_READY_TIMEOUT="90"
export SERVICE_STABILIZATION_TIMEOUT="30"

# Serveurs (si différents des défauts)
export HOSTINGER_DEV_HOST="148.230.114.13"
export HOSTINGER_DEV_USER="root"
export HOSTINGER_PROD_HOST="148.230.114.13"
export HOSTINGER_PROD_USER="root"

# Autres
export GITHUB_USERNAME="skaouech"
export REGISTRY="ghcr.io"
```

---

## 🚨 Troubleshooting Rapide

### Script ne s'exécute pas

```bash
chmod +x deploy-ssl-production-v2.sh
```

### SSH échoue

```bash
ssh root@148.230.114.13 "echo SSH OK"
ssh-copy-id root@148.230.114.13
```

### Build échoue

```bash
# Vérifier Java 17
java -version

# Nettoyer le cache
cd ../dealtobook-deal_security
./mvnw clean
```

### Service not found

```bash
# Utiliser un nom ou alias valide
./deploy-ssl-production-v2.sh ps  # Voir tous les services
./deploy-ssl-production-v2.sh restart generator  # Utiliser alias
```

---

## 📊 Comparaison V1 vs V2

| Critère | V1 | V2 | Amélioration |
|---------|----|----|--------------|
| Commandes | 13 | 22 | **+69%** |
| Bugs connus | Ligne 754 vide | Corrigé | ✅ |
| Code dupliqué | Oui | Non | ✅ |
| Tags custom | ❌ | ✅ | ✅ |
| Scale services | ❌ | ✅ | ✅ |
| Exec dans conteneurs | ❌ | ✅ | ✅ |
| Inspect détaillé | ❌ | ✅ | ✅ |
| Timeouts configurables | ❌ | ✅ | ✅ |
| Alias services | ❌ | ✅ | ✅ |
| Compatibilité V1 | N/A | 100% | ✅ |

---

## 🎯 Cas d'Usage

### Développeur Frontend

```bash
# Build et deploy du frontend
./deploy-ssl-production-v2.sh build webui
./deploy-ssl-production-v2.sh deploy-only webui
./deploy-ssl-production-v2.sh logs webui
```

### Développeur Backend

```bash
# Build et deploy d'un microservice
./deploy-ssl-production-v2.sh build security
./deploy-ssl-production-v2.sh deploy-only security
./deploy-ssl-production-v2.sh inspect security
```

### DevOps

```bash
# Déploiement complet avec tag
export CUSTOM_TAG="v2.0.0"
./deploy-ssl-production-v2.sh deploy

# Monitoring
./deploy-ssl-production-v2.sh health
./deploy-ssl-production-v2.sh ps

# Scaling pour événements
./deploy-ssl-production-v2.sh scale generator 5
```

### DBA

```bash
# Accès base de données
./deploy-ssl-production-v2.sh exec postgres psql -U dealtobook

# Backup
./deploy-ssl-production-v2.sh exec postgres \
    pg_dump -U dealtobook dealtobook_db > backup.sql

# Vérifier connexions
./deploy-ssl-production-v2.sh exec postgres \
    psql -U dealtobook -c "SELECT * FROM pg_stat_activity;"
```

---

## 🔗 Liens Utiles

### Documentation
- [Quick Start](./QUICK-START-V2.md)
- [Guide Complet](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md)
- [Migration V1→V2](./MIGRATION-V1-TO-V2.md)

### Ressources Externes
- [GitHub Packages](https://github.com/skaouech?tab=packages)
- [Docker Documentation](https://docs.docker.com/)
- [Let's Encrypt](https://letsencrypt.org/)

### Support
- Slack: `#devops-support`
- Email: `devops@dealtobook.com`
- Issues: [GitHub Issues](https://github.com/skaouech/dealtobook/issues)

---

## 🤝 Contribution

### Reporter un Bug

```bash
# Collecter les informations
./deploy-ssl-production-v2.sh health > debug-info.txt
./deploy-ssl-production-v2.sh ps >> debug-info.txt

# Envoyer avec:
# - Commande exacte utilisée
# - Message d'erreur complet
# - Fichier debug-info.txt
# - Version du script (ligne 1-5)
```

### Proposer une Amélioration

1. Fork le repository
2. Créer une branche: `git checkout -b feature/ma-fonctionnalite`
3. Commiter: `git commit -m 'Add: nouvelle fonctionnalité'`
4. Push: `git push origin feature/ma-fonctionnalite`
5. Créer une Pull Request

---

## 📜 Changelog

### Version 2.0.0 (2025-10-28)

**Nouvelles fonctionnalités:**
- ✨ 9 nouvelles commandes (pull, scale, exec, inspect, etc.)
- ✨ Support tags personnalisés
- ✨ Timeouts configurables
- ✨ Mapping centralisé avec alias
- ✨ Gestion d'erreurs stricte

**Corrections:**
- 🐛 Ligne 754 vide supprimée
- 🐛 Domaines SSL dynamiques
- 🐛 Validation des builds

**Améliorations:**
- 📚 Documentation complète
- 🧹 Code DRY (pas de duplication)
- 🔒 Sécurité renforcée
- ⚡ Performance optimisée

---

## 📄 Licence

© 2025 DealToBook - Tous droits réservés

---

## 👥 Auteurs

**DevOps Team**
- Lead: DevOps Engineer
- Date: 2025-10-28
- Version: 2.0.0

---

## ⭐ Quick Links

- 🚀 [Démarrage Rapide](./QUICK-START-V2.md)
- 📖 [Documentation Complète](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md)
- 🔄 [Guide de Migration](./MIGRATION-V1-TO-V2.md)
- 🐛 [Troubleshooting](./QUICK-START-V2.md#-troubleshooting-rapide)
- 💡 [Exemples d'Usage](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md#-cas-dusage-avancés)

---

**Prêt à déployer ? 🚀**

```bash
source ~/.dealtobook-deploy.env
./deploy-ssl-production-v2.sh deploy
```

