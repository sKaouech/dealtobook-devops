# 🔐 Guide de Configuration SSL/HTTPS pour DealToBook

Ce guide vous explique comment configurer et déployer SSL/HTTPS pour votre infrastructure DealToBook sur Hostinger.

## 🎯 **Objectifs**

- ✅ Sécuriser toutes les communications avec HTTPS
- ✅ Obtenir des certificats SSL gratuits avec Let's Encrypt
- ✅ Configurer le renouvellement automatique des certificats
- ✅ Optimiser la sécurité avec les meilleures pratiques SSL

## 📋 **Prérequis**

### **DNS Configuration**
Assurez-vous que vos domaines pointent vers votre serveur Hostinger :

```bash
# Vérification DNS
nslookup administration-dev.dealtobook.com
nslookup website-dev.dealtobook.com  
nslookup keycloak-dev.dealtobook.com
```

Tous doivent pointer vers `148.230.114.13`.

### **Ports ouverts**
- Port 80 (HTTP) - Pour la validation Let's Encrypt
- Port 443 (HTTPS) - Pour le trafic sécurisé

## 🚀 **Déploiement SSL Automatisé**

### **Option 1: Déploiement complet automatique**

```bash
# Rendre le script exécutable
chmod +x deploy-ssl-production.sh

# Lancer le déploiement SSL complet
./deploy-ssl-production.sh
```

### **Option 2: Déploiement étape par étape**

```bash
# 1. Préparation de l'environnement
./deploy-ssl-production.sh prepare

# 2. Configuration HTTP initiale
./deploy-ssl-production.sh http

# 3. Obtention des certificats SSL
./deploy-ssl-production.sh certs

# 4. Configuration HTTPS complète
./deploy-ssl-production.sh https

# 5. Configuration du renouvellement automatique
./deploy-ssl-production.sh renew

# 6. Tests de connectivité
./deploy-ssl-production.sh test

# 7. Affichage du statut
./deploy-ssl-production.sh status
```

## 🔧 **Configuration Manuelle (si nécessaire)**

### **1. Préparation sur Hostinger**

```bash
# Connexion SSH
ssh root@148.230.114.13

# Création des répertoires
mkdir -p /opt/dealtobook/nginx
mkdir -p /etc/letsencrypt
mkdir -p /var/www/certbot
```

### **2. Transfert des fichiers**

```bash
# Depuis votre machine locale
scp nginx/nginx.ssl.conf root@148.230.114.13:/opt/dealtobook/nginx/
scp docker-compose.ssl-complete.yml root@148.230.114.13:/opt/dealtobook/
scp dealtobook-ssl.env root@148.230.114.13:/opt/dealtobook/.env
```

### **3. Obtention des certificats**

```bash
# Sur Hostinger
cd /opt/dealtobook

# Démarrer Nginx temporaire pour validation
docker run -d --name nginx-temp -p 80:80 \
  -v /var/www/certbot:/var/www/certbot \
  -v /opt/dealtobook/nginx/nginx.http-only.conf:/etc/nginx/nginx.conf:ro \
  nginx:1.24-alpine

# Obtenir les certificats
docker run --rm \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/www/certbot:/var/www/certbot \
  certbot/certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email skaouech@dealtobook.com \
  --agree-tos \
  --no-eff-email \
  -d administration-dev.dealtobook.com \
  -d website-dev.dealtobook.com \
  -d keycloak-dev.dealtobook.com

# Arrêter Nginx temporaire
docker stop nginx-temp && docker rm nginx-temp
```

### **4. Déploiement HTTPS**

```bash
# Démarrer l'infrastructure complète avec SSL
docker compose -f docker-compose.ssl-complete.yml --env-file .env up -d
```

## 🔄 **Renouvellement Automatique**

### **Configuration du cron**

Le script configure automatiquement un cron job pour renouveler les certificats :

```bash
# Vérification du cron (sur Hostinger)
crontab -l

# Devrait afficher :
# 0 */12 * * * /opt/dealtobook/renew-certs.sh >> /var/log/certbot-renew.log 2>&1
```

### **Test manuel du renouvellement**

```bash
# Sur Hostinger
cd /opt/dealtobook
./renew-certs.sh
```

## 🧪 **Tests et Vérification**

### **1. Test des certificats SSL**

```bash
# Test SSL pour chaque domaine
curl -I https://administration-dev.dealtobook.com
curl -I https://website-dev.dealtobook.com
curl -I https://keycloak-dev.dealtobook.com

# Vérification détaillée SSL
openssl s_client -connect administration-dev.dealtobook.com:443 -servername administration-dev.dealtobook.com
```

### **2. Test des redirections HTTP → HTTPS**

```bash
# Ces commandes doivent retourner une redirection 301
curl -I http://administration-dev.dealtobook.com
curl -I http://website-dev.dealtobook.com
curl -I http://keycloak-dev.dealtobook.com
```

### **3. Vérification des services**

```bash
# Sur Hostinger
cd /opt/dealtobook
docker compose -f docker-compose.ssl-complete.yml ps
docker compose -f docker-compose.ssl-complete.yml logs nginx
```

## 🔒 **Configuration de Sécurité**

### **Headers de sécurité configurés**

- `Strict-Transport-Security` : Force HTTPS
- `X-Frame-Options` : Protection contre le clickjacking
- `X-Content-Type-Options` : Protection contre le MIME sniffing
- `X-XSS-Protection` : Protection XSS

### **Chiffrement SSL**

- **Protocoles** : TLS 1.2 et TLS 1.3 uniquement
- **Ciphers** : Chiffrement fort (ECDHE-RSA-AES)
- **Session Cache** : Optimisation des performances

### **Rate Limiting**

- **Login** : 10 requêtes/minute
- **API** : 100 requêtes/minute

## 🌐 **URLs Finales**

Après configuration SSL, vos services seront disponibles sur :

- **Administration** : https://administration-dev.dealtobook.com
- **Website** : https://website-dev.dealtobook.com
- **Keycloak** : https://keycloak-dev.dealtobook.com
- **Monitoring** : 
  - Prometheus : https://administration-dev.dealtobook.com:9090
  - Grafana : https://administration-dev.dealtobook.com:3000

## 🚨 **Dépannage**

### **Problème : Certificat non trouvé**

```bash
# Vérifier l'existence des certificats
ls -la /etc/letsencrypt/live/

# Régénérer si nécessaire
./deploy-ssl-production.sh certs
```

### **Problème : Nginx ne démarre pas**

```bash
# Vérifier la configuration
docker run --rm -v /opt/dealtobook/nginx/nginx.ssl.conf:/etc/nginx/nginx.conf nginx:1.24-alpine nginx -t

# Vérifier les logs
docker compose -f docker-compose.ssl-complete.yml logs nginx
```

### **Problème : Domaine inaccessible**

```bash
# Vérifier DNS
nslookup administration-dev.dealtobook.com

# Vérifier les ports
netstat -tlnp | grep :443
netstat -tlnp | grep :80

# Tester depuis le serveur
curl -I http://localhost
curl -k -I https://localhost
```

## 📞 **Support**

En cas de problème :

1. Vérifiez les logs : `docker compose logs`
2. Testez la configuration Nginx : `nginx -t`
3. Vérifiez les certificats : `ls /etc/letsencrypt/live/`
4. Consultez les logs Let's Encrypt : `/var/log/letsencrypt/`

---

*Ce guide est généré automatiquement et peut être mis à jour en fonction des évolutions du projet.*
