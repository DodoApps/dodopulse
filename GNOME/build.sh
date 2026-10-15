#!/bin/bash

# DodoPulse GNOME Shell extension builder
#
# Builds both extension flavours from the shared sources in src/:
#   legacy - GNOME Shell 43, 44   (imports.* modules)
#   esm    - GNOME Shell 45+      (ES modules)
#
# Output:
#   build/<flavour>/dodopulse@dodoapps.com/   ready-to-install directories
#   dist/dodopulse@dodoapps.com.<flavour>.shell-extension.zip
#
# Usage: ./build.sh [legacy|esm|all]   (default: all)

set -e

UUID="dodopulse@dodoapps.com"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/src"
BUILD="$SCRIPT_DIR/build"
DIST="$SCRIPT_DIR/dist"

LEGACY_VERSIONS='["43", "44"]'
ESM_VERSIONS='["45", "46", "47", "48", "49", "50", "51"]'

build_flavour() {
    local flavour="$1" versions="$2"
    local out="$BUILD/$flavour/$UUID"

    rm -rf "$out"
    mkdir -p "$out/schemas"

    sed "s/@SHELL_VERSIONS@/$versions/" "$SRC/metadata.json.in" > "$out/metadata.json"
    cp "$SRC/stylesheet.css" "$out/"
    cp "$SRC/schemas/"*.gschema.xml "$out/schemas/"
    cp "$SRC/$flavour/extension.js" "$SRC/$flavour/prefs.js" "$out/"
    cp "$SRC/core.js" "$SRC/prefsCore.js" "$out/"

    if [ "$flavour" = "esm" ]; then
        printf '\nexport { DodoPulseExtension };\n' >> "$out/core.js"
        printf '\nexport { fillDodoPulsePreferences };\n' >> "$out/prefsCore.js"
    fi

    # GNOME 43/44 need compiled schemas inside the extension; 45+ compile them
    # on install, but shipping them is harmless and keeps manual installs working.
    glib-compile-schemas "$out/schemas/"

    mkdir -p "$DIST"
    rm -f "$DIST/$UUID.$flavour.shell-extension.zip"
    (cd "$out" && zip -qr "$DIST/$UUID.$flavour.shell-extension.zip" .)

    echo "✅ Built $flavour: $out"
}

if ! command -v glib-compile-schemas >/dev/null; then
    echo "❌ glib-compile-schemas not found (install libglib2.0-bin / glib2)." >&2
    exit 1
fi
if ! command -v zip >/dev/null; then
    echo "❌ zip not found." >&2
    exit 1
fi

case "${1:-all}" in
    legacy) build_flavour legacy "$LEGACY_VERSIONS" ;;
    esm)    build_flavour esm "$ESM_VERSIONS" ;;
    all)
        build_flavour legacy "$LEGACY_VERSIONS"
        build_flavour esm "$ESM_VERSIONS"
        ;;
    *)
        echo "Usage: $0 [legacy|esm|all]" >&2
        exit 1
        ;;
esac
