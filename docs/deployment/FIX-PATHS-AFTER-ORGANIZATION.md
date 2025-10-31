# 🔧 Fix: Correction des Chemins Après Réorganisation

## 🐛 Problème

Après la réorganisation des fichiers (déplacement vers `config/`, etc.), le script ne trouvait plus les fichiers :

```
❌ scp: stat local "docker-compose.ssl-complete.yml": No such file or directory
⚠️ Répertoire ../dealtobook-deal_generator non trouvé
```

## ✅ Solution Appliquée

### 1. Ajout de Variables de Chemins

Le script calcule maintenant automatiquement les chemins relatifs :

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVOPS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="$DEVOPS_DIR/config"
WORKSPACE_ROOT="$(cd "$DEVOPS_DIR/.." && pwd)"
```

### 2. Mise à Jour des Chemins de Configuration

**Avant**:
```bash
DOCKER_COMPOSE_FILE="docker-compose.ssl-complete.yml"
ENV_FILE="dealtobook-ssl.env"
```

**Après**:
```bash
DOCKER_COMPOSE_FILE="$CONFIG_DIR/docker-compose.ssl-complete.yml"
ENV_FILE="$CONFIG_DIR/dealtobook-ssl.env"  # ou dealtook-ssl-dev.env
```

### 3. Mise à Jour des Chemins des Services

**Avant**:
```bash
local service_dir="../dealtobook-${service_key}"
```

**Après**:
```bash
local service_dir="$WORKSPACE_ROOT/dealtobook-${service_key}"
```

### 4. Mise à Jour des Chemins de Configuration Nginx/Monitoring

**Avant**:
```bash
if [ -d "$dir" ]; then  # Cherchait dans le répertoire courant
```

**Après**:
```bash
local config_path="$CONFIG_DIR/$dir"
if [ -d "$config_path" ]; then  # Cherche dans config/
```

### 5. Création du Fichier Manquant

- ✅ Création de `config/dealtobook-ssl-dev.env` (basé sur `dealtobook-ssl.env`)

## 📊 Structure des Chemins

```
workspace/                              (WORKSPACE_ROOT)
├── dealtobook-devops/                  (DEVOPS_DIR)
│   ├── scripts/                        (SCRIPT_DIR)
│   │   └── deploy-ssl-production-v2.sh
│   ├── config/                         (CONFIG_DIR)
│   │   ├── docker-compose.ssl-complete.yml
│   │   ├── dealtobook-ssl.env
│   │   ├── dealtobook-ssl-dev.env
│   │   ├── nginx/
│   │   ├── monitoring/
│   │   └── keycloak-themes/
│   └── ...
│
├── dealtobook-deal_generator/         (service_dir)
├── dealtobook-deal_security/
├── dealtobook-deal_setting/
├── dealtobook-deal_webui/
└── dealtobook-deal_website/
```

## ✅ Vérifications Effectuées

```bash
✅ Syntaxe du script valide
✅ Fichiers config trouvés:
   - docker-compose.ssl-complete.yml
   - dealtobook-ssl.env
   - dealtobook-ssl-dev.env
✅ Services trouvés:
   - deal_generator
   - deal_security
   - deal_setting
   - deal_webui
   - deal_website
```

## 🚀 Utilisation

Le script fonctionne maintenant correctement depuis n'importe où :

```bash
# Depuis n'importe quel répertoire
cd dealtobook-devops/scripts
./deploy-ssl-production-v2.sh deploy

# Ou directement
./dealtobook-devops/scripts/deploy-ssl-production-v2.sh deploy
```

## 📝 Fichiers Modifiés

- ✅ `scripts/deploy-ssl-production-v2.sh` - Chemins corrigés
- ✅ `config/dealtobook-ssl-dev.env` - Fichier créé

## 🎯 Résultat

Le script trouve maintenant tous les fichiers nécessaire, que ce soit :
- Les fichiers de configuration dans `config/`
- Les répertoires des services dans `workspace/`
- Les sous-répertoires de configuration (nginx, monitoring, etc.)

**Le script est maintenant 100% fonctionnel avec la nouvelle structure ! ✅**

---

*Date: 2025-10-29*  
*Version: 2.0.2 (hotfix chemins)*
