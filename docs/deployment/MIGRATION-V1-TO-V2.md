# 🔄 Guide de Migration: V1 → V2

## 📊 Comparaison Rapide

| Aspect | V1 | V2 | Migration |
|--------|----|----|-----------|
| **Fichier** | `deploy-ssl-production.sh` | `deploy-ssl-production-v2.sh` | ✅ Coexistent |
| **Lignes** | 1036 | 1147 | +11% |
| **Commandes** | 13 | 22 | +9 nouvelles |
| **Bugs** | Ligne 754 vide | Corrigé | ✅ |
| **DRY** | Code dupliqué | Centralisé | ✅ |
| **Backwards Compat** | N/A | 100% | ✅ |

---

## 🚀 Pourquoi Migrer ?

### ✅ Avantages de V2

1. **9 Nouvelles Commandes**
   - `pull`: Télécharger images sans restart
   - `scale`: Scaler les services dynamiquement
   - `exec`: Exécuter commandes dans conteneurs
   - `inspect`: Inspection détaillée
   - Et plus...

2. **Plus de Flexibilité**
   - Tags personnalisés (`CUSTOM_TAG`)
   - Timeouts configurables
   - Alias de services naturels

3. **Code Plus Propre**
   - Mapping centralisé (DRY)
   - Pas de duplication
   - Gestion d'erreurs stricte

4. **Meilleure Maintenabilité**
   - Documentation complète
   - Tests automatisés
   - Code modulaire

### ⚠️ Considérations

- **Même comportement**: Toutes les commandes V1 fonctionnent en V2
- **Pas de breaking changes**: Migration sans risque
- **Coexistence**: V1 et V2 peuvent coexister

---

## 📋 Plan de Migration

### Phase 1: Préparation (15 minutes)

```bash
cd /Users/seyfkaoueche/Documents/work/project/dealtobook/workspace/dealtobook-devops/scripts

# 1. Vérifier que V2 existe
ls -lh deploy-ssl-production-v2.sh

# 2. Rendre exécutable
chmod +x deploy-ssl-production-v2.sh

# 3. Lire la documentation
cat ../DEPLOY-SCRIPT-V2-IMPROVEMENTS.md
cat ../QUICK-START-V2.md
```

### Phase 2: Test en Development (30 minutes)

```bash
# 1. Configurer l'environnement
export DEPLOY_ENV=development
source ~/.dealtobook-deploy.env

# 2. Tester la commande help
./deploy-ssl-production-v2.sh help

# 3. Tester les commandes de base
./deploy-ssl-production-v2.sh ps
./deploy-ssl-production-v2.sh status

# 4. Tester une commande avancée (nouvelle)
./deploy-ssl-production-v2.sh inspect deal_generator

# 5. Tester un build sélectif
./deploy-ssl-production-v2.sh build-only deal_security

# 6. Si tout OK, tester un déploiement complet
./deploy-ssl-production-v2.sh deploy
```

### Phase 3: Adoption Progressive (1 semaine)

```bash
# Semaine 1: Utiliser V2 pour les opérations courantes
./deploy-ssl-production-v2.sh logs
./deploy-ssl-production-v2.sh restart
./deploy-ssl-production-v2.sh health

# Semaine 2: Tester les nouvelles fonctionnalités
./deploy-ssl-production-v2.sh pull
./deploy-ssl-production-v2.sh scale deal_generator 2
./deploy-ssl-production-v2.sh exec postgres psql

# Semaine 3: Utiliser exclusivement V2
# Créer des alias bash
alias dt-deploy='./deploy-ssl-production-v2.sh'
```

### Phase 4: Décommissionnement de V1 (Optionnel)

```bash
# Une fois V2 stable et testé (après 1 mois)

# 1. Renommer V1 en backup
mv deploy-ssl-production.sh deploy-ssl-production-v1-backup.sh

# 2. Faire de V2 la version principale
cp deploy-ssl-production-v2.sh deploy-ssl-production.sh

# 3. Ou créer un lien symbolique
ln -s deploy-ssl-production-v2.sh deploy-ssl-production.sh
```

---

## 🔀 Mapping des Commandes

### Commandes Identiques

Ces commandes fonctionnent exactement de la même manière:

```bash
# Build
./deploy-ssl-production.sh build              # V1
./deploy-ssl-production-v2.sh build           # V2

# Deploy
./deploy-ssl-production.sh deploy             # V1
./deploy-ssl-production-v2.sh deploy          # V2

# Start/Stop/Restart
./deploy-ssl-production.sh start              # V1
./deploy-ssl-production-v2.sh start           # V2

# Logs
./deploy-ssl-production.sh logs deal_security # V1
./deploy-ssl-production-v2.sh logs deal_security # V2
```

