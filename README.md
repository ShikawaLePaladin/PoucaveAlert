# 🚨 PoucaveAlert

**Addon WoW Turtle WoW (1.12)** - Détecte et annonce dans le raid:
- 👟 **Qui bouge** pendant **Shackle of the Legion** (Mephistroth)
- ⚠️ **Qui dispel les mauvais sorts** (50+ sorts dangereux référencés)

Fini les wipes à cause d'un joueur qui bouge ou d'un mauvais dispel! 🎯

---

## 📦 Installation

1. Télécharger le dossier `PoucaveAlert`
2. Placer dans `World of Warcraft\Interface\AddOns\`
3. Redémarrer WoW ou taper `/reload`
4. Vérifier avec `/pa status`

---

## 🎯 Fonctionnalités

### ✅ Détection Shackle of the Legion
- Scan automatique de tous les joueurs du raid/groupe
- Surveillance des mouvements toutes les 0.1 secondes
- Annonce immédiate si quelqu'un bouge: `"Shikawa BOUGE PENDANT SHACKLE! ⚠️"`
- Alerte sonore configurable

### ✅ Détection des Mauvais Dispels
- **50+ sorts interdits** dans la base de données
- Détection en temps réel des dispels/decurse
- Annonce normale pour les dispels autorisés:
  ```
  Pomme a dispel [Corruption] de Tank
  ```
- **ALERTE SPÉCIALE** pour les dispels interdits:
  ```
  ⚠️⚠️⚠️ Healer a DISPEL [Arcane Bomb] (Magie) de DPS — Anomalus: 💀 EXPLOSION INSTANT WIPE! ⚠️⚠️⚠️
  ```

### Boss couverts avec sorts interdits:
- 🌙 **Gnarlmoon** (2 sorts)
- 🔵 **Incantagos** (4 sorts)  
- 💠 **Anomalus** (2 sorts - Arcane Bomb = instant wipe!)
- 🧊 **Medivh** (5 sorts)
- ♟️ **Chess Event** (7 sorts)
- 🌀 **Sanv Tasdal** (6 sorts - Phase Shifted très dangereux!)
- 🗡️ **Krull** (4 sorts - Mana Detonation = explosion!)
- 🔥 **Mephistroth** (3 sorts)

---

## 🎮 Commandes

```
/poucavealert  ou  /poucave  ou  /pa
```

### Commandes disponibles:

| Commande | Description |
|----------|-------------|
| `/pa on` | Activer l'addon |
| `/pa off` | Désactiver l'addon |
| `/pa debug` | Toggle mode debug (voir toutes les détections) |
| `/pa sound` | Toggle alertes sonores |
| `/pa scan` | Toggle scan automatique des debuffs |
| `/pa dispel` | Toggle annonce des dispels |
| `/pa list` | Afficher tous les sorts à ne pas dispel (par boss) |
| `/pa test` | Tester la détection de mouvement |
| `/pa reset` | Réinitialiser la liste de surveillance |
| `/pa status` | Voir le statut et la configuration actuelle |

---

## ⚙️ Configuration

L'addon sauvegarde automatiquement vos paramètres dans `PoucaveAlertDB`. Configuration par défaut:

- ✅ **Activé** par défaut
- 📢 **Canal d'annonce**: RAID_WARNING (nécessite RL/Officier)
- 🔊 **Alertes sonores**: Activées
- 🔍 **Scan automatique**: Activé (scan toutes les 0.5s)
- 📣 **Annonce dispels**: Activée
- 🐛 **Mode debug**: Désactivé

---

## 🔧 Comment ça marche

### Détection de Shackle:
1. Scan automatique des debuffs de tous les joueurs du raid
2. Détection du debuff "Shackle of the Legion"
3. Enregistrement de la position du joueur
4. Vérification du mouvement toutes les 0.1 secondes
5. Annonce si mouvement > 0.5 yard détecté

### Détection des Dispels:
1. Écoute des événements de dispel/decurse dans le combat log
2. Extraction: qui a dispel, quel sort, sur qui
3. Vérification dans la liste des sorts interdits
4. Annonce normale OU alerte spéciale selon le sort

---

## 🎨 Exemple d'utilisation

```
[Raid] PoucaveAlert: Pomme a dispel [Corruption] de Shikawa
⚠️⚠️⚠️ Healer a DISPEL [Phase Shifted] (Magie) de DPS — Sanv Tasdal: 💀 TRÈS DANGEREUX! ⚠️⚠️⚠️
[Raid Warning] Tank BOUGE PENDANT SHACKLE! ⚠️
```

---

## 💡 Conseils

### Pour les Raid Leaders:
- Activez l'addon sur tous les membres du raid
- Utilisez `/pa list` pour briefer sur les sorts à ne pas dispel
- Le mode debug peut aider à identifier les problèmes

### Pour les Healers/Dispellers:
- **LISEZ** la liste des sorts interdits avec `/pa list`
- Faites attention aux annonces de dispel
- En cas de doute, **NE DISPEL PAS**

### Types de debuff par classe:
- 🔵 **Magie** → Priest (Dispel Magic), Paladin (Cleanse), Mage (Remove Lesser Curse)
- 🟢 **Malédiction** → Druid (Remove Curse), Mage (Remove Lesser Curse)
- 🔴 **Autre** → Mécaniques spéciales (non dispellable normalement)

---

## 🐛 Dépannage

**L'addon ne se charge pas:**
- Vérifiez que le dossier s'appelle bien `PoucaveAlert`
- Vérifiez que les fichiers sont au bon endroit
- Faites `/reload`

**Pas de détection des mouvements:**
- Activez le mode debug: `/pa debug`
- Testez avec `/pa test` et bougez
- Vérifiez que le scan auto est activé: `/pa scan`

**Pas d'annonce des dispels:**
- Vérifiez: `/pa dispel` (doit être activé)
- Le sort peut avoir un nom différent sur votre serveur
- Activez debug pour voir les messages de combat

**Le nom du sort est différent:**
- Les noms de sorts peuvent varier (EN/FR)
- Contactez-moi pour ajouter d'autres variantes

---

## 📝 Notes techniques

- **Compatible**: WoW 1.12 (Vanilla / Turtle WoW)
- **Détection mouvement**: `GetPlayerMapPosition()` 
- **Seuil de mouvement**: ~0.5 yard
- **Intervalle scan**: 0.5 secondes
- **Intervalle mouvement**: 0.1 secondes
- **Sauvegarde**: `PoucaveAlertDB` (SavedVariables)

---

## 🤝 Contribution

Des sorts manquants? Un bug? Une suggestion?
- Ouvrez une Issue sur GitHub
- Proposez une Pull Request
- Contactez Poucave in-game

---

## 📜 Licence

Libre d'utilisation et de modification. Pas de garantie - utilisez à vos risques et périls (mais ça devrait aider à éviter les wipes! 😄)

---

## 🎖️ Crédits

**Développé par**: Poucave  
**Version**: 1.0.0  
**Serveur**: Turtle WoW  
**Date**: Décembre 2025

---

## 🔮 Roadmap / Idées futures

- [ ] Interface graphique pour la configuration
- [ ] Statistiques: qui fait le plus de mauvais dispels
- [ ] Intégration avec BigWigs/DBM
- [ ] Support pour d'autres mécaniques similaires
- [ ] Blacklist personnalisable de sorts
- [ ] Export/import de configuration

---

**Bon raid et que Poucave veille sur vous!** 🎯🔥