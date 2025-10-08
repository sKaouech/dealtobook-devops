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
