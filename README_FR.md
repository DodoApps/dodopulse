# DodoPulse

🌍 **Disponible en 7 langues :** 🇺🇸 [English](README.md) | 🇹🇷 [Türkçe](README_TR.md) | 🇩🇪 [Deutsch](README_DE.md) | 🇫🇷 Français | 🇪🇸 [Español](README_ES.md) | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 [中文](README_ZH.md)

Une application légère et native pour la barre de menus macOS qui affiche les métriques système en temps réel avec de beaux mini-graphiques.

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Licence](https://img.shields.io/badge/Licence-MIT-green)

## Fonctionnalités

- **Surveillance CPU** - Pourcentage d'utilisation, température, fréquence (Intel), suivi par cœur avec graphique historique
- **Surveillance mémoire** - Mémoire utilisée/libre, répartition active/wired/compressée
- **Surveillance GPU** - Pourcentage d'utilisation, température, taux de rafraîchissement de l'écran (Hz)
- **Surveillance réseau** - Vitesses de téléchargement/envoi, IP locale et publique, totaux de session
- **Surveillance disque** - Pourcentage d'utilisation, espace libre, santé du SSD (si disponible)
- **Surveillance batterie** - Niveau de charge, état de charge, temps restant, consommation électrique
- **Surveillance ventilateurs** - RPM pour chaque ventilateur (si disponible)
- **Infos système** - Charge moyenne, nombre de processus, utilisation swap, version du noyau, temps de fonctionnement, luminosité de l'écran
- **Support multilingue** - Choisissez votre langue depuis le menu (7 langues disponibles)

### Fonctionnalités interactives

- **Cliquez** sur n'importe quelle carte pour ouvrir l'application système correspondante (Moniteur d'activité, Utilitaire de disque, Préférences Système, etc.)
- **Clic droit** sur l'icône de la barre de menus pour un menu rapide avec paramètres et sélection de langue

## Comparaison avec les alternatives payantes

| Fonctionnalité | DodoPulse | iStat Menus | TG Pro | Sensei |
|----------------|-----------|-------------|--------|--------|
| **Prix** | Gratuit | ~$14 | $10 | $29 |
| **Surveillance CPU** | ✅ | ✅ | ✅ | ✅ |
| **Surveillance GPU** | ✅ | ✅ | ✅ | ✅ |
| **Surveillance mémoire** | ✅ | ✅ | ❌ | ✅ |
| **Surveillance réseau** | ✅ Multi-interface | ✅ Par app | ❌ | ❌ |
| **Surveillance disque** | ✅ | ✅ | ✅ | ✅ |
| **Surveillance batterie** | ✅ | ✅ + Bluetooth | ✅ | ✅ |
| **Contrôle ventilateurs** | ❌ | ✅ | ✅ | ✅ |
| **Météo** | ❌ | ✅ | ❌ | ❌ |
| **Outils d'optimisation** | ❌ | ❌ | ❌ | ✅ |
| **Open source** | ✅ | ❌ | ❌ | ❌ |
| **Fichier unique** | ✅ (~2000 lignes) | ❌ | ❌ | ❌ |

**Pourquoi DodoPulse ?** Gratuit, open source, léger (~1-2% CPU), axé sur la confidentialité (pas d'analytique) et facile à auditer/modifier.

## Configuration requise

- macOS 12.0 (Monterey) ou ultérieur
- Mac Apple Silicon ou Intel

## Installation

> **À propos de la notarisation :** DodoPulse n'est actuellement pas notarisé par Apple. La notarisation est le processus de sécurité d'Apple qui analyse les applications à la recherche de logiciels malveillants avant leur distribution. Sans elle, macOS peut afficher des avertissements comme "l'app est endommagée" ou "ne peut pas être ouverte". Il est sûr de contourner cela pour les applications open source comme DodoPulse où vous pouvez inspecter le code vous-même. **Solution :** Exécutez `xattr -cr /Applications/DodoPulse.app` dans le Terminal, puis ouvrez l'app. La notarisation est prévue pour une version future.

### Option 1 : Homebrew (recommandé)

```bash
brew tap dodoapps/tap
brew install --cask dodopulse
```

Au premier lancement, faites un clic droit sur l'app → Ouvrir → confirmer. Ou exécutez : `xattr -cr /Applications/DodoPulse.app`

### Option 2 : Télécharger le DMG

1. Téléchargez le dernier DMG depuis [Releases](https://github.com/dodoapps/dodopulse/releases)
2. Ouvrez le DMG et glissez DodoPulse dans Applications
3. Au premier lancement, clic droit → Ouvrir → confirmer (voir la note sur la notarisation ci-dessus)

### Option 3 : Compiler depuis les sources

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/dodoapps/dodopulse.git
   cd dodopulse
   ```

2. Compiler l'application :
   ```bash
   swiftc -O -o DodoPulse DodoPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Exécuter :
   ```bash
   ./DodoPulse
   ```

### Option 4 : Créer un bundle d'application (optionnel)

Si vous voulez que DodoPulse apparaisse comme une vraie application macOS :

1. Créer la structure de l'application :
   ```bash
   mkdir -p DodoPulse.app/Contents/MacOS
   cp DodoPulse DodoPulse.app/Contents/MacOS/
   ```

2. Créer `DodoPulse.app/Contents/Info.plist` :
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>CFBundleExecutable</key>
       <string>DodoPulse</string>
       <key>CFBundleIdentifier</key>
       <string>com.bluewave.dodopulse</string>
       <key>CFBundleName</key>
       <string>DodoPulse</string>
       <key>CFBundleVersion</key>
       <string>1.0</string>
       <key>LSMinimumSystemVersion</key>
       <string>12.0</string>
       <key>LSUIElement</key>
       <true/>
   </dict>
   </plist>
   ```

3. Déplacer vers Applications (optionnel) :
   ```bash
   mv DodoPulse.app /Applications/
   ```

### Option 5 : Exécuter avec Automator

Cette méthode permet à DodoPulse de fonctionner indépendamment du Terminal, donc il continue de fonctionner même après avoir fermé le Terminal.

1. Compilez d'abord DodoPulse (voir Option 1 ci-dessus)

2. Ouvrez **Automator** (recherchez-le dans Spotlight)

3. Cliquez sur **Nouveau document** et sélectionnez **Application**

4. Dans la barre de recherche, tapez "Exécuter un script shell" et faites-le glisser dans la zone de workflow

5. Remplacez le texte par défaut par le chemin complet vers votre binaire DodoPulse :
   ```bash
   /chemin/vers/dodopulse/DodoPulse
   ```
   Par exemple, si vous avez cloné dans votre dossier personnel :
   ```bash
   ~/dodopulse/DodoPulse
   ```

6. Allez dans **Fichier** > **Enregistrer** et enregistrez-le sous "DodoPulse" dans votre dossier Applications

7. Double-cliquez sur l'application Automator enregistrée pour exécuter DodoPulse

**Astuce :** Vous pouvez ajouter DodoPulse à vos Ouverture pour le démarrer automatiquement au démarrage :
1. Ouvrez **Réglages Système** > **Général** > **Ouverture**
2. Cliquez sur **+** et sélectionnez votre application Automator DodoPulse

## Utilisation

Une fois lancé, DodoPulse apparaît dans votre barre de menus affichant l'utilisation CPU et mémoire.

- **Clic gauche** sur l'élément de la barre de menus pour ouvrir le panneau détaillé
- **Clic droit** pour un menu rapide avec paramètres, sélection de langue et option Quitter
- **Cliquez** sur une carte pour ouvrir l'application système associée

### Changer de langue

1. Faites un clic droit sur l'icône DodoPulse dans la barre de menus
2. Sélectionnez **Langue** dans le menu
3. Choisissez votre langue préférée dans le sous-menu

## Détails techniques

DodoPulse utilise les APIs natives macOS pour des métriques précises :

- **CPU** : API Mach `host_processor_info()`
- **Mémoire** : API Mach `host_statistics64()`
- **GPU** : Service IOKit `IOAccelerator`
- **Réseau** : `getifaddrs()` pour les statistiques d'interface
- **Batterie** : `IOPSCopyPowerSourcesInfo()` depuis IOKit
- **Température/Ventilateurs** : SMC (System Management Controller) via IOKit

## Contribuer

Les contributions sont les bienvenues ! N'hésitez pas à soumettre une pull request.

### Ajouter des traductions

DodoPulse permet d'ajouter facilement de nouvelles langues. Pour ajouter une nouvelle langue :

1. Ajoutez un nouveau cas à l'enum `Language`
2. Ajoutez les traductions pour toutes les chaînes dans le struct `L10n`
3. Soumettez une pull request

## Licence

Licence MIT - voir [LICENSE](LICENSE) pour plus de détails.

## Support KDE Plasma

DodoPulse est également disponible en tant que **widget KDE Plasma** pour les utilisateurs Linux!

Offre les mêmes capacités de surveillance système avec de beaux graphiques sparkline:
- Surveillance CPU, Mémoire, GPU avec graphiques en temps réel
- Vitesses réseau avec totaux de session
- Utilisation disque avec détection des disques externes
- État de la batterie et informations système

**Installation:**
```bash
kpackagetool6 -t Plasma/Applet -i dodopulse.plasmoid
```

Pour plus de détails, voir [KDE/README.md](KDE/README.md)

## Remerciements

Développé avec Swift et AppKit pour des performances macOS natives.
