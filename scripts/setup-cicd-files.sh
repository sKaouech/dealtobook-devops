#!/bin/bash

echo "🚀 Configuration des fichiers CI/CD pour tous les services DealToBook"
echo ""

# Configuration
WORKSPACE_ROOT="$(dirname "$(dirname "$(pwd)")")"
DEVOPS_DIR="$(pwd)"

echo "Workspace root: $WORKSPACE_ROOT"
echo "DevOps directory: $DEVOPS_DIR"
echo ""

# Services backend (Spring Boot)
BACKEND_SERVICES=(
    "dealtobook-deal_generator"
    "dealtobook-deal_security" 
    "dealtobook-deal_setting"
)

# Services frontend (Angular)
FRONTEND_SERVICES=(
    "dealtobook-deal_webui"
    "dealtobook-deal_website"
)

# Fonction pour créer les fichiers CI/CD pour un service backend
setup_backend_service() {
    local service_dir="$1"
    local service_name=$(basename "$service_dir")
    
    echo "📦 Configuration du service backend: $service_name"
    
    if [ ! -d "$service_dir" ]; then
        echo "❌ Répertoire $service_dir non trouvé"
        return 1
    fi
    
    cd "$service_dir"
    
    # Créer le répertoire .github/workflows
    mkdir -p .github/workflows
    
    # Copier le Dockerfile backend
    cp "$DEVOPS_DIR/../Dockerfile.backend-template" ./Dockerfile
    
    # Copier le workflow GitHub Actions
    cp "$DEVOPS_DIR/../github-workflow-backend.yml" .github/workflows/ci-cd.yml
    
    # Copier le .gitignore approprié
    cp "$DEVOPS_DIR/../.gitignore-backend" .gitignore
    
    # Créer un README.md avec les instructions CI/CD
    cat > README.md << EOF
# $service_name

Service backend DealToBook basé sur Spring Boot.

## 🚀 CI/CD

### Déploiement Automatique
- **Push sur \`main\`** → Déploiement automatique en production
- **Push sur \`develop\`** → Build et tests uniquement
- **Pull Request** → Build et tests uniquement

### Workflow
1. Build Maven avec JDK 17
2. Build de l'image Docker
3. Push vers GitHub Container Registry (GHCR)
4. Déploiement sur Hostinger
5. Health check automatique
6. Rollback automatique en cas d'échec

### Images Docker
- **Registry**: \`ghcr.io/skaouech/$service_name\`
- **Tags**: \`latest\`, \`main-{sha}\`, \`{sha}\`

### Health Check
- **Endpoint**: \`/management/health\`
- **Timeout**: 45 secondes
- **Retries**: 5 tentatives

### Secrets Requis
Configurés dans les settings du repository :
- \`HOSTINGER_HOST\`: IP du serveur (148.230.114.13)
- \`HOSTINGER_USER\`: Utilisateur SSH (root)
- \`HOSTINGER_SSH_KEY\`: Clé SSH privée

## 🛠️ Développement Local

### Prérequis
- JDK 17
- Maven 3.9+
- Docker

### Build
\`\`\`bash
mvn clean compile
mvn clean package -DskipTests -Pprod
\`\`\`

### Docker
\`\`\`bash
docker build -t $service_name .
docker run -p 8080:8080 $service_name
\`\`\`

## 📊 Monitoring

- **Métriques**: Prometheus (\`/actuator/prometheus\`)
- **Health**: \`/management/health\`
- **Info**: \`/management/info\`
EOF
    
    echo "✅ $service_name configuré"
    cd "$WORKSPACE_ROOT"
}

# Fonction pour créer les fichiers CI/CD pour un service frontend
setup_frontend_service() {
    local service_dir="$1"
    local service_name=$(basename "$service_dir")
    
    echo "🎨 Configuration du service frontend: $service_name"
    
    if [ ! -d "$service_dir" ]; then
        echo "❌ Répertoire $service_dir non trouvé"
        return 1
    fi
    
    cd "$service_dir"
    
    # Créer le répertoire .github/workflows
    mkdir -p .github/workflows
    
    # Copier le Dockerfile frontend
    cp "$DEVOPS_DIR/../Dockerfile.frontend-template" ./Dockerfile
    
    # Copier le workflow GitHub Actions
    cp "$DEVOPS_DIR/../github-workflow-frontend.yml" .github/workflows/ci-cd.yml
    
    # Copier le .gitignore approprié
    cp "$DEVOPS_DIR/../.gitignore-frontend" .gitignore
    
    # Créer une configuration Nginx simple si elle n'existe pas
    if [ ! -f "nginx.conf" ]; then
        cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;
        
        # Support pour les routes Angular (SPA)
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        # Cache pour les assets statiques
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF
    fi
    
    # Créer un README.md avec les instructions CI/CD
    cat > README.md << EOF
# $service_name

Service frontend DealToBook basé sur Angular.

## 🚀 CI/CD

### Déploiement Automatique
- **Push sur \`main\`** → Déploiement automatique en production
- **Push sur \`develop\`** → Build et tests uniquement
- **Pull Request** → Build et tests uniquement

### Workflow
1. Build Angular avec Node.js 18
2. Build de l'image Docker avec Nginx
3. Push vers GitHub Container Registry (GHCR)
4. Déploiement sur Hostinger
5. Health check automatique
6. Rollback automatique en cas d'échec

### Images Docker
- **Registry**: \`ghcr.io/skaouech/$service_name\`
- **Tags**: \`latest\`, \`main-{sha}\`, \`{sha}\`

### Health Check
- **URL**: Déterminée automatiquement selon le service
  - \`deal-webui\`: https://administration-dev.dealtobook.com
  - \`deal-website\`: https://website-dev.dealtobook.com
- **Timeout**: 30 secondes
- **Retries**: 5 tentatives

### Secrets Requis
Configurés dans les settings du repository :
- \`HOSTINGER_HOST\`: IP du serveur (148.230.114.13)
- \`HOSTINGER_USER\`: Utilisateur SSH (root)
- \`HOSTINGER_SSH_KEY\`: Clé SSH privée

## 🛠️ Développement Local

### Prérequis
- Node.js 18+
- npm ou yarn
- Angular CLI 14

### Installation
\`\`\`bash
npm install --legacy-peer-deps
\`\`\`

### Développement
\`\`\`bash
ng serve
\`\`\`

### Build
\`\`\`bash
ng build --prod
\`\`\`

### Docker
\`\`\`bash
docker build -t $service_name .
docker run -p 80:80 $service_name
\`\`\`

## 🎨 Configuration

### Variables d'Environnement
Les variables sont substituées au runtime via \`docker-entrypoint.sh\`:
- \`KEYCLOAK_URL\`
- \`KEYCLOAK_REALM\`
- \`KEYCLOAK_CLIENT_ID\`
- \`API_*_URL\`

### Nginx
Configuration dans \`nginx.conf\` pour :
- Support des routes SPA
- Gzip compression
- Cache des assets statiques
EOF
    
    echo "✅ $service_name configuré"
    cd "$WORKSPACE_ROOT"
}

# Configuration du repo DevOps
setup_devops_repo() {
    echo "⚙️ Configuration du repository DevOps"
    
    cd "$DEVOPS_DIR"
    
    # Créer le répertoire .github/workflows
    mkdir -p .github/workflows
    
    # Copier le workflow d'orchestration
    cp github-workflow-orchestration.yml .github/workflows/full-deployment.yml
    
    # Créer un README.md pour le repo DevOps
    cat > README.md << 'EOF'
# DealToBook DevOps

Repository central pour l'infrastructure et le déploiement de la plateforme DealToBook.

## 🏗️ Architecture

### Services
- **Backend Services**: Spring Boot (deal-generator, deal-security, deal-setting)
- **Frontend Services**: Angular (deal-webui, deal-website)
- **Infrastructure**: PostgreSQL, Keycloak, Nginx, Monitoring

### Environnements
- **Production**: Hostinger VPS (148.230.114.13)
- **Future**: Kubernetes sur AWS EKS

## 🚀 Déploiement

### Déploiement Complet
```bash
# Via GitHub Actions (recommandé)
# Aller dans Actions → Full Stack Deployment Orchestration → Run workflow

# Ou via API
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/skaouech/dealtobook-devops/dispatches \
  -d '{"event_type":"deploy-all"}'
```

### Déploiement Sélectif
```bash
# Déployer seulement certains services
# Dans GitHub Actions, spécifier: deal-generator,deal-security
```

### Déploiement d'Urgence
```bash
# Connexion directe au serveur
ssh root@148.230.114.13
cd /opt/dealtobook
docker-compose -f docker-compose.ssl-complete.yml pull
docker-compose -f docker-compose.ssl-complete.yml up -d
```

## 📁 Structure

```
dealtobook-devops/
├── .github/workflows/          # Workflows GitHub Actions
├── docker-compose/            # Configurations Docker Compose
├── nginx/                     # Configurations Nginx
├── keycloak-themes/          # Thèmes Keycloak personnalisés
├── scripts/                  # Scripts de déploiement et maintenance
├── monitoring/               # Configuration monitoring (Prometheus, Grafana)
└── docs/                    # Documentation technique
```

## 🔧 Configuration

### Secrets GitHub
- `HOSTINGER_HOST`: 148.230.114.13
- `HOSTINGER_USER`: root
- `HOSTINGER_SSH_KEY`: Clé SSH privée
- `POSTGRES_PASSWORD`: Mot de passe PostgreSQL
- `KEYCLOAK_ADMIN_PASSWORD`: Mot de passe admin Keycloak

### Variables d'Environnement
- `REGISTRY`: ghcr.io/skaouech
- `COMPOSE_FILE`: docker-compose.ssl-complete.yml
- `ENVIRONMENT`: prod

## 🏥 Monitoring

### URLs de Santé
- **Administration**: https://administration-dev.dealtobook.com
- **Website**: https://website-dev.dealtobook.com
- **Keycloak**: https://keycloak-dev.dealtobook.com
- **Grafana**: https://administration-dev.dealtobook.com:3000
- **Prometheus**: https://administration-dev.dealtobook.com:9090

### Health Checks
Tous les services exposent des endpoints de santé :
- **Backend**: `/management/health`
- **Frontend**: Status HTTP 200
- **Infrastructure**: Endpoints spécifiques

## 🔄 Rollback

### Automatique
- Health check échoue → Rollback automatique
- Images de backup conservées automatiquement

### Manuel
```bash
ssh root@148.230.114.13
cd /opt/dealtobook

# Lister les backups disponibles
docker images | grep backup

# Restaurer un service spécifique
docker tag deal-security:backup-20241009 deal-security:latest
docker-compose -f docker-compose.ssl-complete.yml up -d --no-deps deal-security
```

## 📊 Métriques

### Déploiement
- **Fréquence**: Automatique sur push main
- **Durée moyenne**: 5-8 minutes
- **Taux de succès**: Surveillé via GitHub Actions

### Performance
- **Monitoring**: Prometheus + Grafana
- **Logs**: Centralisés via Docker Compose
- **Alertes**: À configurer selon les besoins

## 🛠️ Maintenance

### Nettoyage Automatique
- Images Docker anciennes (garde les 3 dernières)
- Backups de configuration (garde les 5 derniers)
- Logs rotatifs

### Mise à Jour
- **Services**: Automatique via CI/CD
- **Infrastructure**: Manuel avec validation
- **Certificats SSL**: Automatique (Let's Encrypt)

## 🔮 Roadmap

### Phase 2: Kubernetes
- Migration vers AWS EKS
- Helm Charts
- ArgoCD pour GitOps
- Multi-environnement (dev/staging/prod)

### Phase 3: Améliorations
- Tests automatisés
- Security scanning
- Performance monitoring
- Notifications Slack/Discord
EOF
    
    echo "✅ Repository DevOps configuré"
}

# Exécution du setup
echo "🚀 Début de la configuration CI/CD..."
echo ""

# Aller dans le workspace root
cd "$WORKSPACE_ROOT"

# Configurer les services backend
for service in "${BACKEND_SERVICES[@]}"; do
    setup_backend_service "$WORKSPACE_ROOT/$service"
done

echo ""

# Configurer les services frontend  
for service in "${FRONTEND_SERVICES[@]}"; do
    setup_frontend_service "$WORKSPACE_ROOT/$service"
done

echo ""

# Configurer le repo DevOps
setup_devops_repo

echo ""
echo "🎉 Configuration CI/CD terminée !"
echo ""
echo "📋 Prochaines étapes :"
echo "1. Commit et push des changements dans chaque repository"
echo "2. Configurer les secrets GitHub dans chaque repo :"
echo "   - HOSTINGER_HOST=148.230.114.13"
echo "   - HOSTINGER_USER=root" 
echo "   - HOSTINGER_SSH_KEY=<clé SSH privée>"
echo "3. Tester le premier déploiement avec un push sur main"
echo "4. Vérifier les workflows dans GitHub Actions"
echo ""
echo "🔗 Repositories configurés :"
for service in "${BACKEND_SERVICES[@]}" "${FRONTEND_SERVICES[@]}"; do
    echo "   - https://github.com/skaouech/$service"
done
echo "   - https://github.com/skaouech/dealtobook-devops"
