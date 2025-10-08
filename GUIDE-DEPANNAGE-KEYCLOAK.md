# 🔧 Guide de Dépannage Keycloak

## 🚨 Problème : "ERR_TOO_MANY_REDIRECTS" après connexion admin

### 📋 **Symptômes**
- Message : "keycloak-dev.dealtobook.com redirected you too many times"
- Erreur : `ERR_TOO_MANY_REDIRECTS`
- Logs Keycloak : `LOGIN_ERROR`, `expired_code`, `client_not_found`

### ✅ **Solutions (dans l'ordre)**

#### **1. Vider le cache et les cookies du navigateur**

**Chrome/Edge :**
1. Ouvrir les Outils de développement (`F12`)
2. Clic droit sur le bouton Actualiser
3. Sélectionner "Vider le cache et effectuer une actualisation forcée"
4. Ou : `Ctrl+Shift+R` (Windows) / `Cmd+Shift+R` (Mac)

**Firefox :**
1. `Ctrl+Shift+Delete` pour ouvrir l'effacement des données
2. Cocher "Cookies" et "Cache"
3. Sélectionner "Dernière heure"
4. Cliquer "Effacer maintenant"

**Safari :**
1. Menu "Développement" → "Vider les caches"
2. Ou `Cmd+Option+E`

#### **2. Supprimer les cookies spécifiques à Keycloak**

**Dans Chrome/Edge :**
1. `F12` → Onglet "Application"
2. Section "Storage" → "Cookies"
3. Sélectionner `keycloak-dev.dealtobook.com`
4. Supprimer tous les cookies

**Dans Firefox :**
1. `F12` → Onglet "Stockage"
2. "Cookies" → `keycloak-dev.dealtobook.com`
3. Supprimer tous les cookies

#### **3. Utiliser une fenêtre de navigation privée**

- **Chrome** : `Ctrl+Shift+N`
- **Firefox** : `Ctrl+Shift+P`
- **Safari** : `Cmd+Shift+N`
- **Edge** : `Ctrl+Shift+N`

#### **4. Accès direct via IP (solution de contournement)**

Si le domaine ne fonctionne pas, utilisez l'accès direct :

```
http://148.230.114.13:9080/admin/
```

**Identifiants :**
- **Utilisateur** : `admin`
- **Mot de passe** : `KeycloakAdmin2024Secure!`

#### **5. Vérifier la configuration DNS**

Assurez-vous que `keycloak-dev.dealtobook.com` pointe vers `148.230.114.13` :

```bash
# Test DNS
nslookup keycloak-dev.dealtobook.com

# Test de connectivité
curl -I http://keycloak-dev.dealtobook.com/
```

### 🔍 **Diagnostic avancé**

#### **Vérifier les logs Keycloak**
```bash
ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose logs --tail=50 keycloak'
```

#### **Vérifier le statut des services**
```bash
ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose ps'
```

#### **Redémarrer Keycloak**
```bash
ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose restart keycloak'
```

#### **Vérifier la configuration Nginx**
```bash
ssh root@148.230.114.13 'docker exec dealtobook-nginx nginx -t'
```

### 🛠️ **Solutions techniques**

#### **Si le problème persiste :**

1. **Redémarrer tous les services :**
   ```bash
   ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose restart'
   ```

2. **Vérifier les variables d'environnement Keycloak :**
   ```bash
   ssh root@148.230.114.13 'docker exec dealtobook-keycloak env | grep KC_'
   ```

3. **Recréer le conteneur Keycloak :**
   ```bash
   ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose stop keycloak && docker-compose rm -f keycloak && docker-compose up -d keycloak'
   ```

### 📱 **Test de fonctionnement**

#### **URLs à tester :**

1. **Page d'accueil** : http://keycloak-dev.dealtobook.com/
   - **Attendu** : Page d'accueil Keycloak

2. **Administration** : http://keycloak-dev.dealtobook.com/admin/
   - **Attendu** : Redirection vers `/admin/master/console/`

3. **Console** : http://keycloak-dev.dealtobook.com/admin/master/console/
   - **Attendu** : Interface de connexion admin

4. **Accès direct** : http://148.230.114.13:9080/admin/
   - **Attendu** : Interface d'administration directe

#### **Test avec curl :**
```bash
# Test de base
curl -I http://keycloak-dev.dealtobook.com/

# Test admin
curl -I http://keycloak-dev.dealtobook.com/admin/

# Test console
curl -I http://keycloak-dev.dealtobook.com/admin/master/console/
```

**Résultats attendus :**
- Page d'accueil : `HTTP/1.1 200 OK`
- Admin : `HTTP/1.1 302 Found` avec `Location: .../admin/master/console/`
- Console : `HTTP/1.1 200 OK`

### 🔐 **Informations de connexion**

- **URL Admin** : http://keycloak-dev.dealtobook.com/admin/
- **URL Direct** : http://148.230.114.13:9080/admin/
- **Utilisateur** : `admin`
- **Mot de passe** : `KeycloakAdmin2024Secure!`

### 📞 **Support**

Si aucune solution ne fonctionne :

1. **Vérifier les logs détaillés :**
   ```bash
   ssh root@148.230.114.13 'cd /opt/dealtobook && docker-compose logs keycloak | grep ERROR'
   ```

2. **Vérifier la connectivité réseau :**
   ```bash
   telnet keycloak-dev.dealtobook.com 80
   ```

3. **Tester depuis le serveur :**
   ```bash
   ssh root@148.230.114.13 'curl -I http://localhost:9080/admin/'
   ```

---
*Dernière mise à jour : 2025-10-04*
*Configuration testée et fonctionnelle*
