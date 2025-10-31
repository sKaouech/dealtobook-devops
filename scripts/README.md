# 📜 Scripts de Déploiement

Scripts pour le déploiement et la gestion de l'infrastructure DealToBook.

---

## 🎯 Script Principal

### deploy-ssl-production-v2.sh

Script de déploiement complet avec support SSL/HTTPS, multi-environnement (dev/prod), et flexibilité maximale.

**Documentation complète** : [../docs/deployment/](../docs/deployment/)

#### Utilisation de Base

```bash
# Aide
./deploy-ssl-production-v2.sh help

# Déployer en development
export DEPLOY_ENV=development
./deploy-ssl-production-v2.sh deploy

# Déployer en production
export DEPLOY_ENV=production
./deploy-ssl-production-v2.sh deploy
```

#### Commandes Disponibles

| Commande | Description |
|----------|-------------|
| `build` | Construire et pousser images vers GHCR |
| `deploy` | Déploiement complet |
| `start/stop/restart` | Gérer les services |
| `scale <service> <n>` | Scaler un service |
| `exec <service> <cmd>` | Exécuter commande dans conteneur |
| `inspect <service>` | Inspecter un service |
| `logs [service]` | Voir les logs |
| `health` | Health check |
| `ps` | Liste des conteneurs |

**Voir documentation** : [QUICK-START-V2.md](../docs/deployment/QUICK-START-V2.md)

---

## 🧪 Tests

### test-deploy-v2.sh

Suite de tests automatisés pour valider le script de déploiement.

```bash
./test-deploy-v2.sh
```

---

## 🛠️ Scripts Utilitaires (tools/)

### configure-keycloak-theme.sh
Configure le thème personnalisé Keycloak.

```bash
./tools/configure-keycloak-theme.sh
```

### fix-keycloak-clients.sh
Répare la configuration des clients Keycloak.

```bash
./tools/fix-keycloak-clients.sh
```

### init-multiple-databases.sh
Initialise les bases de données PostgreSQL.

```bash
./tools/init-multiple-databases.sh
```

### migrate-postgres-azure-to-hostinger.sh
Migre les données PostgreSQL d'Azure vers Hostinger.

```bash
./tools/migrate-postgres-azure-to-hostinger.sh
```

### test-postgres-connectivity.sh
Teste la connectivité PostgreSQL.

```bash
./tools/test-postgres-connectivity.sh
```

---

## 📦 Scripts Legacy (legacy/)

Scripts obsolètes conservés pour référence historique.

### deploy-ssl-production.sh (V1)
Version 1 du script de déploiement (remplacée par V2).

### deploy-ghcr-production.sh
Ancien script de déploiement GHCR (fusionné dans V2).

### test-ghcr-deployment.sh
Anciens tests GHCR (remplacés par test-deploy-v2.sh).

**⚠️ Ces scripts ne doivent plus être utilisés. Utilisez V2.**

---

## 📁 Structure

```
scripts/
├── deploy-ssl-production-v2.sh    # ⭐ Script principal
├── test-deploy-v2.sh              # 🧪 Tests
├── README.md                      # 📖 Ce fichier
│
├── legacy/                        # 📦 Scripts obsolètes (V1)
│   ├── deploy-ssl-production.sh
│   ├── deploy-ghcr-production.sh
│   └── test-ghcr-deployment.sh
│
└── tools/                         # 🛠️ Scripts utilitaires
    ├── configure-keycloak-theme.sh
    ├── fix-keycloak-clients.sh
    ├── init-multiple-databases.sh
    ├── migrate-postgres-azure-to-hostinger.sh
    ├── test-postgres-connectivity.sh
    ├── pg_hba.conf
    └── postgresql.conf
```

---

## ⚡ Exemples d'Utilisation

### Déploiement Complet

```bash
# Configuration
export DEPLOY_ENV=development
export CR_PAT="your_github_token"

# Déploiement
./deploy-ssl-production-v2.sh deploy
```

### Déployer un Service Spécifique

```bash
./deploy-ssl-production-v2.sh build deal_security
./deploy-ssl-production-v2.sh deploy-only deal_security
```

### Debug

```bash
# Inspecter
./deploy-ssl-production-v2.sh inspect deal_generator

# Logs
./deploy-ssl-production-v2.sh logs deal_security

# Shell dans conteneur
./deploy-ssl-production-v2.sh exec deal_generator bash
```

### Scaling

```bash
# Scaler à 3 replicas
./deploy-ssl-production-v2.sh scale deal_generator 3

# Vérifier
./deploy-ssl-production-v2.sh ps

# Revenir à 1
./deploy-ssl-production-v2.sh scale deal_generator 1
```

---

## 🔑 Variables d'Environnement

### Obligatoires

```bash
export CR_PAT="your_github_token"
export DEPLOY_ENV="development|production"
```

### Optionnelles

```bash
export CUSTOM_TAG="v1.2.3"
export DB_READY_TIMEOUT="60"
export KEYCLOAK_READY_TIMEOUT="90"
export SERVICE_STABILIZATION_TIMEOUT="30"
```

---

## 📚 Documentation

- **Quick Start** : [../docs/deployment/QUICK-START-V2.md](../docs/deployment/QUICK-START-V2.md)
- **Documentation Complète** : [../docs/deployment/DEPLOY-SCRIPT-V2-IMPROVEMENTS.md](../docs/deployment/DEPLOY-SCRIPT-V2-IMPROVEMENTS.md)
- **Migration V1→V2** : [../docs/deployment/MIGRATION-V1-TO-V2.md](../docs/deployment/MIGRATION-V1-TO-V2.md)
- **Index** : [../docs/deployment/INDEX-DOCUMENTATION-V2.md](../docs/deployment/INDEX-DOCUMENTATION-V2.md)

---

## 🐛 Troubleshooting

### Script ne démarre pas

```bash
# Vérifier permissions
chmod +x deploy-ssl-production-v2.sh

# Vérifier syntaxe
bash -n deploy-ssl-production-v2.sh
```

### Erreur "unbound variable"

Le script est maintenant compatible bash 3.x (macOS).  
Voir : [HOTFIX-BASH3-COMPATIBILITY.md](../docs/deployment/HOTFIX-BASH3-COMPATIBILITY.md)

### SSH échoue

```bash
# Tester connexion
ssh root@148.230.114.13 "echo SSH OK"

# Copier clé si nécessaire
ssh-copy-id root@148.230.114.13
```

---

## 🆘 Support

- Documentation : [../docs/](../docs/)
- Slack : `#devops-support`
- Email : `devops@dealtobook.com`

---

**Prêt à déployer ? Consultez le [Quick Start](../docs/deployment/QUICK-START-V2.md) ! 🚀**