### Nouvelles Commandes V2

Ces commandes n'existent pas en V1:

```bash
# Pull images sans restart
./deploy-ssl-production-v2.sh pull

# Scale services
./deploy-ssl-production-v2.sh scale deal_generator 3

# Exec dans conteneur
./deploy-ssl-production-v2.sh exec postgres psql

# Inspect détaillé
./deploy-ssl-production-v2.sh inspect deal_security
```

### Améliorations des Commandes Existantes

```bash
# V1: Restart avec nom complet uniquement
./deploy-ssl-production.sh restart deal_generator,deal_security

# V2: Restart avec alias
./deploy-ssl-production-v2.sh restart generator,security
./deploy-ssl-production-v2.sh restart admin  # Alias pour webui
```

---

## 🎯 Cas d'Usage Comparés

### Cas 1: Déployer un Hotfix

**Avec V1:**
```bash
export DEPLOY_ENV=production
source ~/.dealtobook-deploy.env

# Pas de support pour tags custom
# Doit modifier le code ou utiliser latest
./deploy-ssl-production.sh build deal_security
./deploy-ssl-production.sh deploy-only deal_security
```

**Avec V2:**
```bash
export DEPLOY_ENV=production
export CUSTOM_TAG="hotfix-2024-10-28"  # ✨ Nouveau !
source ~/.dealtobook-deploy.env

./deploy-ssl-production-v2.sh build deal_security
./deploy-ssl-production-v2.sh deploy-only deal_security
```

### Cas 2: Debug en Production

**Avec V1:**
```bash
# Voir les logs
./deploy-ssl-production.sh logs deal_security

# Pour accéder au conteneur, SSH manuel nécessaire
ssh root@148.230.114.13
cd /opt/dealtobook
docker exec -it $(docker-compose ps -q deal-security) bash
```

**Avec V2:**
```bash
# Voir les logs
./deploy-ssl-production-v2.sh logs deal_security

# Inspection complète en une commande ✨
./deploy-ssl-production-v2.sh inspect deal_security

# Exec direct ✨
./deploy-ssl-production-v2.sh exec deal_security bash
./deploy-ssl-production-v2.sh exec deal_security cat logs/spring.log
```

### Cas 3: Scale pour Tests de Charge

**Avec V1:**
```bash
# Impossible directement avec le script
# Doit SSH et utiliser docker-compose scale
ssh root@148.230.114.13
cd /opt/dealtobook-dev
docker-compose up -d --scale deal-generator=3
```

**Avec V2:**
```bash
# Une seule commande ✨
./deploy-ssl-production-v2.sh scale deal_generator 3

# Vérifier
./deploy-ssl-production-v2.sh ps

# Redescendre après tests
./deploy-ssl-production-v2.sh scale deal_generator 1
```

---

## 🔧 Configuration Mise à Jour

### Anciennes Variables (V1)

```bash
# ~/.dealtobook-deploy.env (V1)
export CR_PAT="your_token"
export DEPLOY_ENV="development"
export GITHUB_USERNAME="skaouech"
```

### Nouvelles Variables (V2)

```bash
# ~/.dealtobook-deploy.env (V2)
# Variables existantes (compatibles V1)
export CR_PAT="your_token"
export DEPLOY_ENV="development"
export GITHUB_USERNAME="skaouech"

# Nouvelles variables optionnelles ✨
export CUSTOM_TAG="v1.2.3"                      # Tag personnalisé
export DB_READY_TIMEOUT="60"                    # Timeout PostgreSQL
export KEYCLOAK_READY_TIMEOUT="90"              # Timeout Keycloak
export SERVICE_STABILIZATION_TIMEOUT="30"       # Timeout services
```

---

## ✅ Checklist de Migration

### Avant Migration

- [ ] Lire la documentation complète
  - [ ] `DEPLOY-SCRIPT-V2-IMPROVEMENTS.md`
  - [ ] `QUICK-START-V2.md`
  - [ ] `MIGRATION-V1-TO-V2.md` (ce fichier)

- [ ] Sauvegarder la configuration actuelle
  ```bash
  cp ~/.dealtobook-deploy.env ~/.dealtobook-deploy.env.backup
  ```

- [ ] Vérifier l'environnement
  ```bash
  java -version  # Java 17
  docker --version
  ssh root@148.230.114.13 "echo SSH OK"
  ```

### Pendant Migration

- [ ] Installer V2
  ```bash
  chmod +x deploy-ssl-production-v2.sh
  ```

- [ ] Tester en dev d'abord
  ```bash
  export DEPLOY_ENV=development
  ./deploy-ssl-production-v2.sh health
  ```

