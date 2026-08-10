# FLANB — Flutter & Native Android LAN Build

[![pub package](https://img.shields.io/pub/v/flanb.svg)](https://pub.dev/packages/flanb)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Author](https://img.shields.io/badge/Author-Nirmal%20Yohannan-purple.svg)](https://github.com/nirmalyohannan)

**FLANB** (*Flutter & Android LAN Build*) is a developer-focused cross-platform CLI tool designed to build **Flutter** and **Native Android** projects and instantly serve them—or any custom file—over your local Wi-Fi network (LAN) and public HTTPS tunnels.

With FLANB, you can automatically detect project types, select flavors, entry points, build modes, and tunneling providers directly from your terminal. Scan QR codes straight from your terminal screen or web browser to download APK builds and custom files directly onto test devices—without USB cables, cloud uploads, or manual distribution steps.

---

## ⚡ Key Features

- 🎯 **Automatic Multi-Framework Project Detection**: Scans the current directory to automatically detect **Flutter** (`pubspec.yaml` with `flutter` dependency) or **Native Android** (`gradlew` / `build.gradle[.kts]`) projects.
- 🏗 **Native Android & Flutter Build Engine**: Executes `flutter build apk` or `./gradlew assemble<Variant>` (`assembleRelease`, `assembleDevelopmentDebug`, etc.) with single-line animated progress spinners.
- 🎨 **Android Flavor Discovery**: Automatically detects product flavors from Groovy (`build.gradle`) and Kotlin DSL (`build.gradle.kts`) build scripts for both Flutter and Native Android projects.
- 🌐 **Public HTTPS Tunnel Integration**: Tunnel local HTTP servers using `cloudflared`, `ngrok`, `localtunnel` (`lt`), or `localhost.run` (`ssh`), with automatic fail-safe fallback to Local LAN Server.
- 📱 **Terminal ANSI & Web SVG QR Codes**: Generates UTF-8 block QR codes directly in your terminal and vector SVG QR codes in the web dashboard resolving to your primary Wi-Fi IP for instant mobile downloads.
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

### 1. Interactive Build Engine (Default)

Navigate to the root directory of any **Flutter** or **Native Android** project and run:

```bash
cd my_project
flanb
```

FLANB automatically detects the project type and guides you through an interactive arrow-key selection menu:

#### Flutter Project Output:
```text
╭────────────────────────────────────╮
│              FLANB                 │
│   Flutter & Android LAN Build      │
│        by Nirmal Yohannan          │
╰────────────────────────────────────╯

✓ Flutter project detected: my_flutter_app

ℹ Discovered Android flavors: development, staging, production

? Select Android Flavor: (Use ↑/↓ arrows, Enter to confirm)
  ❯ development
    production
    staging
    No flavor (default)
```

#### Native Android Project Output:
```text
╭────────────────────────────────────╮
│              FLANB                 │
│   Flutter & Android LAN Build      │
│        by Nirmal Yohannan          │
╰────────────────────────────────────╯

✓ Native Android project detected: Chorand App

Build Configuration (Native Android):
  Project:    Chorand App
  Flavor:     default (none)
  Mode:       release
  Tunnel:     No Tunnel (Local LAN Server only)
```

---

### 2. Decorative Invalid Directory Error

If `flanb` is executed inside a directory that is neither a Flutter nor Native Android project, FLANB displays a decorative error box:

```text
╭──────────────────────────────────────────────────╮
│ ✗ INVALID PROJECT DIRECTORY                      │
╰──────────────────────────────────────────────────╯

  The current directory is not a recognized project type:
    • Flutter  (missing pubspec.yaml with flutter dependency)
    • Android  (missing gradlew or app/build.gradle[.kts])

  Use flanb --file <PATH> to share custom files, or run flanb --help for details.
```

---

### 3. Custom File Sharing Mode (`flanb --file`)

Share any file (APKs, ZIPs, PDFs, videos, images) from any directory on your computer over Wi-Fi and public HTTPS tunnels:

```bash
# Share a specific file by path
flanb --file ./my_app_build.apk
flanb --file ~/Desktop/presentation.pdf

# Run without a path to pick from non-hidden files in current directory
flanb --file
```

---

### 4. Inspect Supported Tunnel Services (`flanb --show-tunnels`)

Check which tunneling services are installed on your system:

```bash
flanb --show-tunnels
```

---

### 5. Non-Interactive / Scripting Flags

Pass command-line arguments to skip prompts or automate builds in CI/CD pipelines:

```bash
# Build staging flavor in release mode with cloudflared tunnel
flanb --flavor staging --mode release --tunnel cloudflared

# Short aliases
flanb -f staging -m release -u ngrok -p 8080

# Non-interactive mode (uses defaults for omitted options)
flanb --non-interactive --no-browser
```

#### Available Flags

| Flag | Short | Description | Default |
| --- | --- | --- | --- |
| `--file` | | Share any custom file over LAN & Public Tunnel | `null` |
| `--flavor` | `-f` | Product flavor (e.g., `staging`, `dev`, `prod`) | `null` (no flavor) |
| `--target` | `-t` | Main Dart entry point for Flutter (e.g., `lib/main_dev.dart`) | `lib/main.dart` |
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

---

## 🛠 Supported Flavor Configurations

FLANB automatically parses product flavors from both Groovy and Kotlin DSL Gradle build scripts.

### Groovy (`android/app/build.gradle` or root `build.gradle`)
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

### Kotlin DSL (`android/app/build.gradle.kts` or `build.gradle.kts`)
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
