#!/bin/bash

# DodoPulse GNOME Shell Extension Installer
# Detects the GNOME Shell version and installs the matching flavour
# (GNOME 43/44 → legacy, GNOME 45+ → ES modules).

set -e

UUID="dodopulse@dodoapps.com"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔══════════════════════════════════════════╗"
echo "║   DodoPulse GNOME Extension Installer    ║"
echo "╚══════════════════════════════════════════╝"
echo ""

if ! command -v gnome-shell >/dev/null; then
    echo "❌ gnome-shell not found. This extension requires GNOME Shell 43 or later."
    exit 1
fi

SHELL_VERSION="$(gnome-shell --version | grep -oE '[0-9]+' | head -1)"
if [ -z "$SHELL_VERSION" ] || [ "$SHELL_VERSION" -lt 43 ]; then
    echo "❌ GNOME Shell $SHELL_VERSION is not supported (43 or later required)."
    exit 1
fi

if [ "$SHELL_VERSION" -ge 45 ]; then
    FLAVOUR="esm"
else
    FLAVOUR="legacy"
fi
echo "🖥  GNOME Shell $SHELL_VERSION detected → $FLAVOUR build"

if [ "$1" == "--system" ]; then
    INSTALL_DIR="/usr/share/gnome-shell/extensions/$UUID"
    SUDO="sudo"
    echo "📦 Installing system-wide (requires sudo)..."
else
    INSTALL_DIR="$HOME/.local/share/gnome-shell/extensions/$UUID"
    SUDO=""
    echo "📦 Installing for current user..."
fi

"$SCRIPT_DIR/build.sh" "$FLAVOUR"

$SUDO rm -rf "$INSTALL_DIR"
$SUDO mkdir -p "$INSTALL_DIR"
$SUDO cp -r "$SCRIPT_DIR/build/$FLAVOUR/$UUID/." "$INSTALL_DIR/"
$SUDO chmod -R a+rX "$INSTALL_DIR"

echo ""
echo "✅ Installation complete!"
echo "📍 Installed to: $INSTALL_DIR"
echo ""

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "🔄 On Wayland, log out and log back in so GNOME Shell picks up the new extension."
else
    echo "🔄 On X11, press Alt+F2, type 'r' and press Enter to restart GNOME Shell."
fi
echo ""
echo "Then enable it with:"
echo "  gnome-extensions enable $UUID"
echo ""
echo "Open settings with:"
echo "  gnome-extensions prefs $UUID"
echo ""
