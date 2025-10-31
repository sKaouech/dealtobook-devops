# 🐘 Guide de Connexion PostgreSQL Externe

## 📋 Informations de Connexion

### 🌐 **Serveur PostgreSQL**
- **Host** : `148.230.114.13` (Hostinger)
- **Port** : `5432`
- **Utilisateur** : `dealtobook`
- **Mot de passe** : `DealToBook2024SecurePassword!`

### 🗄️ **Bases de Données Disponibles**

| Base de Données | Usage | Description |
|-----------------|-------|-------------|
| `dealtobook_db` | Principal | Base de données principale |
| `keycloak` | Authentification | Base de données Keycloak |
| `deal_generator` | Microservice | Service deal-generator |
| `deal_security` | Microservice | Service deal-security |
| `deal_setting` | Microservice | Service deal-setting |
| `deal_dealgen` | Legacy | Ancienne base deal_generator |

## 🔧 **Méthodes de Connexion**

### 1. **Ligne de commande (psql)**

```bash
# Connexion à la base principale
PGPASSWORD="DealToBook2024SecurePassword!" psql -h 148.230.114.13 -p 5432 -U dealtobook -d dealtobook_db

# Connexion à Keycloak
PGPASSWORD="DealToBook2024SecurePassword!" psql -h 148.230.114.13 -p 5432 -U dealtobook -d keycloak

# Connexion à un microservice
PGPASSWORD="DealToBook2024SecurePassword!" psql -h 148.230.114.13 -p 5432 -U dealtobook -d deal_generator
```

### 2. **URL de Connexion**

```bash
# Format général
postgresql://dealtobook:DealToBook2024SecurePassword!@148.230.114.13:5432/dealtobook_db

# Pour Keycloak
postgresql://dealtobook:DealToBook2024SecurePassword!@148.230.114.13:5432/keycloak

# Pour les microservices
postgresql://dealtobook:DealToBook2024SecurePassword!@148.230.114.13:5432/deal_generator
```

### 3. **Clients Graphiques**

#### **pgAdmin**
- **Host** : `148.230.114.13`
- **Port** : `5432`
- **Database** : `dealtobook_db` (ou autre)
- **Username** : `dealtobook`
- **Password** : `DealToBook2024SecurePassword!`

#### **DBeaver**
- **Server Host** : `148.230.114.13`
- **Port** : `5432`
- **Database** : `dealtobook_db`
- **Username** : `dealtobook`
- **Password** : `DealToBook2024SecurePassword!`

#### **DataGrip / IntelliJ**
- **Host** : `148.230.114.13`
- **Port** : `5432`
- **Database** : `dealtobook_db`
- **User** : `dealtobook`
- **Password** : `DealToBook2024SecurePassword!`

## 🔍 **Commandes Utiles**

### **Lister les bases de données**
```sql
\l
```

### **Se connecter à une base**
```sql
\c deal_generator
```

### **Lister les tables**
```sql
\dt
```

### **Voir la structure d'une table**
```sql
\d nom_table
```

### **Vérifier les connexions actives**
```sql
SELECT datname, usename, client_addr, state 
FROM pg_stat_activity 
WHERE state = 'active';
```

## 🛠️ **Configuration Technique**

### **Fichiers de Configuration**
- `postgresql.conf` : Configuration principale
- `pg_hba.conf` : Authentification et accès

### **Paramètres Importants**
- `listen_addresses = '*'` : Écoute sur toutes les interfaces
- `port = 5432` : Port standard PostgreSQL
- `max_connections = 100` : Maximum 100 connexions simultanées

### **Sécurité**
- ✅ Authentification MD5 activée
- ✅ Connexions externes autorisées
- ⚠️ **Attention** : Configuration de développement (accès depuis toute IP)

## 🚨 **Sécurité - Important**

### **⚠️ Configuration Actuelle (Développement)**
- Accès autorisé depuis **toute IP** (`0.0.0.0/0`)
- Approprié pour l'environnement de développement
- **À RESTREINDRE en production**

### **🔒 Pour la Production**
Modifier `pg_hba.conf` pour restreindre l'accès :
```bash
# Remplacer cette ligne :
host    all             all             0.0.0.0/0               md5

# Par des IPs spécifiques :
host    all             all             192.168.1.0/24          md5
host    all             all             10.0.0.0/8              md5
```

## 🧪 **Test de Connexion**

```bash
# Test rapide de connectivité
PGPASSWORD="DealToBook2024SecurePassword!" psql -h 148.230.114.13 -p 5432 -U dealtobook -d dealtobook_db -c "SELECT version();"
```

**Résultat attendu :**
```
PostgreSQL 15.14 on x86_64-pc-linux-musl, compiled by gcc (Alpine 14.2.0) 14.2.0, 64-bit
```

## 📞 **Support**

En cas de problème :

1. **Vérifier la connectivité réseau** :
   ```bash
   telnet 148.230.114.13 5432
   ```

2. **Vérifier les logs PostgreSQL** :
   ```bash
   ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose logs postgres'
   ```

3. **Vérifier le statut du conteneur** :
   ```bash
   ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose ps postgres'
   ```

---
*Configuration mise à jour le : 2025-10-04*
*Serveur : Hostinger (148.230.114.13)*
