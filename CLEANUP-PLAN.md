# 🧹 Plan de Nettoyage - dealtobook-devops

Analyse effectuée le: 2025-10-31

## 📊 Analyse du Repository

### ✅ Fichiers Essentiels (À GARDER)

#### Configuration Active
- `config/docker-compose.ssl-complete.yml` ✅ Utilisé
- `config/docker-compose.ghcr-complete.yml` ✅ Utilisé
- `config/*.env` ✅ Environnements
- `config/scripts/*.sh` ✅ Scripts PostgreSQL actifs
- `config/nginx/*.conf` ✅ Configurations Nginx
- `config/keycloak-themes/` ✅ Thèmes Keycloak
- `config/monitoring/` ✅ Prometheus/Grafana

#### Scripts Actifs
- `scripts/deploy-ssl-production-v2.sh` ✅ Script principal de déploiement
- `scripts/diagnose-502.sh` ✅ Diagnostic utile
- `scripts/test-deploy-v2.sh` ✅ Tests
- `scripts/tools/sync-keycloak-themes.sh` ✅ Nouveau, utilisé
- `scripts/tools/verify-and-reload-keycloak-theme.sh` ✅ Utilisé
- `scripts/tools/quick-reload-keycloak-theme.sh` ✅ Utilisé
- `scripts/tools/fix-keycloak-clients.sh` ✅ Utile
- `scripts/tools/test-postgres-connectivity.sh` ✅ Diagnostic
- `scripts/tools/migrate-postgres-azure-to-hostinger.sh` ✅ Migration

#### Documentation Active
- `README.md` ✅ Point d'entrée principal
- `START-HERE-V2.md` ✅ Guide de démarrage
- `docs/cicd/*` ✅ **NOUVELLE** documentation CI/CD
- `docs/deployment/*` ✅ Guides de déploiement V2
- `docs/guides/*` ✅ Guides pratiques
- `docs/troubleshooting/*` ✅ Résolution de problèmes

### ❌ Fichiers Obsolètes (À SUPPRIMER)

#### 1. Racine du Projet
```
❌ fix-security-hazelcast.sh              [Déjà intégré dans le code]
❌ github-workflow-orchestration.yml      [Remplacé par nouveaux workflows]
❌ ORGANIZATION-COMPLETE.md               [Doc temporaire obsolète]
❌ sync-from-hostinger.sh                 [À vérifier utilisation]
❌ sync-to-hostinger.sh                   [À vérifier utilisation]
❌ dealtobook-devops.iml                  [Fichier IDE, devrait être en .gitignore]
```

#### 2. Documentation Obsolète
```
❌ docs/CICD-ARCHITECTURE.md              [Dupliqué dans docs/cicd/ARCHITECTURE.md]
❌ docs/CLEANUP-AND-CICD-PLAN.md          [Plan obsolète]
❌ docs/GUIDE-FINALISATION-CICD.md        [Obsolète, remplacé par docs/cicd/]
❌ docs/GUIDE-RELOAD-KEYCLOAK-THEME.md    [Obsolète, scripts tools/ existent]
❌ docs/RESOLUTION-FEIGN-ERROR.md         [Déplacé dans troubleshooting/]
```

#### 3. Scripts Legacy (Anciens)
```
❌ scripts/legacy/configure-keycloak-theme-fixed.sh
❌ scripts/legacy/deploy-ghcr-production.sh
❌ scripts/legacy/deploy-ssl-production.sh
❌ scripts/legacy/setup-cicd-files.sh
❌ scripts/legacy/test-ghcr-deployment.sh
```

#### 4. Doublons dans scripts/tools/
```
❌ scripts/tools/init-multiple-databases.sh    [Dupliqué de config/scripts/]
❌ scripts/tools/pg_hba.conf                   [Dupliqué de config/scripts/]
❌ scripts/tools/postgresql.conf               [Dupliqué de config/scripts/]
❌ scripts/tools/configure-keycloak-theme.sh   [Remplacé par sync/verify]
```

### ⚠️ Fichiers à Évaluer

#### Archives (Optionnel)
```
⚠️  docs/archive/*   [Garder pour historique OU supprimer si espace nécessaire]
    - DEPLOYMENT-STATUS-FINAL.md
    - README-GHCR-DEPLOYMENT.md
    - REDEPLOY-FINAL-SUCCESS.md
    - REPONSE-COMPLETE-GHCR.md
    - SCRIPT-SSL-UPGRADE-SUCCESS.md
    - STRUCTURE-FINALE-NETTOYEE.md
    - SUMMARY-V2-CREATION.md
    - THEME-SIMPLE-MODERNE.md
```

