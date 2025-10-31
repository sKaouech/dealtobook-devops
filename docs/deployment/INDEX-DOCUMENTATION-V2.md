# 📑 Index de la Documentation - Deploy Script V2

## 🎯 Navigation Rapide

### 🚀 Pour Commencer (15 minutes)
1. [README-DEPLOY-V2.md](./README-DEPLOY-V2.md) - Vue d'ensemble et référence rapide
2. [QUICK-START-V2.md](./QUICK-START-V2.md) - Guide de démarrage avec exemples pratiques

### 🔄 Pour Migrer depuis V1 (30 minutes)
3. [MIGRATION-V1-TO-V2.md](./MIGRATION-V1-TO-V2.md) - Guide complet de migration

### 📚 Pour Approfondir (1 heure)
4. [DEPLOY-SCRIPT-V2-IMPROVEMENTS.md](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md) - Documentation technique détaillée

### 📋 Résumé de Création
5. [SUMMARY-V2-CREATION.md](./SUMMARY-V2-CREATION.md) - Récapitulatif de ce qui a été fait

---

## 📖 Guide de Lecture par Profil

### 👨‍💻 Développeur
**Temps estimé**: 20 minutes

1. **README-DEPLOY-V2.md** - Section "Démarrage Rapide"
2. **QUICK-START-V2.md** - Section "Exemples Courants"
3. Tester quelques commandes:
   \`\`\`bash
   ./deploy-ssl-production-v2.sh ps
   ./deploy-ssl-production-v2.sh logs webui
   ./deploy-ssl-production-v2.sh build security
   \`\`\`

### 🔧 DevOps
**Temps estimé**: 1 heure

1. **SUMMARY-V2-CREATION.md** - Comprendre ce qui a été fait
2. **DEPLOY-SCRIPT-V2-IMPROVEMENTS.md** - Toutes les améliorations
3. **MIGRATION-V1-TO-V2.md** - Plan de migration
4. Tester les nouvelles commandes:
   \`\`\`bash
   ./deploy-ssl-production-v2.sh inspect deal_generator
   ./deploy-ssl-production-v2.sh scale generator 2
   ./deploy-ssl-production-v2.sh exec postgres psql
   \`\`\`

### 👔 Tech Lead / Manager
**Temps estimé**: 15 minutes

1. **SUMMARY-V2-CREATION.md** - Résumé exécutif
2. **README-DEPLOY-V2.md** - Vue d'ensemble
3. **MIGRATION-V1-TO-V2.md** - Section "Comparaison V1 vs V2"

### 🆕 Nouveau dans l'Équipe
**Temps estimé**: 45 minutes

1. **README-DEPLOY-V2.md** - Vue d'ensemble
2. **QUICK-START-V2.md** - Installation et configuration
3. **QUICK-START-V2.md** - Scénarios courants
4. Pratiquer avec les commandes de base

---

## 📁 Structure des Fichiers

\`\`\`
dealtobook-devops/
├── scripts/
│   ├── deploy-ssl-production-v2.sh      # ⭐ Script principal V2
│   ├── deploy-ssl-production.sh         # 📜 Script V1 (legacy)
│   └── test-deploy-v2.sh                # 🧪 Tests automatisés
│
├── INDEX-DOCUMENTATION-V2.md            # 📑 Ce fichier
├── README-DEPLOY-V2.md                  # 📖 Vue d'ensemble
├── QUICK-START-V2.md                    # ⚡ Guide rapide
├── MIGRATION-V1-TO-V2.md                # 🔄 Guide de migration
├── DEPLOY-SCRIPT-V2-IMPROVEMENTS.md     # 📚 Doc technique
└── SUMMARY-V2-CREATION.md               # 📋 Résumé
\`\`\`

---

## 🎯 Par Besoin

### "Je veux déployer rapidement"
→ [QUICK-START-V2.md](./QUICK-START-V2.md#-demarrage-rapide) (Section: Démarrage Rapide)

### "Je veux comprendre les nouveautés"
→ [DEPLOY-SCRIPT-V2-IMPROVEMENTS.md](./DEPLOY-SCRIPT-V2-IMPROVEMENTS.md#-nouvelles-fonctionnalites) (Section: Nouvelles Fonctionnalités)

### "Je veux migrer depuis V1"
→ [MIGRATION-V1-TO-V2.md](./MIGRATION-V1-TO-V2.md#-plan-de-migration) (Section: Plan de Migration)

### "Je veux voir tous les exemples"
→ [QUICK-START-V2.md](./QUICK-START-V2.md#-scenarios-courants) (Section: Scénarios Courants)

### "Je cherche une commande spécifique"
→ [README-DEPLOY-V2.md](./README-DEPLOY-V2.md#-toutes-les-commandes) (Section: Toutes les Commandes)

### "J'ai un problème"
→ [QUICK-START-V2.md](./QUICK-START-V2.md#-troubleshooting-rapide) (Section: Troubleshooting)

### "Je veux voir ce qui a changé"
→ [SUMMARY-V2-CREATION.md](./SUMMARY-V2-CREATION.md#-ce-qui-a-ete-fait) (Section: Ce qui a été fait)

---

## 🔍 Recherche par Mot-Clé

### Build & Déploiement
- Build sélectif → QUICK-START-V2.md, ligne ~150
- Tag personnalisé → DEPLOY-SCRIPT-V2-IMPROVEMENTS.md, ligne ~200
- Deploy sans rebuild → README-DEPLOY-V2.md, ligne ~180

### Services
- Mapping services → DEPLOY-SCRIPT-V2-IMPROVEMENTS.md, ligne ~50
- Alias de services → README-DEPLOY-V2.md, ligne ~250
- Scale services → DEPLOY-SCRIPT-V2-IMPROVEMENTS.md, ligne ~120

### Debug & Monitoring
- Logs → QUICK-START-V2.md, ligne ~100
- Inspect → DEPLOY-SCRIPT-V2-IMPROVEMENTS.md, ligne ~140
- Exec → QUICK-START-V2.md, ligne ~220
- Health check → README-DEPLOY-V2.md, ligne ~200

### Configuration
- Variables d'environnement → README-DEPLOY-V2.md, ligne ~300
- Timeouts → DEPLOY-SCRIPT-V2-IMPROVEMENTS.md, ligne ~180
- SSL Setup → QUICK-START-V2.md, ligne ~400

### Migration
- Plan de migration → MIGRATION-V1-TO-V2.md, ligne ~100
- Comparaison V1/V2 → MIGRATION-V1-TO-V2.md, ligne ~50
- Checklist → MIGRATION-V1-TO-V2.md, ligne ~600

---

## ⚡ Commandes les Plus Utiles

\`\`\`bash
# Aide
./deploy-ssl-production-v2.sh help

# Status
./deploy-ssl-production-v2.sh ps
./deploy-ssl-production-v2.sh health

# Build & Deploy
./deploy-ssl-production-v2.sh build security
./deploy-ssl-production-v2.sh deploy-only security

# Monitoring
./deploy-ssl-production-v2.sh logs webui
./deploy-ssl-production-v2.sh inspect generator

# Debug
./deploy-ssl-production-v2.sh exec postgres psql
./deploy-ssl-production-v2.sh exec security bash

# Scaling
./deploy-ssl-production-v2.sh scale generator 3
./deploy-ssl-production-v2.sh scale generator 1

# Gestion
./deploy-ssl-production-v2.sh restart
./deploy-ssl-production-v2.sh stop security
./deploy-ssl-production-v2.sh start security
\`\`\`

---

## 📊 Statistiques de Documentation

| Fichier | Taille | Lignes | Sections | Exemples |
|---------|--------|--------|----------|----------|
| README-DEPLOY-V2.md | 10KB | 350 | 12 | 25+ |
| QUICK-START-V2.md | 13KB | 450 | 15 | 40+ |
| MIGRATION-V1-TO-V2.md | 11KB | 400 | 14 | 30+ |
| DEPLOY-SCRIPT-V2-IMPROVEMENTS.md | 13KB | 500 | 18 | 50+ |
| SUMMARY-V2-CREATION.md | 8KB | 300 | 10 | 20+ |
| **Total** | **55KB** | **2000** | **69** | **165+** |

---

## 🎓 Parcours d'Apprentissage Recommandé

### Jour 1: Installation et Découverte (2 heures)
- [ ] Lire README-DEPLOY-V2.md (20 min)
- [ ] Installer et configurer (30 min)
- [ ] Tester commandes de base (30 min)
- [ ] Lire QUICK-START-V2.md (40 min)

### Jour 2: Pratique (2 heures)
- [ ] Déployer en dev (30 min)
- [ ] Tester nouvelles commandes (60 min)
- [ ] Lire cas d'usage avancés (30 min)

### Jour 3: Migration (si V1 utilisé) (1 heure)
- [ ] Lire MIGRATION-V1-TO-V2.md (30 min)
- [ ] Comparer commandes V1/V2 (30 min)

### Semaine 1: Maîtrise (5 heures)
- [ ] Lire doc technique complète (2 heures)
- [ ] Créer scripts personnalisés (2 heures)
- [ ] Documenter cas d'usage équipe (1 heure)

---

## 💡 Conseils de Lecture

### Pour une Lecture Rapide (Skimming)
1. Lire les titres et sous-titres
2. Regarder les tableaux et exemples
3. Noter les commandes importantes
4. Marquer les sections à approfondir

### Pour une Lecture Approfondie
1. Lire section par section
2. Tester chaque exemple
3. Prendre des notes
4. Créer des alias personnalisés

### Pour Référence Future
1. Bookmarker ce fichier INDEX
2. Noter les sections importantes
3. Créer un guide d'équipe personnalisé
4. Maintenir un changelog des usages

---

## 🔗 Liens Rapides

### Documentation
- [Script Principal](./scripts/deploy-ssl-production-v2.sh)
- [Tests](./scripts/test-deploy-v2.sh)

### Ressources Externes
- [GitHub Packages](https://github.com/skaouech?tab=packages)
- [Docker Hub](https://hub.docker.com/)
- [Let's Encrypt](https://letsencrypt.org/)

### Support
- Slack: #devops-support
- Email: devops@dealtobook.com
- Issues: GitHub Issues

---

## ✅ Checklist Première Utilisation

- [ ] Lire INDEX-DOCUMENTATION-V2.md (ce fichier)
- [ ] Choisir le guide approprié selon mon profil
- [ ] Lire le guide choisi
- [ ] Installer et configurer le script
- [ ] Tester les commandes de base
- [ ] Créer mes alias bash personnalisés
- [ ] Bookmarker la documentation
- [ ] Partager avec l'équipe

---

## 🎯 Aide au Choix

**"Quel fichier lire en premier ?"**

- Si vous êtes **pressé** (5 min) → README-DEPLOY-V2.md (section Vue d'Ensemble)
- Si vous êtes **nouveau** (30 min) → QUICK-START-V2.md
- Si vous **migrez de V1** (20 min) → MIGRATION-V1-TO-V2.md
- Si vous voulez **tout comprendre** (1h) → DEPLOY-SCRIPT-V2-IMPROVEMENTS.md
- Si vous voulez **un résumé** (10 min) → SUMMARY-V2-CREATION.md

---

**Bonne lecture ! 📚**

*Dernière mise à jour: 2025-10-28*
