# 🔄 Guide de Migration PostgreSQL Azure → Hostinger

## 🎯 Vue d'Ensemble

Migration complète de votre base de données PostgreSQL depuis Azure (`dev-dealtobook-postgres.postgres.database.azure.com`) vers votre serveur Hostinger.

### 📊 Bases de Données à Migrer

| Base Azure | Base Hostinger | Usage |
|------------|----------------|-------|
| `deal_generator` | `deal_generator` | Service deal_generator |
| `keycloak` | `keycloak` | Service deal_security |
| `deal_setting` | `deal_setting` | Service deal_setting |

## 🚀 Migration Rapide

### 1. Configuration des Variables
```bash
# Mot de passe Azure PostgreSQL
export AZURE_PASSWORD="votre_mot_de_passe_azure"

# Mot de passe Hostinger PostgreSQL (doit correspondre à dealtobook-ghcr.env)
export POSTGRES_PASSWORD="devpassword123"

# Optionnel: utilisateur Azure (par défaut: dealtobook)
export AZURE_USER="dealtobook"
```

### 2. Migration Complète
```bash
# Migration complète en une commande
./migrate-postgres-azure-to-hostinger.sh migrate
```

## 🔧 Migration Étape par Étape

### Étape 1: Sauvegarde Azure
```bash
# Sauvegarder seulement les bases Azure
./migrate-postgres-azure-to-hostinger.sh backup
```

### Étape 2: Restauration Hostinger
```bash
# Restaurer sur Hostinger (après backup)
./migrate-postgres-azure-to-hostinger.sh restore
```

### Étape 3: Vérification
```bash
# Vérifier la migration
./migrate-postgres-azure-to-hostinger.sh verify
```

## 📋 Prérequis

### 🔧 Outils Requis
```bash
# Sur votre machine locale
sudo apt-get update
sudo apt-get install postgresql-client

# Ou sur macOS
brew install postgresql
```

### 🔑 Accès Requis
- **SSH vers Hostinger** : Clé SSH configurée
- **Azure PostgreSQL** : Mot de passe et accès réseau
- **Hostinger PostgreSQL** : Container Docker démarré

### 🌐 Connectivité
```bash
# Test SSH Hostinger
ssh root@148.230.114.13 "echo 'SSH OK'"

# Test Azure PostgreSQL
PGPASSWORD="your_password" psql -h dev-dealtobook-postgres.postgres.database.azure.com -U dealtobook -d postgres -c "SELECT version();"
```

## 🔍 Processus de Migration Détaillé

### 1. **Vérification des Prérequis**
- ✅ Installation de `pg_dump` et `psql`
- ✅ Connexion SSH vers Hostinger
- ✅ Variables d'environnement définies
- ✅ Création du répertoire de backup

### 2. **Test des Connexions**
- ✅ Connexion à Azure PostgreSQL
- ✅ Connexion à Hostinger PostgreSQL (via Docker)

### 3. **Sauvegarde Azure**
```bash
# Pour chaque base de données
pg_dump -h dev-dealtobook-postgres.postgres.database.azure.com \
        -U dealtobook \
        -d deal_generator \
        --no-owner --no-privileges --clean --if-exists \
        --file=deal_generator_backup.sql
```

### 4. **Préparation Hostinger**
```bash
# Démarrer PostgreSQL
docker-compose -f docker-compose.ghcr.yml up -d postgres

# Créer les bases de données
docker exec dealtobook-postgres psql -U dealtobook -d dealtobook_db \
  -c "CREATE DATABASE deal_generator OWNER dealtobook;"
```

### 5. **Transfert des Données**
```bash
# Copier les backups vers Hostinger
scp backup.sql root@148.230.114.13:/tmp/

# Restaurer sur Hostinger
docker exec -i dealtobook-postgres psql -U dealtobook -d deal_generator < backup.sql
```

### 6. **Vérification**
- ✅ Comparaison du nombre de tables
- ✅ Comparaison du nombre d'enregistrements
- ✅ Test des requêtes critiques

## 🛡️ Sécurité et Bonnes Pratiques

### 🔒 **Sécurité des Données**
```bash
# Backups chiffrés (optionnel)
gpg --symmetric --cipher-algo AES256 backup.sql

# Permissions restrictives
chmod 600 backup.sql
```

