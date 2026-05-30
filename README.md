# Invertify 🎛️

A native, ultra-minimalist macOS utility app designed to invert image colors in style. Built using **SwiftUI**, **AppKit**, and **Core Image**.

It offers a gorgeous, glassmorphic dark HUD interface and two core operations:
1. **Drag-and-Drop Inverter**: Drag any image in, get its color-inverted version instantly, and drag it directly back out to Finder, Desktop, or other applications.
2. **Interactive Desktop X-Ray Lens**: When no image is loaded, the app serves as a real-time color-inverting lens. Drag the window around your screen to see a live "x-ray" of whatever is directly behind it!

---

## Features

- **Fluid Drag-and-Drop**: Drag image files (PNG, JPG, WEBP, etc.) from Finder into the app, and drag the inverted output straight out.
- **Live Desktop Preview**: Real-time color inversion of the screen pixels directly beneath the app window as you drag it.
- **Sleek HUD Aesthetics**: Modern glassmorphic background using macOS native materials (`.hudWindow`), glowing neon borders, and micro-animations.
- **Native & Lightweight**: Less than 1MB bundle size. Written in 100% native Swift with zero external dependencies.

---

## Requirements

- **Operating System**: macOS 12.0 (Monterey) or later.
- **Compilation**: Xcode Command Line Tools installed (pre-installed on most developer Macs, provides `swiftc` and `iconutil`).

---

## Quick Start & Compilation

You can compile the app bundle with a single command. Open Terminal, navigate to this directory, and run:

```bash
chmod +x build.sh
./build.sh
```

This will:
1. Create the native macOS application bundle structure `InvertImage.app`.
2. Generate a standard `Info.plist`.
3. Use the system `sips` and `iconutil` to resize the high-resolution app icon base into a native macOS `AppIcon.icns`.
4. Compile the Swift source code into an optimized binary.
5. Deploy `InvertImage.app` directly into your **Downloads** directory.

Double-click the generated `InvertImage.app` in your Downloads folder to run it.

---

## Permissions Notice

For the **Interactive Desktop X-Ray Lens** to work, macOS requires **Screen Recording** permissions to read the pixels behind the window.
- The app will automatically prompt you for permission when launched.
- If not granted, a clickable button inside the window will guide you to grant access in **System Settings -> Privacy & Security -> Screen Recording**.
- *Note: Invertify runs entirely locally. It does not record, save, or transmit any screen data.*

---

## Author & License

Developed as a minimalist utility helper. Released under the MIT License.
