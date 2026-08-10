# FLANB — Flutter LAN Build & File Sharer

[![pub package](https://img.shields.io/pub/v/flanb.svg)](https://pub.dev/packages/flanb)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Nirmal%20Yohannan-purple.svg)](https://github.com/nirmalyohannan)

**FLANB** (*Flutter LAN Build & File Sharer*) is a developer-focused cross-platform CLI tool designed to build Flutter Android APKs and instantly share them—or any custom file—over your local Wi-Fi network (LAN) and public HTTPS tunnels.

With FLANB, you can select flavors, entry points, build modes, and tunneling providers directly from your terminal. Scan QR codes straight from your terminal screen or web browser to download builds and custom files directly onto test devices—without USB cables, cloud uploads, or manual distribution steps.

---

## ⚡ Key Features

- 🎯 **Automatic Flavor & Entry Point Discovery**: Scans Gradle files (`build.gradle` / `build.gradle.kts`) for Android product flavors and `lib/` for `main*.dart` entry points.
- 🌐 **Public HTTPS Tunnel Integration**: Tunnel local HTTP servers using `cloudflared`, `ngrok`, `localtunnel` (`lt`), or `localhost.run` (`ssh`), with automatic fail-safe fallback to Local LAN Server.
- 📱 **Terminal ANSI & Web SVG QR Codes**: Generates UTF-8 block QR codes directly in your terminal and vector SVG QR codes in the web dashboard for instant mobile camera downloads.
- 📦 **Custom File Sharing Mode (`flanb --file`)**: Share any custom file (APKs, PDFs, ZIPs, videos, images) from any directory on your computer over Wi-Fi and HTTPS tunnels.
- 🔄 **Interactive Rebuild Shortcuts**: Press **`r` / `Ctrl+r`** to instantly rebuild with the same configuration (keeping active servers and tunnels alive) or **`c`** to change configuration.
- 🔍 **Supported Tunnels Inspector (`flanb --show-tunnels`)**: Inspect installed tunneling binaries on your machine and display one-click package manager install hints (`brew`, `npm`).
- 🔔 **Native Web Notifications & Live SSE Console**: Real-time log streaming over Server-Sent Events (SSE) with a Super Dark web dashboard and native browser notification alerts on build completion/failure.
- 🔤 **Unicode & RFC 5987 Compliant Streaming**: RFC 6266 / RFC 5987 URI percent-encoding for file download headers, supporting filenames with special symbols, spaces, or non-ASCII characters.

---

## 🚀 Installation

Install FLANB globally using the Dart SDK:

```bash
dart pub global activate flanb
```

Ensure your Dart global binaries directory is added to your system `PATH`:
- **macOS/Linux**: `~/.pub-cache/bin`
- **Windows**: `%LOCALAPPDATA%\Pub\Cache\bin`

---

## 📖 User Manual & Usage

### 1. Interactive Flutter Build Engine (Default)

Navigate to the root directory of any Flutter project and run:

```bash
cd my_flutter_project
flanb
```

FLANB will detect your Flutter project, discover flavors and entry points, and guide you through an interactive arrow-key selection menu:

```text
╭────────────────────────────────────╮
│              FLANB                 │
│       Flutter LAN Build            │
│        by Nirmal Yohannan          │
╰────────────────────────────────────╯

✓ Flutter project detected: my_flutter_project

ℹ Discovered Android flavors: development, staging, production

? Select Android Flavor: (Use ↑/↓ arrows, Enter to confirm)
  ❯ development
    production
    staging
    No flavor (default)

? Select Dart Entry Point:
  ❯ lib/main.dart
    lib/main_dev.dart
    lib/main_staging.dart

? Select Build Mode:
  ❯ Release (optimised for deployment)
    Debug (faster build, larger binary)
    Profile (for performance testing)

? Select Public Tunnel Service:
  ❯ No Tunnel (Local LAN Server only)
    Cloudflare Tunnel (cloudflared)
    ngrok Tunnel (ngrok)
    Localtunnel (lt)
    SSH Tunnel (localhost.run)
```

After selection, FLANB launches an embedded HTTP server, starts the build with a single-line animated spinner (`Building Flutter APK...`), and streams real-time logs to the Web UI.

---

### 2. Custom File Sharing Mode (`flanb --file`)

Share any file (APKs, ZIPs, PDFs, videos, images) from any directory on your computer over Wi-Fi and public HTTPS tunnels:

```bash
# Share a specific file by path
flanb --file ./my_app_build.apk
flanb --file ~/Desktop/presentation.pdf

# Run without a path to pick from non-hidden files in the current directory
flanb --file
```

When run without a path argument, FLANB lists files in the current directory for selection. If the directory contains more than 25 files, FLANB outputs a clean message asking for an explicit file path to keep terminal views uncluttered.

---

### 3. Inspect Supported Tunnel Services (`flanb --show-tunnels`)

Check which tunneling services are installed on your system:

```bash
flanb --show-tunnels
```

Output:

```text
╭──────────────────────────────────────────────────╮
│             SUPPORTED TUNNEL SERVICES            │
╰──────────────────────────────────────────────────╯

  Cloudflare Tunnel (cloudflared)  [ NOT INSTALLED ]  brew install cloudflared
  ngrok Tunnel (ngrok)             [ INSTALLED ]      brew install ngrok
  Localtunnel (lt)                 [ INSTALLED ]      npm install -g localtunnel
  SSH Tunnel (localhost.run)       [ INSTALLED ]      Pre-installed (ssh)

  To run FLANB with a specific tunnel:
    flanb --tunnel cloudflared
    flanb -u ngrok
```

---

### 4. Non-Interactive / Scripting Flags

Pass command-line arguments to skip prompts or automate builds in CI/CD pipelines:

```bash
# Build staging flavor in release mode using main_staging.dart with ngrok tunnel
flanb --flavor staging --target lib/main_staging.dart --mode release --tunnel ngrok

# Short aliases
flanb -f staging -t lib/main_staging.dart -m release -u cloudflared -p 8080

# Non-interactive mode (uses defaults for omitted options)
flanb --non-interactive --no-browser
```

#### Available Flags

| Flag | Short | Description | Default |
| --- | --- | --- | --- |
| `--file` | | Share any custom file over LAN & Public Tunnel | `null` |
| `--flavor` | `-f` | Android product flavor (e.g., `staging`, `prod`) | `null` (no flavor) |
| `--target` | `-t` | Main Dart entry point (e.g., `lib/main_dev.dart`) | `lib/main.dart` |
| `--mode` | `-m` | Build mode (`release`, `debug`, `profile`) | `release` |
| `--port` | `-p` | Local HTTP server port | `8080` |
| `--tunnel` | `-u` | Public HTTP tunnel (`cloudflared`, `ngrok`, `lt`, `ssh`, `none`) | `none` |
| `--show-tunnels` | | List supported tunneling tools & installation status | |
| `--no-browser` | | Do not open the browser automatically | `false` |
| `--non-interactive` | | Skip all terminal prompts (runs with defaults) | `false` |
| `--help` | `-h` | Display usage information | |
| `--version` | `-v` | Display FLANB version | |

---

## 📱 Embedded Web Dashboard

When FLANB starts, it launches an embedded Shelf HTTP server and prints accessible URLs alongside terminal ANSI QR codes:

```text
╭──────────────────────────────────────────────────╮
│                 SERVER IS ACTIVE                 │
╰──────────────────────────────────────────────────╯

  Local:
    http://localhost:8080

  Network (LAN):
    http://172.30.223.106:8080

  Scan QR Code to open Web Dashboard on mobile:
  [ ANSI QR CODE ]
```

### Web Views

1. **Flutter Build Mode**:
   - Super Dark color scheme with a live 100vh console viewer and blinking block cursor.
   - Real-time build log streaming via Server-Sent Events (`/logs`).
   - Native Web Notification prompts on build completion or failure.
   - Download banner with single-tap QR code popup and APK download stream (`/download`).

2. **Custom File Sharer View**:
   - Dedicated File Sharer card displaying file icon (`📦`), filename, formatted size badge, and a prominent **Download File** button.
   - Embedded SVG QR Code (`/qr`) resolving directly to the primary Wi-Fi LAN IP or HTTPS Public Tunnel URL for instant smartphone camera downloads.
   - Connection Mode Pill Badge (`📶 Local LAN Server` / `🌐 Public Tunnel`).

---

## 🛠 Supported Flavor Configurations

FLANB automatically parses product flavors from both Groovy and Kotlin DSL Gradle build scripts.

### Groovy (`android/app/build.gradle`)
```groovy
android {
    flavorDimensions "environment"

    productFlavors {
        development {
            dimension "environment"
        }
        staging {
            dimension "environment"
        }
        production {
            dimension "environment"
        }
    }
}
```

### Kotlin DSL (`android/app/build.gradle.kts`)
```kotlin
android {
    flavorDimensions += listOf("environment")

    productFlavors {
        create("development") {
            dimension = "environment"
        }
        create("staging") {
            dimension = "environment"
        }
        create("production") {
            dimension = "environment"
        }
    }
}
```

---

## 📄 License & Credits

FLANB is created by **Nirmal Yohannan** and released under the [MIT License](LICENSE).
