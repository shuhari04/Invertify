#!/bin/bash
set -e

APP_NAME="InvertImage"
APP_DIR="/Users/leitong/Downloads/${APP_NAME}.app"
SRC_DIR="/Users/leitong/Downloads/lev0/InvertApp"
ICON_BASE="/Users/leitong/.gemini/antigravity/brain/6c14b17c-ef91-49fb-90e7-c0afdf0c8344/app_icon_base_1780155371915.png"

echo "=== Creating App Bundle Directory ==="
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

echo "=== Generating Info.plist ==="
cat << 'EOF' > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>InvertImage</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.lev0.invertimage</string>
    <key>CFBundleName</key>
    <string>InvertImage</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "=== Creating App Icon ==="
ICONSET_DIR="/tmp/AppIcon.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

# Resize images using sips
echo "Resizing app icon with sips..."
sips -s format png -z 16 16     "$ICON_BASE" --out "$ICONSET_DIR/icon_16x16.png" > /dev/null
sips -s format png -z 32 32     "$ICON_BASE" --out "$ICONSET_DIR/icon_16x16@2x.png" > /dev/null
sips -s format png -z 32 32     "$ICON_BASE" --out "$ICONSET_DIR/icon_32x32.png" > /dev/null
sips -s format png -z 64 64     "$ICON_BASE" --out "$ICONSET_DIR/icon_32x32@2x.png" > /dev/null
sips -s format png -z 128 128   "$ICON_BASE" --out "$ICONSET_DIR/icon_128x128.png" > /dev/null
sips -s format png -z 256 256   "$ICON_BASE" --out "$ICONSET_DIR/icon_128x128@2x.png" > /dev/null
sips -s format png -z 256 256   "$ICON_BASE" --out "$ICONSET_DIR/icon_256x256.png" > /dev/null
sips -s format png -z 512 512   "$ICON_BASE" --out "$ICONSET_DIR/icon_256x256@2x.png" > /dev/null
sips -s format png -z 512 512   "$ICON_BASE" --out "$ICONSET_DIR/icon_512x512.png" > /dev/null
sips -s format png -z 1024 1024 "$ICON_BASE" --out "$ICONSET_DIR/icon_512x512@2x.png" > /dev/null

# Compile iconset to icns
echo "Compiling iconset with iconutil..."
iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET_DIR"

echo "=== Compiling Swift Application ==="
swiftc -parse-as-library -O -o "$APP_DIR/Contents/MacOS/InvertImage" "$SRC_DIR/main.swift"

echo "=== Build Complete ==="
echo "Successfully built InvertImage.app in: $APP_DIR"
