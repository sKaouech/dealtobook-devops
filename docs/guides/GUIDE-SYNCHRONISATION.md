# 🔄 Guide de Synchronisation DealToBook

## 📋 Vue d'ensemble

Ce guide explique comment synchroniser les changements entre votre repository local et le serveur de production Hostinger.

## 🛠️ Scripts disponibles

### 1. `sync-from-hostinger.sh` - Récupération des changements

**Usage :** Récupère les modifications depuis le serveur de production vers votre repository local.

```bash
./sync-from-hostinger.sh
```

**Ce que fait ce script :**
- ✅ Récupère `docker-compose.ghcr-complete.yml`
- ✅ Récupère les variables d'environnement (`.env` → `dealtobook-ghcr.env`)
- ✅ Récupère toutes les configurations Nginx
- ✅ Récupère les scripts de base de données
- ✅ Récupère les configurations de monitoring
- ✅ Détecte automatiquement les changements Git
- ✅ Propose de commiter et pousser les changements

### 2. `sync-to-hostinger.sh` - Déploiement des changements

**Usage :** Déploie vos modifications locales vers le serveur de production.

```bash
# Déploiement simple
./sync-to-hostinger.sh

# Déploiement avec redémarrage automatique des services
./sync-to-hostinger.sh --restart
```

**Ce que fait ce script :**
- ✅ Vérifie les changements non commitées
- ✅ Déploie `docker-compose.ghcr-complete.yml`
- ✅ Déploie les variables d'environnement
- ✅ Déploie toutes les configurations Nginx
- ✅ Déploie les scripts et configurations de monitoring
- ✅ Redémarre les services si demandé (`--restart`)

## 🔄 Workflow de synchronisation

### Scénario 1 : Modifications faites sur le serveur

```bash
# 1. Récupérer les changements depuis Hostinger
./sync-from-hostinger.sh

# 2. Le script détecte automatiquement les changements
# 3. Choisir 'y' pour commiter
# 4. Choisir 'y' pour pousser vers le repository distant
```

### Scénario 2 : Modifications faites localement

```bash
# 1. Faire vos modifications localement
# 2. Commiter vos changements
git add .
git commit -m "🔧 Update configuration"

# 3. Déployer vers Hostinger
./sync-to-hostinger.sh --restart
```

### Scénario 3 : Synchronisation bidirectionnelle

```bash
# 1. Récupérer les derniers changements du serveur
./sync-from-hostinger.sh

# 2. Faire vos modifications locales
# 3. Commiter vos changements
git add .
git commit -m "🚀 New features"

# 4. Déployer vers le serveur
./sync-to-hostinger.sh --restart
```

## 📁 Fichiers synchronisés

| Fichier Local | Fichier Distant | Description |
|---------------|-----------------|-------------|
| `docker-compose.ghcr-complete.yml` | `/opt/dealtobook/docker-compose.ghcr-complete.yml` | Configuration Docker Compose principale |
| `dealtobook-ghcr.env` | `/opt/dealtobook/.env` | Variables d'environnement |
| `nginx/nginx.http.conf` | `/opt/dealtobook/nginx/nginx.http.conf` | Configuration Nginx HTTP |
| `nginx/nginx.prod.conf` | `/opt/dealtobook/nginx/nginx.prod.conf` | Configuration Nginx SSL |
| `scripts/init-multiple-databases.sh` | `/opt/dealtobook/scripts/init-multiple-databases.sh` | Script d'initialisation BDD |
| `monitoring/prometheus.yml` | `/opt/dealtobook/monitoring/prometheus.yml` | Configuration Prometheus |
| `monitoring/grafana/` | `/opt/dealtobook/monitoring/grafana/` | Configurations Grafana |

## 🚨 Bonnes pratiques

### ✅ À faire

1. **Toujours récupérer avant de modifier**
   ```bash
   ./sync-from-hostinger.sh
   ```

2. **Commiter vos changements localement**
   ```bash
   git add .
   git commit -m "Description des changements"
   ```

3. **Tester localement avant de déployer**
   ```bash
   docker-compose -f docker-compose.ghcr-complete.yml config
   ```

4. **Déployer avec redémarrage pour les changements critiques**
   ```bash
   ./sync-to-hostinger.sh --restart
   ```

### ❌ À éviter

1. **Ne pas modifier directement sur le serveur** sans synchroniser après
2. **Ne pas déployer des changements non testés**
3. **Ne pas oublier de commiter avant de déployer**

## 🔧 Dépannage

### Problème : "Changements non commitées détectés"

**Solution :**
```bash
# Commiter vos changements d'abord
git add .
git commit -m "Description des changements"

# Puis déployer
./sync-to-hostinger.sh
```

### Problème : "Fichier local non trouvé"

**Solution :**
```bash
# Récupérer les fichiers depuis le serveur
./sync-from-hostinger.sh
```

### Problème : Échec de connexion SSH

**Solution :**
```bash
# Vérifier la connexion SSH
ssh root@148.230.114.13 "echo 'Connexion OK'"

# Vérifier les clés SSH
ssh-add -l
```

## 🌐 URLs de vérification après déploiement

Après chaque déploiement, vérifiez ces URLs :

- **Administration :** http://administration-dev.dealtobook.com
- **Website :** http://website-dev.dealtobook.com
- **Keycloak :** http://keycloak-dev.dealtobook.com
- **Grafana :** http://148.230.114.13:3000
- **Prometheus :** http://148.230.114.13:9090

## 📞 Support

En cas de problème, vérifiez :

1. **Logs des services :**
   ```bash
   ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose logs -f'
   ```

2. **Status des conteneurs :**
   ```bash
   ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose ps'
   ```

3. **Connectivité réseau :**
   ```bash
   curl -I http://148.230.114.13
   ```

---
*Dernière mise à jour : 2025-10-04*
