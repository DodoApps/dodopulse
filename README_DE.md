# SystemPulse

🌍 **In 7 Sprachen verfügbar:** 🇺🇸 [English](README.md) | 🇹🇷 [Türkçe](README_TR.md) | 🇩🇪 Deutsch | 🇫🇷 [Français](README_FR.md) | 🇪🇸 [Español](README_ES.md) | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 [中文](README_ZH.md)

Eine leichte, native macOS-Menüleisten-App, die Echtzeit-Systemmetriken mit schönen Mini-Grafiken anzeigt.

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />

![macOS](https://img.shields.io/badge/macOS-14.0%2B-blue)
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

## Anforderungen

- macOS 12.0 (Monterey) oder höher
- Apple Silicon oder Intel Mac

## Installation

> **Über Notarisierung:** SystemPulse ist derzeit nicht von Apple notarisiert. Notarisierung ist Apples Sicherheitsprozess, der Apps vor der Verteilung auf Malware überprüft. Ohne sie zeigt macOS beim ersten Start eine Warnung an. Bei Open-Source-Apps wie SystemPulse, wo Sie den Code selbst überprüfen können, ist es sicher, diese zu umgehen. Notarisierung ist für eine zukünftige Version geplant.

### Option 1: Homebrew (empfohlen)

```bash
brew tap bluewave-labs/systempulse
brew install --cask systempulse
```

Beim ersten Start: Rechtsklick auf die App → Öffnen → bestätigen. Oder ausführen: `xattr -cr /Applications/SystemPulse.app`

### Option 2: DMG herunterladen

1. Laden Sie die neueste DMG von [Releases](https://github.com/bluewave-labs/systempulse/releases) herunter
2. Öffnen Sie die DMG und ziehen Sie SystemPulse in Programme
3. Beim ersten Start: Rechtsklick → Öffnen → bestätigen (siehe Hinweis zur Notarisierung oben)

### Option 3: Aus Quellcode erstellen

1. Repository klonen:
   ```bash
   git clone https://github.com/bluewave-labs/systempulse.git
   cd systempulse
   ```

2. App erstellen:
   ```bash
   swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Ausführen:
   ```bash
   ./SystemPulse
   ```

### Option 4: App-Bundle erstellen (optional)

Wenn Sie möchten, dass SystemPulse als richtige macOS-App erscheint:

1. App-Struktur erstellen:
   ```bash
   mkdir -p SystemPulse.app/Contents/MacOS
   cp SystemPulse SystemPulse.app/Contents/MacOS/
   ```

2. `SystemPulse.app/Contents/Info.plist` erstellen:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>CFBundleExecutable</key>
       <string>SystemPulse</string>
       <key>CFBundleIdentifier</key>
       <string>com.bluewave.systempulse</string>
       <key>CFBundleName</key>
       <string>SystemPulse</string>
       <key>CFBundleVersion</key>
       <string>1.0</string>
       <key>LSMinimumSystemVersion</key>
       <string>14.0</string>
       <key>LSUIElement</key>
       <true/>
   </dict>
   </plist>
   ```

3. In Programme verschieben (optional):
   ```bash
   mv SystemPulse.app /Applications/
   ```

### Option 5: Mit Automator ausführen

Diese Methode ermöglicht es SystemPulse, unabhängig vom Terminal zu laufen, sodass es auch nach dem Schließen des Terminals weiterläuft.

1. Erstellen Sie zuerst SystemPulse (siehe Option 1 oben)

2. Öffnen Sie **Automator** (suchen Sie in Spotlight danach)

3. Klicken Sie auf **Neues Dokument** und wählen Sie **Programm**

4. Geben Sie in der Suchleiste "Shell-Skript ausführen" ein und ziehen Sie es in den Workflow-Bereich

5. Ersetzen Sie den Standardtext durch den vollständigen Pfad zu Ihrer SystemPulse-Binärdatei:
   ```bash
   /pfad/zu/systempulse/SystemPulse
   ```
   Wenn Sie beispielsweise in Ihren Home-Ordner geklont haben:
   ```bash
   ~/systempulse/SystemPulse
   ```

6. Gehen Sie zu **Ablage** > **Sichern** und speichern Sie es als "SystemPulse" in Ihrem Programme-Ordner

7. Doppelklicken Sie auf die gespeicherte Automator-App, um SystemPulse auszuführen

**Tipp:** Sie können SystemPulse zu Ihren Anmeldeobjekten hinzufügen, um es automatisch beim Hochfahren zu starten:
1. Öffnen Sie **Systemeinstellungen** > **Allgemein** > **Anmeldeobjekte**
2. Klicken Sie auf **+** und wählen Sie Ihre SystemPulse Automator-App

## Verwendung

Nach dem Start erscheint SystemPulse in Ihrer Menüleiste und zeigt CPU- und Speichernutzung an.

- **Linksklick** auf das Menüleistenelement, um das Detailfenster zu öffnen
- **Rechtsklick** für ein Schnellmenü mit Einstellungen, Sprachauswahl und Beenden-Option
- **Klicken** Sie auf eine Karte, um die zugehörige System-App zu öffnen

### Sprache ändern

1. Rechtsklicken Sie auf das SystemPulse-Symbol in der Menüleiste
2. Wählen Sie **Sprache** aus dem Menü
3. Wählen Sie Ihre bevorzugte Sprache aus dem Untermenü

## Technische Details

SystemPulse verwendet native macOS-APIs für genaue Metriken:

- **CPU**: `host_processor_info()` Mach API
- **Speicher**: `host_statistics64()` Mach API
- **GPU**: IOKit `IOAccelerator` Dienst
- **Netzwerk**: `getifaddrs()` für Schnittstellenstatistiken
- **Batterie**: `IOPSCopyPowerSourcesInfo()` von IOKit
- **Temperatur/Lüfter**: SMC (System Management Controller) über IOKit

## Mitwirken

Beiträge sind willkommen! Bitte zögern Sie nicht, einen Pull Request einzureichen.

### Übersetzungen hinzufügen

SystemPulse unterstützt das einfache Hinzufügen neuer Sprachen. Um eine neue Sprache hinzuzufügen:

1. Fügen Sie einen neuen Fall zum `Language` Enum hinzu
2. Fügen Sie Übersetzungen für alle Strings im `L10n` Struct hinzu
3. Reichen Sie einen Pull Request ein

## Lizenz

MIT-Lizenz - siehe [LICENSE](LICENSE) für Details.

## Danksagungen

Entwickelt mit Swift und AppKit für native macOS-Leistung.
