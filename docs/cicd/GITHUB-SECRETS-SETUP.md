# 🔐 Configuration des Secrets GitHub

Ce document décrit tous les secrets nécessaires pour faire fonctionner la CI/CD GitHub Actions.

## 📋 Liste des Secrets Requis

### 1. Secrets Obligatoires

| Secret | Description | Où l'obtenir |
|--------|-------------|--------------|
| `GITHUB_TOKEN` | Token GitHub pour GHCR | Fourni automatiquement par GitHub Actions |
| `SSH_PRIVATE_KEY` | Clé SSH privée pour se connecter au serveur | Générer avec `ssh-keygen` |
| `HOSTINGER_USER` | Utilisateur SSH du serveur | Fourni par Hostinger (généralement `root`) |
| `HOSTINGER_IP` | Adresse IP du serveur | IP de votre serveur Hostinger |

### 2. Secrets Optionnels

| Secret | Description | Requis pour |
|--------|-------------|-------------|
| `SONAR_TOKEN` | Token SonarQube/SonarCloud | Analyse de code (optionnel) |
| `SLACK_WEBHOOK` | Webhook Slack | Notifications (optionnel) |

## 🔧 Configuration Étape par Étape

### Étape 1: Générer la clé SSH

```bash
# Sur votre machine locale
ssh-keygen -t ed25519 -C "github-actions@dealtobook" -f ~/.ssh/dealtobook_deploy

# Cela crée deux fichiers:
# - dealtobook_deploy (clé privée)
# - dealtobook_deploy.pub (clé publique)
```

### Étape 2: Copier la clé publique sur le serveur

```bash
# Copier la clé publique sur le serveur Hostinger
ssh-copy-id -i ~/.ssh/dealtobook_deploy.pub root@VOTRE_IP_HOSTINGER

# Ou manuellement:
cat ~/.ssh/dealtobook_deploy.pub
# Copier le contenu et l'ajouter dans ~/.ssh/authorized_keys sur le serveur
```

### Étape 3: Tester la connexion SSH

```bash
ssh -i ~/.ssh/dealtobook_deploy root@VOTRE_IP_HOSTINGER
# Si ça fonctionne sans mot de passe, c'est bon!
```

### Étape 4: Ajouter les secrets sur GitHub

1. Aller sur votre repository GitHub
2. Cliquer sur **Settings** > **Secrets and variables** > **Actions**
3. Cliquer sur **New repository secret**

#### Secret: SSH_PRIVATE_KEY

```bash
# Afficher la clé privée
cat ~/.ssh/dealtobook_deploy

# Copier TOUT le contenu (y compris les lignes BEGIN/END)
```

- **Name:** `SSH_PRIVATE_KEY`
- **Value:** Coller tout le contenu de la clé privée

#### Secret: HOSTINGER_USER

- **Name:** `HOSTINGER_USER`
- **Value:** `root` (ou votre utilisateur)

#### Secret: HOSTINGER_IP

- **Name:** `HOSTINGER_IP`
- **Value:** L'adresse IP de votre serveur (ex: `148.230.114.13`)

### Étape 5: (Optionnel) Configurer SonarCloud

Si vous voulez activer l'analyse de code:

1. Aller sur https://sonarcloud.io
2. Se connecter avec GitHub
3. Créer une organisation
4. Importer vos projets
5. Récupérer le token d'analyse

Ajouter le secret:
- **Name:** `SONAR_TOKEN`
- **Value:** Votre token SonarCloud

## 🔒 Environnements GitHub (Recommandé)

Pour séparer les secrets entre Development et Production:

1. Aller sur **Settings** > **Environments**
2. Créer deux environnements:
   - `development`
   - `production`
3. Pour chaque environnement, ajouter les secrets spécifiques:
   - `HOSTINGER_IP` (différent pour dev/prod si vous avez 2 serveurs)
   - Protection rules (ex: require approval for production)

### Configuration des Environments

#### Environment: `development`

- **Deployment branches:** `develop`
- **Secrets:**
  - `HOSTINGER_IP`: IP du serveur de développement
  - `SSH_PRIVATE_KEY`: Clé SSH pour le serveur de dev
  - `HOSTINGER_USER`: `root`

#### Environment: `production`

- **Deployment branches:** `main`
- **Required reviewers:** Ajouter au moins 1 reviewer
- **Secrets:**
  - `HOSTINGER_IP`: IP du serveur de production
  - `SSH_PRIVATE_KEY`: Clé SSH pour le serveur de prod
  - `HOSTINGER_USER`: `root`

## ✅ Vérification

Pour vérifier que tout est bien configuré:

1. Aller sur **Actions** dans votre repository
2. Sélectionner le workflow **Deploy Only**
3. Cliquer sur **Run workflow**
4. Sélectionner `development` comme environment
5. Sélectionner `all` comme services
6. Cliquer sur **Run workflow**

Si le workflow s'exécute sans erreur, votre configuration est correcte!

## 🔐 Sécurité

### Bonnes Pratiques

1. **Ne jamais commiter de secrets** dans le code
2. **Utiliser des clés SSH dédiées** pour GitHub Actions (pas votre clé personnelle)
3. **Rotation des clés** tous les 6 mois
4. **Limiter les permissions** des clés SSH (pas de sudo si non nécessaire)
5. **Activer la protection de branche** pour `main`
6. **Require approval** pour les déploiements en production

### Rotation des Clés SSH

```bash
# Générer une nouvelle clé
ssh-keygen -t ed25519 -C "github-actions@dealtobook-$(date +%Y%m%d)" -f ~/.ssh/dealtobook_deploy_new

# Copier la nouvelle clé sur le serveur
ssh-copy-id -i ~/.ssh/dealtobook_deploy_new.pub root@VOTRE_IP

# Tester la nouvelle clé
ssh -i ~/.ssh/dealtobook_deploy_new root@VOTRE_IP

# Mettre à jour le secret GitHub
# Settings > Secrets > SSH_PRIVATE_KEY > Update

# Supprimer l'ancienne clé du serveur
ssh root@VOTRE_IP
# Éditer ~/.ssh/authorized_keys et supprimer l'ancienne ligne
```

## 🆘 Troubleshooting

### Erreur: "Permission denied (publickey)"

1. Vérifier que la clé publique est bien dans `~/.ssh/authorized_keys` sur le serveur
2. Vérifier les permissions:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```
3. Vérifier que le secret `SSH_PRIVATE_KEY` contient bien TOUTE la clé (BEGIN/END inclus)

### Erreur: "Host key verification failed"

La clé du serveur n'est pas connue. Le workflow inclut `ssh-keyscan` pour résoudre ce problème automatiquement.

### Erreur: "Could not resolve hostname"

Vérifier que `HOSTINGER_IP` contient bien l'IP (pas le nom de domaine).

## 📚 Ressources

- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [SSH Key Generation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

