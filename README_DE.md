# DodoPulse

🌍 **In 7 Sprachen verfügbar:** 🇺🇸 [English](README.md) | 🇹🇷 [Türkçe](README_TR.md) | 🇩🇪 Deutsch | 🇫🇷 [Français](README_FR.md) | 🇪🇸 [Español](README_ES.md) | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 [中文](README_ZH.md)

Eine leichte, native macOS-Menüleisten-App, die Echtzeit-Systemmetriken mit schönen Mini-Grafiken anzeigt.

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![Lizenz](https://img.shields.io/badge/Lizenz-MIT-green)

## Funktionen

- **CPU-Überwachung** - Auslastung in Prozent, Temperatur, Frequenz (Intel), Verfolgung pro Kern mit Verlaufsgrafik
- **Speicherüberwachung** - Belegter/freier Speicher, aktiv/wired/komprimiert Aufschlüsselung
- **GPU-Überwachung** - Auslastung in Prozent, Temperatur, Bildschirm-Aktualisierungsrate (Hz)
- **Netzwerküberwachung** - Download-/Upload-Geschwindigkeiten, lokale und öffentliche IP, Sitzungssummen
- **Festplattenüberwachung** - Auslastung in Prozent, freier Speicherplatz, SSD-Zustand (wenn verfügbar)
- **Batterieüberwachung** - Ladestand, Ladestatus, verbleibende Zeit, Stromverbrauch
- **Lüfterüberwachung** - Drehzahl für jeden Lüfter (wenn verfügbar)
- **Systeminfo** - Lastdurchschnitt, Prozessanzahl, Swap-Nutzung, Kernel-Version, Betriebszeit, Bildschirmhelligkeit
- **Mehrsprachige Unterstützung** - Wählen Sie Ihre Sprache aus dem Menü (7 Sprachen verfügbar)

### Interaktive Funktionen

- **Klicken** Sie auf eine Karte, um die entsprechende System-App zu öffnen (Aktivitätsanzeige, Festplattendienstprogramm, Systemeinstellungen usw.)
- **Rechtsklicken** Sie auf das Menüleistensymbol für ein Schnellmenü mit Einstellungen und Sprachauswahl

## Vergleich mit kostenpflichtigen Alternativen

| Funktion | DodoPulse | iStat Menus | TG Pro | Sensei |
|----------|-----------|-------------|--------|--------|
| **Preis** | Kostenlos | ~$14 | $10 | $29 |
| **CPU-Überwachung** | ✅ | ✅ | ✅ | ✅ |
| **GPU-Überwachung** | ✅ | ✅ | ✅ | ✅ |
| **Speicherüberwachung** | ✅ | ✅ | ❌ | ✅ |
| **Netzwerküberwachung** | ✅ Multi-Interface | ✅ Pro App | ❌ | ❌ |
| **Festplattenüberwachung** | ✅ | ✅ | ✅ | ✅ |
| **Batterieüberwachung** | ✅ | ✅ + Bluetooth | ✅ | ✅ |
| **Lüftersteuerung** | ❌ | ✅ | ✅ | ✅ |
| **Wetter** | ❌ | ✅ | ❌ | ❌ |
| **Optimierungstools** | ❌ | ❌ | ❌ | ✅ |
| **Open Source** | ✅ | ❌ | ❌ | ❌ |
| **Einzelne Datei** | ✅ (~2000 Zeilen) | ❌ | ❌ | ❌ |

**Warum DodoPulse?** Kostenlos, Open Source, leichtgewichtig (~1-2% CPU), datenschutzorientiert (keine Analytik) und einfach zu prüfen/modifizieren.

## Anforderungen

- macOS 12.0 (Monterey) oder höher
- Apple Silicon oder Intel Mac

## Installation

> **Über Notarisierung:** DodoPulse ist derzeit nicht von Apple notarisiert. Notarisierung ist Apples Sicherheitsprozess, der Apps vor der Verteilung auf Malware überprüft. Ohne sie kann macOS Warnungen wie "App ist beschädigt" oder "kann nicht geöffnet werden" anzeigen. Bei Open-Source-Apps wie DodoPulse, wo Sie den Code selbst überprüfen können, ist es sicher, diese zu umgehen. **Lösung:** Führen Sie `xattr -cr /Applications/DodoPulse.app` im Terminal aus, dann öffnen Sie die App. Notarisierung ist für eine zukünftige Version geplant.

### Option 1: Homebrew (empfohlen)

```bash
brew tap dodoapps/tap
brew install --cask dodopulse
```

Beim ersten Start: Rechtsklick auf die App → Öffnen → bestätigen. Oder ausführen: `xattr -cr /Applications/DodoPulse.app`

### Option 2: DMG herunterladen

1. Laden Sie die neueste DMG von [Releases](https://github.com/dodoapps/dodopulse/releases) herunter
2. Öffnen Sie die DMG und ziehen Sie DodoPulse in Programme
3. Beim ersten Start: Rechtsklick → Öffnen → bestätigen (siehe Hinweis zur Notarisierung oben)

### Option 3: Aus Quellcode erstellen

1. Repository klonen:
   ```bash
   git clone https://github.com/dodoapps/dodopulse.git
   cd dodopulse
   ```

2. App erstellen:
   ```bash
   swiftc -O -o DodoPulse DodoPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Ausführen:
   ```bash
   ./DodoPulse
   ```

### Option 4: App-Bundle erstellen (optional)

Wenn Sie möchten, dass DodoPulse als richtige macOS-App erscheint:

1. App-Struktur erstellen:
   ```bash
   mkdir -p DodoPulse.app/Contents/MacOS
   cp DodoPulse DodoPulse.app/Contents/MacOS/
   ```

2. `DodoPulse.app/Contents/Info.plist` erstellen:
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

3. In Programme verschieben (optional):
   ```bash
   mv DodoPulse.app /Applications/
   ```

### Option 5: Mit Automator ausführen

Diese Methode ermöglicht es DodoPulse, unabhängig vom Terminal zu laufen, sodass es auch nach dem Schließen des Terminals weiterläuft.

1. Erstellen Sie zuerst DodoPulse (siehe Option 1 oben)

2. Öffnen Sie **Automator** (suchen Sie in Spotlight danach)

3. Klicken Sie auf **Neues Dokument** und wählen Sie **Programm**

4. Geben Sie in der Suchleiste "Shell-Skript ausführen" ein und ziehen Sie es in den Workflow-Bereich

5. Ersetzen Sie den Standardtext durch den vollständigen Pfad zu Ihrer DodoPulse-Binärdatei:
   ```bash
   /pfad/zu/dodopulse/DodoPulse
   ```
   Wenn Sie beispielsweise in Ihren Home-Ordner geklont haben:
   ```bash
   ~/dodopulse/DodoPulse
   ```

6. Gehen Sie zu **Ablage** > **Sichern** und speichern Sie es als "DodoPulse" in Ihrem Programme-Ordner

7. Doppelklicken Sie auf die gespeicherte Automator-App, um DodoPulse auszuführen

**Tipp:** Sie können DodoPulse zu Ihren Anmeldeobjekten hinzufügen, um es automatisch beim Hochfahren zu starten:
1. Öffnen Sie **Systemeinstellungen** > **Allgemein** > **Anmeldeobjekte**
2. Klicken Sie auf **+** und wählen Sie Ihre DodoPulse Automator-App

## Verwendung

Nach dem Start erscheint DodoPulse in Ihrer Menüleiste und zeigt CPU- und Speichernutzung an.

- **Linksklick** auf das Menüleistenelement, um das Detailfenster zu öffnen
- **Rechtsklick** für ein Schnellmenü mit Einstellungen, Sprachauswahl und Beenden-Option
- **Klicken** Sie auf eine Karte, um die zugehörige System-App zu öffnen

### Sprache ändern

1. Rechtsklicken Sie auf das DodoPulse-Symbol in der Menüleiste
2. Wählen Sie **Sprache** aus dem Menü
3. Wählen Sie Ihre bevorzugte Sprache aus dem Untermenü

## Technische Details

DodoPulse verwendet native macOS-APIs für genaue Metriken:

- **CPU**: `host_processor_info()` Mach API
- **Speicher**: `host_statistics64()` Mach API
- **GPU**: IOKit `IOAccelerator` Dienst
- **Netzwerk**: `getifaddrs()` für Schnittstellenstatistiken
- **Batterie**: `IOPSCopyPowerSourcesInfo()` von IOKit
- **Temperatur/Lüfter**: SMC (System Management Controller) über IOKit

## Mitwirken

Beiträge sind willkommen! Bitte zögern Sie nicht, einen Pull Request einzureichen.

### Übersetzungen hinzufügen

DodoPulse unterstützt das einfache Hinzufügen neuer Sprachen. Um eine neue Sprache hinzuzufügen:

1. Fügen Sie einen neuen Fall zum `Language` Enum hinzu
2. Fügen Sie Übersetzungen für alle Strings im `L10n` Struct hinzu
3. Reichen Sie einen Pull Request ein

## Lizenz

MIT-Lizenz - siehe [LICENSE](LICENSE) für Details.

## KDE Plasma Unterstützung

DodoPulse ist auch als **KDE Plasma Widget** für Linux-Benutzer verfügbar!

Bietet die gleichen Systemüberwachungsfunktionen mit schönen Sparkline-Grafiken:
- CPU, Speicher, GPU-Überwachung mit Echtzeit-Grafiken
- Netzwerkgeschwindigkeiten mit Sitzungssummen
- Festplattennutzung mit externer Laufwerkserkennung
- Batteriestatus und Systeminfo

**Installation:**
```bash
kpackagetool6 -t Plasma/Applet -i dodopulse.plasmoid
```

Weitere Details unter [KDE/README.md](KDE/README.md)

## Danksagungen

Entwickelt mit Swift und AppKit für native macOS-Leistung.
