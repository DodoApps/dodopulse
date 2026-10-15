#!/bin/bash

# DodoPulse GNOME Shell Extension Uninstaller

UUID="dodopulse@dodoapps.com"

echo "🗑  Uninstalling DodoPulse GNOME extension..."

gnome-extensions disable "$UUID" 2>/dev/null || true

if [ "$1" == "--system" ]; then
    sudo rm -rf "/usr/share/gnome-shell/extensions/$UUID"
else
    rm -rf "$HOME/.local/share/gnome-shell/extensions/$UUID"
fi

echo "✅ DodoPulse removed. Log out and back in (Wayland) or restart GNOME Shell (X11) to finish."
