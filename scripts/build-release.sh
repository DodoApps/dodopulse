#!/bin/bash
set -e

# Configuration
APP_NAME="SystemPulse"
VERSION="${1:-1.0.0}"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"

echo "Building $APP_NAME version $VERSION..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create .app bundle structure
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile the Swift file
echo "Compiling..."
swiftc -O -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" SystemPulse.swift \
    -framework Cocoa -framework IOKit -framework Metal

# Create Info.plist
cat > "$APP_BUNDLE/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.bluewave-labs.systempulse</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025 Bluewave Labs. MIT License.</string>
</dict>
</plist>
EOF

# Copy icon if it exists
if [ -f "resources/AppIcon.icns" ]; then
    cp "resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
fi

echo "App bundle created at $APP_BUNDLE"

# Create DMG
echo "Creating DMG..."
rm -f "$BUILD_DIR/$DMG_NAME"

# Create a temporary directory for DMG contents
DMG_TEMP="$BUILD_DIR/dmg-temp"
mkdir -p "$DMG_TEMP"
cp -R "$APP_BUNDLE" "$DMG_TEMP/"

# Create symbolic link to Applications folder
ln -s /Applications "$DMG_TEMP/Applications"

# Create the DMG
hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_TEMP" -ov -format UDZO "$BUILD_DIR/$DMG_NAME"

# Clean up
rm -rf "$DMG_TEMP"

echo ""
echo "Build complete!"
echo "  App: $APP_BUNDLE"
echo "  DMG: $BUILD_DIR/$DMG_NAME"
echo ""

# Calculate SHA256 for Homebrew
SHA256=$(shasum -a 256 "$BUILD_DIR/$DMG_NAME" | awk '{print $1}')
echo "SHA256: $SHA256"
echo ""
echo "Use this SHA256 in the Homebrew Cask formula."