#### Backups
```
⚠️  backups/postgres-migration-20251003-234031/  [Backup ancien - à archiver ailleurs?]
```

## 🎯 Recommandations de Nettoyage

### Phase 1: Nettoyage Sûr (Aucun Risque)
```bash
# Supprimer les scripts legacy
rm -rf scripts/legacy/

# Supprimer les doublons dans tools/
rm scripts/tools/init-multiple-databases.sh
rm scripts/tools/pg_hba.conf
rm scripts/tools/postgresql.conf
rm scripts/tools/configure-keycloak-theme.sh

# Supprimer docs obsolètes
rm docs/CICD-ARCHITECTURE.md
rm docs/CLEANUP-AND-CICD-PLAN.md
rm docs/GUIDE-FINALISATION-CICD.md
rm docs/GUIDE-RELOAD-KEYCLOAK-THEME.md

# Supprimer fichiers racine obsolètes
rm fix-security-hazelcast.sh
rm github-workflow-orchestration.yml
rm ORGANIZATION-COMPLETE.md
```

### Phase 2: Nettoyage Conditionnel
```bash
# Si vous n'utilisez pas ces scripts de sync:
rm sync-from-hostinger.sh
rm sync-to-hostinger.sh

# Supprimer RESOLUTION-FEIGN-ERROR.md si doublon
# (vérifier d'abord qu'il est bien dans troubleshooting/)
```

### Phase 3: Archivage (Optionnel)
```bash
# Supprimer ou déplacer les archives si pas nécessaires
rm -rf docs/archive/

# Déplacer backup ancien hors du repo (vers backup externe)
# mv backups/ ~/Documents/dealtobook-backups-archive/
```

## 📋 Structure Recommandée Finale

```
dealtobook-devops/
├── README.md                          ✅ Point d'entrée
├── START-HERE-V2.md                   ✅ Guide rapide
│
├── config/                            ✅ Configuration
│   ├── docker-compose.*.yml
│   ├── *.env
│   ├── scripts/                       ✅ Scripts PostgreSQL
│   ├── nginx/                         ✅ Configs Nginx
│   ├── keycloak-themes/               ✅ Thèmes
│   └── monitoring/                    ✅ Prometheus/Grafana
│
├── scripts/                           ✅ Scripts de déploiement
│   ├── deploy-ssl-production-v2.sh    ✅ Principal
│   ├── diagnose-502.sh                ✅ Diagnostic
│   ├── test-deploy-v2.sh              ✅ Tests
│   ├── README.md                      ✅ Documentation scripts
│   └── tools/                         ✅ Outils
│       ├── sync-keycloak-themes.sh
│       ├── verify-and-reload-keycloak-theme.sh
│       ├── quick-reload-keycloak-theme.sh
│       ├── fix-keycloak-clients.sh
│       ├── test-postgres-connectivity.sh
│       └── migrate-postgres-azure-to-hostinger.sh
│
└── docs/                              ✅ Documentation
    ├── cicd/                          ✅ CI/CD (NOUVEAU)
    │   ├── README.md
    │   ├── ARCHITECTURE.md
    │   ├── CICD-USAGE-GUIDE.md
    │   ├── GITHUB-SECRETS-SETUP.md
    │   ├── MULTI-REPO-STRATEGY.md
    │   ├── SETUP-MULTI-REPO.md
    │   ├── workflow-devops/
    │   └── workflow-per-service/
    ├── deployment/                    ✅ Guides déploiement
    ├── guides/                        ✅ Guides pratiques
    └── troubleshooting/               ✅ Dépannage
```

## 🔢 Statistiques

- **Fichiers à supprimer:** ~20 fichiers
- **Espace récupéré estimé:** ~500KB (sans backups)
- **Espace récupéré avec backups:** ~50MB+

## ⚠️ Avant de Supprimer

1. ✅ Faire un backup du repo complet
2. ✅ Vérifier que les scripts actifs fonctionnent
3. ✅ Commiter les changements avec message clair
4. ✅ Possibilité de rollback avec git

## 🚀 Commandes de Nettoyage Automatique

Voir le script: `scripts/cleanup-repo.sh` (à créer)

