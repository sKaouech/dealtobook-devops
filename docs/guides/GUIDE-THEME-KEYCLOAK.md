# Guide de Configuration du Thème Keycloak DealToBook

## 🎨 Thème Intégré

Le thème personnalisé `dealtobook` a été intégré avec succès dans votre déploiement Keycloak.

### 📁 Structure du Thème

```
keycloak-themes/dealtobook/
├── login/                    # Thème pour les pages de connexion
│   ├── login.ftl            # Page de connexion principale
│   ├── register.ftl         # Page d'inscription
│   ├── resources/           # Ressources CSS, JS, images
│   │   ├── css/
│   │   │   ├── login.css
│   │   │   ├── bootstrap.css
│   │   │   └── material-keycloak-theme.css
│   │   ├── img/
│   │   │   ├── title_deal_to_book3.png
│   │   │   ├── moorishHome.png
│   │   │   └── flags/
│   │   └── js/
│   └── messages/            # Traductions
└── email/                   # Thème pour les emails
    ├── html/
    └── text/
```

## 🔧 Configuration Manuelle

### Étape 1: Accès à l'Administration Keycloak

1. **URL**: https://keycloak-dev.dealtobook.com/admin
2. **Utilisateur**: `admin`
3. **Mot de passe**: `DealToBook2024AdminSecure!`

### Étape 2: Configuration du Thème

1. **Connectez-vous** à l'interface d'administration
2. **Sélectionnez le realm** `dealtobook` (menu déroulant en haut à gauche)
3. **Naviguez** vers `Realm Settings` > `Themes`
4. **Configurez les thèmes**:
   - **Login theme**: `dealtobook`
   - **Email theme**: `dealtobook`
   - **Account theme**: `dealtobook` (optionnel)
   - **Admin console theme**: Laissez par défaut
5. **Cliquez** sur `Save`

### Étape 3: Test du Thème

1. **Page de connexion**: https://keycloak-dev.dealtobook.com/realms/dealtobook/account
2. **Test d'authentification**: Utilisez vos applications frontend pour tester la nouvelle interface

## 🚀 Configuration Automatique

Si l'authentification admin fonctionne, vous pouvez utiliser le script automatique :

```bash
./scripts/configure-keycloak-theme.sh
```

## 🎯 Vérification

### Via l'API (si l'admin fonctionne)

```bash
# Obtenir un token admin
ADMIN_TOKEN=$(curl -k -s -X POST "https://keycloak-dev.dealtobook.com/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d "password=DealToBook2024AdminSecure!" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" | jq -r ".access_token")

# Vérifier la configuration
curl -k -s -X GET "https://keycloak-dev.dealtobook.com/admin/realms/dealtobook" \
  -H "Authorization: Bearer $ADMIN_TOKEN" | jq -r ".loginTheme, .emailTheme"
```

### Via l'Interface Web

1. Allez dans `Realm Settings` > `Themes`
2. Vérifiez que les champs affichent `dealtobook`

## 🎨 Personnalisation Avancée

### Modification du Thème

1. **Éditez les fichiers** dans `keycloak-themes/dealtobook/`
2. **Redéployez** le thème :
   ```bash
   scp -r keycloak-themes root@148.230.114.13:/opt/dealtobook/
   ssh root@148.230.114.13 "cd /opt/dealtobook && docker-compose restart keycloak"
   ```

### Fichiers Clés à Personnaliser

- **CSS Principal**: `login/resources/css/login.css`
- **Images**: `login/resources/img/`
- **Templates**: `login/*.ftl`
- **Messages**: `login/messages/messages_*.properties`

## 🔍 Dépannage

### Problème d'Authentification Admin

Si l'utilisateur admin n'existe pas :

```bash
# Recréer le container Keycloak
ssh root@148.230.114.13 "cd /opt/dealtobook && docker-compose stop keycloak && docker-compose rm -f keycloak && docker-compose up -d keycloak"

# Attendre le démarrage complet (60 secondes)
# Puis essayer la configuration manuelle
```

### Thème Non Visible

1. **Vérifiez** que le volume est monté :
   ```bash
   ssh root@148.230.114.13 "docker exec dealtobook-keycloak ls -la /opt/keycloak/themes/"
   ```

2. **Redémarrez** Keycloak si nécessaire :
   ```bash
   ssh root@148.230.114.13 "cd /opt/dealtobook && docker-compose restart keycloak"
   ```

## 📱 Résultat Attendu

Une fois configuré, vos utilisateurs verront :
- **Logo DealToBook** sur la page de connexion
- **Couleurs et style** personnalisés
- **Interface cohérente** avec votre marque
- **Emails** avec le thème DealToBook

## 🎉 Finalisation

Le thème est maintenant intégré et prêt à être utilisé. Les utilisateurs de vos applications frontend verront automatiquement le nouveau thème lors de l'authentification Keycloak.
