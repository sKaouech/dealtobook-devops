# 🚀 DealToBook DevOps

Infrastructure et scripts de déploiement pour l'application DealToBook.

---

## 📖 Documentation

### 🏁 Démarrage Rapide
- **[START-HERE-V2.md](./START-HERE-V2.md)** - Point d'entrée principal

### 📦 Déploiement
- **[Quick Start](./docs/deployment/QUICK-START-V2.md)** - Guide de démarrage rapide (30 min)
- **[README Deploy V2](./docs/deployment/README-DEPLOY-V2.md)** - Vue d'ensemble complète
- **[Migration V1→V2](./docs/deployment/MIGRATION-V1-TO-V2.md)** - Guide de migration
- **[Documentation Technique](./docs/deployment/DEPLOY-SCRIPT-V2-IMPROVEMENTS.md)** - Détails complets
- **[Index](./docs/deployment/INDEX-DOCUMENTATION-V2.md)** - Navigation complète

### 📚 Guides
- [Configuration SSL](./docs/guides/GUIDE-SSL-CONFIGURATION.md)
- [Thème Keycloak](./docs/guides/GUIDE-THEME-KEYCLOAK.md)
- [Migration PostgreSQL](./docs/guides/GUIDE-MIGRATION-POSTGRES.md)
- [Connexion PostgreSQL](./docs/guides/GUIDE-CONNEXION-POSTGRES.md)
- [Test Responsive](./docs/guides/GUIDE-TEST-RESPONSIVE.md)
- [Et plus...](./docs/guides/)

### 🔧 Troubleshooting
- [Erreur 502](./docs/troubleshooting/RESOLUTION-502-ERROR.md)
- [Erreur Feign](./docs/troubleshooting/RESOLUTION-FEIGN-ERROR.md)
- [Dépannage Keycloak](./docs/guides/GUIDE-DEPANNAGE-KEYCLOAK.md)

---

## 🛠️ Scripts

### Script Principal
```bash
cd scripts/
./deploy-ssl-production-v2.sh help
```

### Documentation Scripts
Voir [scripts/README.md](./scripts/README.md) pour la documentation complète.

---

## 📁 Structure du Projet

```
dealtobook-devops/
├── README.md                    # Ce fichier
├── START-HERE-V2.md             # Point d'entrée
│
├── docs/                        # Documentation
│   ├── deployment/              # Docs déploiement V2
│   ├── guides/                  # Guides spécifiques
│   ├── troubleshooting/         # Résolution problèmes
│   └── archive/                 # Docs obsolètes
│
├── scripts/                     # Scripts de déploiement
│   ├── deploy-ssl-production-v2.sh  # Script principal
│   ├── test-deploy-v2.sh        # Tests
│   ├── legacy/                  # Scripts obsolètes
│   └── tools/                   # Scripts utilitaires
│
├── config/                      # Configuration
│   ├── docker-compose.ssl-complete.yml
│   ├── dealtobook-ssl.env
│   ├── nginx/
│   ├── monitoring/
│   └── keycloak-themes/
│
└── backups/                     # Sauvegardes
```

---

## ⚡ Démarrage Rapide (2 minutes)

### 1. Configuration

```bash
# Créer votre fichier de configuration
cat > ~/.dealtobook-deploy.env << 'EOF'
export CR_PAT="your_github_token"
export DEPLOY_ENV="development"
export GITHUB_USERNAME="skaouech"
EOF

# Charger la configuration
source ~/.dealtobook-deploy.env
```

### 2. Premier Déploiement

```bash
# Naviguer vers les scripts
cd scripts/

# Voir l'aide
./deploy-ssl-production-v2.sh help

# Déployer en development
./deploy-ssl-production-v2.sh deploy
```

---

## 🎯 Cas d'Usage Courants

### Déployer un Service Spécifique

```bash
./scripts/deploy-ssl-production-v2.sh build deal_security
./scripts/deploy-ssl-production-v2.sh deploy-only deal_security
```

### Debug en Production

```bash
./scripts/deploy-ssl-production-v2.sh inspect deal_generator
./scripts/deploy-ssl-production-v2.sh logs deal_security
./scripts/deploy-ssl-production-v2.sh exec postgres psql -U dealtobook
```

### Scaler un Service

```bash
./scripts/deploy-ssl-production-v2.sh scale deal_generator 3
./scripts/deploy-ssl-production-v2.sh ps
```

---

## 🔑 Variables d'Environnement

### Obligatoires
```bash
export CR_PAT="your_github_token"          # Token GitHub pour GHCR
export DEPLOY_ENV="development|production" # Environnement cible
```

### Optionnelles
```bash
export CUSTOM_TAG="v1.2.3"                 # Tag personnalisé
export DB_READY_TIMEOUT="60"               # Timeouts configurables
export KEYCLOAK_READY_TIMEOUT="90"
```

---

## 📊 Services Disponibles

### Backend
- `deal-generator` (alias: `generator`, `deal_generator`)
- `deal-security` (alias: `security`, `deal_security`)
- `deal-setting` (alias: `setting`, `deal_setting`)

### Frontend
- `deal-webui` (alias: `webui`, `admin`)
- `deal-website` (alias: `website`)

### Infrastructure
- `postgres` (alias: `db`)
- `keycloak`
- `nginx`
- `redis`

---

## 🆘 Support

### Documentation
- [Quick Start](./docs/deployment/QUICK-START-V2.md)
- [Troubleshooting](./docs/troubleshooting/)
- [Guides](./docs/guides/)

### Contact
- Slack: `#devops-support`
- Email: `devops@dealtobook.com`

---

## 📝 Changelog

### Version 2.0.1 (2025-10-28)
- ✅ Hotfix compatibilité bash 3.x (macOS)
- ✅ Organisation et nettoyage de la documentation
- ✅ Structure de dossiers claire

### Version 2.0.0 (2025-10-28)
- ✨ 9 nouvelles commandes (pull, scale, exec, inspect, etc.)
- ✨ Tags personnalisés et timeouts configurables
- ✨ Mapping centralisé avec alias de services
- 🐛 Corrections de bugs V1
- 📚 Documentation complète

---

## 📄 Licence

© 2025 DealToBook - Tous droits réservés

---

**Prêt à déployer ? Commencez par [START-HERE-V2.md](./START-HERE-V2.md) ! 🚀**