### 📦 **Compression**
```bash
# Compression automatique des backups
gzip backup.sql  # Réduit la taille de ~70%
```

### 🔄 **Rollback**
```bash
# En cas de problème, restaurer depuis Azure
# Les backups sont conservés localement
```

## 🚨 Gestion des Erreurs

### **Erreur: Connexion Azure Refusée**
```bash
# Vérifier les règles de pare-feu Azure
# Ajouter votre IP aux règles autorisées
```

### **Erreur: Base Existe Déjà**
```bash
# Supprimer et recréer la base
docker exec dealtobook-postgres psql -U dealtobook -d dealtobook_db \
  -c "DROP DATABASE IF EXISTS deal_generator;"
```

### **Erreur: Permissions Insuffisantes**
```bash
# Vérifier l'utilisateur PostgreSQL
docker exec dealtobook-postgres psql -U dealtobook -d dealtobook_db \
  -c "ALTER USER dealtobook CREATEDB;"
```

## 📊 Monitoring de la Migration

### **Taille des Données**
```bash
# Taille des bases Azure
PGPASSWORD="$AZURE_PASSWORD" psql -h dev-dealtobook-postgres.postgres.database.azure.com \
  -U dealtobook -d deal_generator \
  -c "SELECT pg_size_pretty(pg_database_size('deal_generator'));"
```

### **Temps de Migration**
| Base | Taille Estimée | Temps Migration |
|------|----------------|-----------------|
| `deal_generator` | ~50MB | 2-5 minutes |
| `keycloak` | ~10MB | 1-2 minutes |
| `deal_setting` | ~100MB | 5-10 minutes |

### **Vérification Post-Migration**
```bash
# Comparer les schémas
pg_dump --schema-only source_db > schema_source.sql
pg_dump --schema-only target_db > schema_target.sql
diff schema_source.sql schema_target.sql
```

## 🔄 Mise à Jour des Applications

### **Configuration Automatique**
Les applications DealToBook sont déjà configurées dans `docker-compose.ghcr.yml` :

```yaml
deal-generator:
  environment:
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/deal_generator

deal-security:
  environment:
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/keycloak

deal-setting:
  environment:
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/deal_setting
```

### **Redémarrage des Services**
```bash
# Redémarrer tous les services backend
ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose -f docker-compose.ghcr.yml restart deal-generator deal-security deal-setting'
```

## 📋 Checklist de Migration

### **Avant Migration**
- [ ] Variables d'environnement configurées
- [ ] Connexions testées (Azure + Hostinger)
- [ ] Espace disque suffisant
- [ ] Services Hostinger démarrés

### **Pendant Migration**
- [ ] Sauvegarde Azure réussie
- [ ] Transfert vers Hostinger OK
- [ ] Restauration sans erreurs
- [ ] Vérification des données

### **Après Migration**
- [ ] Applications redémarrées
- [ ] Tests fonctionnels OK
- [ ] Monitoring actif
- [ ] Backups conservés

## 🎯 Résultats Attendus

### **Performance**
- **Latence** : Réduction de ~50ms (Azure → Hostinger local)
- **Débit** : Amélioration des requêtes complexes
- **Disponibilité** : 99.9% (infrastructure contrôlée)

### **Coûts**
- **Azure PostgreSQL** : ~100€/mois → 0€
- **Hostinger** : Inclus dans VPS
- **Économie** : ~1200€/an

### **Contrôle**
- **Backups** : Gestion complète
- **Monitoring** : Prometheus + Grafana
- **Scaling** : Contrôle des ressources

## 🆘 Support et Dépannage

### **Logs de Migration**
```bash
# Logs détaillés dans
./postgres-migration-YYYYMMDD-HHMMSS/migration.log
```

### **Commandes de Debug**
```bash
# Status PostgreSQL Hostinger
ssh root@148.230.114.13 'docker logs dealtobook-postgres'

# Connexion directe
ssh root@148.230.114.13 'docker exec -it dealtobook-postgres psql -U dealtobook'
```

### **Rollback d'Urgence**
```bash
# Restaurer depuis les backups locaux
./migrate-postgres-azure-to-hostinger.sh restore
```

**Votre migration PostgreSQL Azure → Hostinger est maintenant prête !** 🚀
