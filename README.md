# SystemPulse

🌍 **Localized in 7 languages:** 🇺🇸 English | 🇹🇷 [Türkçe](README_TR.md) | 🇩🇪 [Deutsch](README_DE.md) | 🇫🇷 [Français](README_FR.md) | 🇪🇸 [Español](README_ES.md) | 🇯🇵 [日本語](README_JA.md) | 🇨🇳 [中文](README_ZH.md)

A lightweight, native macOS menu bar app that displays real-time system metrics with beautiful mini graphs.

<img width="397" height="715" alt="image" src="https://github.com/user-attachments/assets/6868a0ac-1d01-45aa-84d7-8d21dc0daa6b" />


![macOS](https://img.shields.io/badge/macOS-12.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **CPU monitoring** - Usage percentage, temperature, frequency (Intel), per-core tracking with history graph
- **Memory monitoring** - Used/free memory, active/wired/compressed breakdown
- **GPU monitoring** - Utilization percentage, temperature, display refresh rate (Hz)
- **Network monitoring** - Download/upload speeds, local & public IP, session totals
- **Disk monitoring** - Usage percentage, free space, SSD health (when available)
- **Battery monitoring** - Charge level, charging status, time remaining, power consumption
- **Fan monitoring** - RPM for each fan (when available)
- **System info** - Load average, process count, swap usage, kernel version, uptime, screen brightness
- **Multi-language support** - Choose your language from the menu (7 languages available)

### Interactive features

- **Click** any card to open the corresponding system app (Activity Monitor, Disk Utility, System Settings, etc.)
- **Right-click** the menu bar icon for a quick menu with settings and language selection

## Requirements

- macOS 12.0 (Monterey) or later
- Apple Silicon or Intel Mac

## Installation

> **About notarization:** SystemPulse is not currently notarized by Apple. Notarization is Apple's security process that scans apps for malware before distribution. Without it, macOS shows a warning on first launch. This is safe to bypass for open-source apps like SystemPulse where you can inspect the code yourself. Notarization is planned for a future release.

### Option 1: Homebrew (recommended)

```bash
brew tap bluewave-labs/systempulse
brew install --cask systempulse
```

On first launch, right-click the app → Open → confirm. Or run: `xattr -cr /Applications/SystemPulse.app`

### Option 2: Download DMG

1. Download the latest DMG from [Releases](https://github.com/bluewave-labs/systempulse/releases)
2. Open the DMG and drag SystemPulse to Applications
3. On first launch, right-click → Open → confirm (see note above about notarization)

### Option 3: Build from source

1. Clone the repository:
   ```bash
   git clone https://github.com/bluewave-labs/systempulse.git
   cd systempulse
   ```

2. Build the app:
   ```bash
   swiftc -O -o SystemPulse SystemPulse.swift -framework Cocoa -framework IOKit -framework Metal
   ```

3. Run:
   ```bash
   ./SystemPulse
   ```

### Option 4: Create an app bundle (optional)

If you want SystemPulse to appear as a proper macOS app:

1. Create the app structure:
   ```bash
   mkdir -p SystemPulse.app/Contents/MacOS
   cp SystemPulse SystemPulse.app/Contents/MacOS/
   ```

2. Create `SystemPulse.app/Contents/Info.plist`:
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
       <string>12.0</string>
       <key>LSUIElement</key>
       <true/>
   </dict>
   </plist>
   ```

3. Move to Applications (optional):
   ```bash
   mv SystemPulse.app /Applications/
   ```

### Option 5: Run with Automator

This method allows SystemPulse to run independently of Terminal, so it keeps running even after you close Terminal.

1. Build SystemPulse first (see Option 1 above)

2. Open **Automator** (search for it in Spotlight)

3. Click **New Document** and select **Application**

4. In the search bar, type "Run Shell Script" and drag it to the workflow area

5. Replace the default text with the full path to your SystemPulse binary:
   ```bash
   /path/to/systempulse/SystemPulse
   ```
   For example, if you cloned to your home folder:
   ```bash
   ~/systempulse/SystemPulse
   ```

6. Go to **File** > **Save** and save it as "SystemPulse" in your Applications folder

7. Double-click the saved Automator app to run SystemPulse

**Tip:** You can add SystemPulse to your Login Items to start automatically at boot:
1. Open **System Settings** > **General** > **Login Items**
2. Click **+** and select your SystemPulse Automator app

## Usage

Once running, SystemPulse appears in your menu bar showing CPU and memory usage.

- **Left-click** the menu bar item to open the detailed panel
- **Right-click** for a quick menu with settings, language selection, and quit option
- **Click** a card to open the related system app

### Changing language

1. Right-click the SystemPulse icon in the menu bar
2. Select **Language** from the menu
3. Choose your preferred language from the submenu

## Technical details

SystemPulse uses native macOS APIs for accurate metrics:

- **CPU**: `host_processor_info()` Mach API
- **Memory**: `host_statistics64()` Mach API
- **GPU**: IOKit `IOAccelerator` service
- **Network**: `getifaddrs()` for interface statistics
- **Battery**: `IOPSCopyPowerSourcesInfo()` from IOKit
- **Temperature/Fans**: SMC (System Management Controller) via IOKit

## Contributing

Contributions are welcome! Please feel free to submit a pull request.

### Adding translations

SystemPulse supports adding new languages easily. To add a new language:

1. Add a new case to the `Language` enum
2. Add translations for all strings in the `L10n` struct
3. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built with Swift and AppKit for native macOS performance.