- [ ] Tester les commandes de base
  - [ ] `ps`
  - [ ] `logs`
  - [ ] `health`
  - [ ] `restart`

- [ ] Tester les nouvelles commandes
  - [ ] `inspect`
  - [ ] `pull`
  - [ ] `exec`

- [ ] Tester un déploiement complet
  ```bash
  ./deploy-ssl-production-v2.sh deploy
  ```

### Après Migration

- [ ] Documenter les changements dans votre équipe
- [ ] Mettre à jour les runbooks
- [ ] Mettre à jour les scripts CI/CD si applicable
- [ ] Créer des alias bash pour faciliter l'adoption
- [ ] Former l'équipe aux nouvelles commandes

---

## 🐛 Problèmes Connus et Solutions

### Problème 1: "Service not found"

**Symptôme**: Erreur lors de l'utilisation d'un nom de service

**Cause**: Utilisation d'un nom non reconnu

**Solution**:
```bash
# ❌ Nom invalide
./deploy-ssl-production-v2.sh restart dealgenerator

# ✅ Utiliser un nom valide ou alias
./deploy-ssl-production-v2.sh restart deal_generator  # Nom complet
./deploy-ssl-production-v2.sh restart generator       # Alias court
```

### Problème 2: Commande V1 ne fonctionne plus

**Symptôme**: Ancienne commande échoue en V2

**Cause**: Cela ne devrait pas arriver (100% compatible)

**Solution**:
```bash
# Vérifier la syntaxe
./deploy-ssl-production-v2.sh help

# Reporter le bug avec détails:
# - Commande exacte utilisée
# - Message d'erreur
# - Version de l'environnement
```

### Problème 3: Performance dégradée

**Symptôme**: V2 semble plus lent que V1

**Cause**: `set -euo pipefail` rend le script plus strict

**Solution**:
```bash
# Ajuster les timeouts si nécessaire
export DB_READY_TIMEOUT="30"        # Réduire pour env rapide
export KEYCLOAK_READY_TIMEOUT="45"
./deploy-ssl-production-v2.sh deploy
```

---

## 📞 Support Migration

### Si vous rencontrez des problèmes

1. **Consulter la documentation**
   - [QUICK-START-V2.md](./QUICK-START-V2.md)
   - [DEPLOY-SCRIPT-V2-IMPROVEMENTS.md](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md)

2. **Tester avec V1 pour comparer**
   ```bash
   # Même commande avec V1
   ./deploy-ssl-production.sh health
   
   # Même commande avec V2
   ./deploy-ssl-production-v2.sh health
   ```

3. **Activer le mode debug**
   ```bash
   bash -x ./deploy-ssl-production-v2.sh health
   ```

4. **Contacter le support**
   - Slack: #devops-support
   - Email: devops@dealtobook.com
   - Issues GitHub: https://github.com/skaouech/dealtobook/issues

---

## 🎉 Réussite de la Migration

Une fois la migration complète, vous devriez pouvoir:

✅ Utiliser toutes les commandes V1 en V2  
✅ Bénéficier des 9 nouvelles commandes  
✅ Utiliser les alias de services  
✅ Configurer les timeouts  
✅ Déployer avec des tags personnalisés  
✅ Debugger plus facilement  
✅ Scaler les services dynamiquement  
✅ Avoir un code plus maintenable  

---

## 📈 Prochaines Étapes

Après avoir migré vers V2, explorez:

1. **Automatisation CI/CD**
   ```bash
   # Intégrer dans GitHub Actions
   - name: Deploy to production
     run: |
       export DEPLOY_ENV=production
       export CUSTOM_TAG="${{ github.ref_name }}"
       ./scripts/deploy-ssl-production-v2.sh deploy
   ```

2. **Scripts personnalisés**
   ```bash
   # Créer vos propres wrappers
   cat > deploy-hotfix.sh << 'EOF'
   #!/bin/bash
   export CUSTOM_TAG="hotfix-$(date +%Y%m%d)"
   export DEPLOY_ENV=production
   ./deploy-ssl-production-v2.sh build "$1"
   ./deploy-ssl-production-v2.sh deploy-only "$1"
   EOF
   ```

3. **Monitoring avancé**
   ```bash
   # Ajouter des checks post-déploiement
   ./deploy-ssl-production-v2.sh deploy && \
   ./deploy-ssl-production-v2.sh health && \
   curl -X POST https://slack-webhook.com -d '{"text":"Deploy successful"}'
   ```

---

**Bonne migration ! 🚀**

*Document mis à jour le: 2025-10-28*  
*Version: 1.0*

