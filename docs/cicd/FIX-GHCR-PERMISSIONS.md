# 🔐 Fix: GitHub Container Registry Permissions

Guide rapide pour résoudre l'erreur `permission_denied: write_package`

## 🐛 Erreur

```
denied: permission_denied: write_package
Error: Process completed with exit code 1.
```

## ✅ Solution en 3 Étapes (2 minutes)

### Étape 1️⃣ : Ouvrir les Settings

Allez sur votre repo GitHub :
```
https://github.com/skaouech/[NOM-DU-REPO]
```

Exemples :
- https://github.com/skaouech/dealtobook-deal_setting
- https://github.com/skaouech/dealtobook-deal_generator
- https://github.com/skaouech/dealtobook-deal_security

Cliquez sur **"Settings"** (onglet en haut)

---

### Étape 2️⃣ : Naviguer vers Actions > General

Dans le **menu de gauche**, cliquez sur :
1. **"Actions"** 
2. **"General"**

---

### Étape 3️⃣ : Modifier Workflow Permissions

Scrollez vers le bas jusqu'à la section **"Workflow permissions"**

Vous verrez 2 options :

```
⚪ Read repository contents and packages permissions  ← Actuel (problème)
☑️ Read and write permissions                         ← Sélectionnez celle-ci!
```

**Sélectionnez** : `Read and write permissions`

**Cochez aussi** :
```
☑️ Allow GitHub Actions to create and approve pull requests
```

**Cliquez sur** : Bouton **"Save"** (en bas de page)

---

## 🔄 Relancer le Workflow

Retournez sur **Actions** :
```
https://github.com/skaouech/[NOM-DU-REPO]/actions
```

**Option 1** : Re-run le job échoué
- Cliquez sur le run échoué
- Cliquez sur **"Re-run failed jobs"** (bouton en haut à droite)

**Option 2** : Lancer un nouveau run
- Cliquez sur **"build-and-push.yml"** (menu gauche)
- Cliquez sur **"Run workflow"** (bouton en haut à droite)
- Branch: **develop**
- Cliquez sur le bouton vert **"Run workflow"**

---

## 🎯 Résultat Attendu

Après la correction, le workflow devrait :

```
✅ 1. Checkout code
✅ 2. Setup JDK 17
✅ 3. Build with Maven
✅ 4. Build Docker with Jib
✅ 5. Determine image tag
✅ 6. Tag Docker Images
✅ 7. Login to GHCR
✅ 8. Push Docker Images  ← VA RÉUSSIR MAINTENANT!
✅ 9. Summary
```

Temps estimé : **~5 minutes**

---

## 📦 Vérifier les Images dans GHCR

Une fois le workflow terminé avec succès, vérifiez que les images sont bien créées :

```
https://github.com/[USERNAME]?tab=packages
```

Exemple : https://github.com/skaouech?tab=packages

Vous devriez voir votre package (ex: `dealsetting`) avec les tags :
- ✅ `develop`
- ✅ `sha-[commit]`

---

## 🔁 Appliquer à Tous les Repos

Cette modification doit être faite pour **CHAQUE REPO** :

### Repos Backend (Services)
- [ ] `dealtobook-deal_setting`
- [ ] `dealtobook-deal_generator`
- [ ] `dealtobook-deal_security`

### Repos Frontend
- [ ] `dealtobook-deal_website`
- [ ] `dealtobook-deal_webui`

### Repo DevOps (Orchestration)
- [ ] `dealtobook-devops`

**Astuce** : Faites-le au fur et à mesure que vous ajoutez le workflow dans chaque repo.

---

## ❓ Pourquoi ce Problème ?

### Permission Par Défaut (❌ Problème)

GitHub configure par défaut les nouveaux repos avec :
```
Read repository contents and packages permissions
```

Cette option permet **UNIQUEMENT** :
- ✅ Lire le code
- ✅ Pull des images
- ❌ **Push des images** ← BLOQUÉ!

### Permission Corrigée (✅ Solution)

En changeant pour :
```
Read and write permissions
```

Le workflow peut maintenant :
- ✅ Lire le code
- ✅ Pull des images
- ✅ **Push des images** ← AUTORISÉ!

---

## 🔒 Sécurité

### Est-ce Sécurisé ?

**OUI !** Cette permission concerne uniquement le `GITHUB_TOKEN` utilisé par **GitHub Actions** :

- ✅ Le token est **automatique** et **temporaire**
- ✅ Le token est **limité au repo** où le workflow s'exécute
- ✅ Le token **expire** à la fin du workflow
- ✅ Le token **ne peut pas** accéder à d'autres repos
- ✅ Le token **ne peut pas** modifier les settings du repo

### Permissions Accordées

Avec "Read and write permissions", le `GITHUB_TOKEN` peut :
- ✅ Lire le code source
- ✅ Créer/modifier des pull requests
- ✅ Push des images vers GHCR (packages)
- ✅ Créer des releases
- ❌ **Ne peut PAS** modifier les Settings
- ❌ **Ne peut PAS** supprimer le repo
- ❌ **Ne peut PAS** gérer les webhooks

---

## 📚 Liens Utiles

### Documentation GitHub
- [Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
- [Permissions for the GITHUB_TOKEN](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)
- [Working with Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

### Documentation Locale
- [ERRORS-AND-SOLUTIONS.md](./ERRORS-AND-SOLUTIONS.md) - Toutes les erreurs documentées
- [TROUBLESHOOTING-WORKFLOW-MANUAL.md](./TROUBLESHOOTING-WORKFLOW-MANUAL.md) - Guide de troubleshooting complet

---

## 🆘 Besoin d'Aide ?

Si le problème persiste après avoir suivi ce guide :

1. **Vérifiez** que vous avez bien cliqué sur **"Save"**
2. **Vérifiez** que le bon repo est sélectionné (pas un fork)
3. **Attendez** 10 secondes et rafraîchissez la page
4. **Relancez** le workflow (parfois il faut relancer 2 fois)
5. **Vérifiez** les logs du workflow pour d'autres erreurs

Si ça ne fonctionne toujours pas, partagez :
- Le message d'erreur complet
- Une capture d'écran de Settings > Actions > General > Workflow permissions
- Le nom du repo concerné

---

## ✅ Checklist

Avant de passer au repo suivant :

- [ ] Settings > Actions > General ouvert
- [ ] "Read and write permissions" sélectionné
- [ ] "Allow GitHub Actions to create and approve pull requests" coché
- [ ] Bouton "Save" cliqué
- [ ] Workflow relancé
- [ ] Workflow réussi (✅ check vert)
- [ ] Images visibles dans https://github.com/[USERNAME]?tab=packages

---

**Version:** 1.0  
**Date:** 2025-10-31  
**Status:** ✅ Testé et validé

