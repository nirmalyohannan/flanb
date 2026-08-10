# FLANB — Flutter LAN Build

[![pub package](https://img.shields.io/pub/v/flanb.svg)](https://pub.dev/packages/flanb)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**FLANB** (*Flutter LAN Build*) is a developer-focused cross-platform CLI tool that simplifies building Flutter Android APKs and instantly serving them over your local network (LAN).

With FLANB, you can select flavors, entry points, and build modes directly from your terminal, execute the Flutter build, stream live logs to a web dashboard, and download the resulting APK directly onto test devices on your Wi-Fi network — without cloud services, USB cables, or third-party hosting.

---

## ⚡ Features

- **Zero Configuration Setup**: Run `flanb` from any Flutter project root directory.
- **Flavor Discovery**: Automatically detects Android product flavors from Groovy (`build.gradle`) and Kotlin DSL (`build.gradle.kts`).
- **Entry Point Scanning**: Discovers `main*.dart` candidate entry points in your `lib/` directory.
- **Build Mode Selection**: Easily switch between `Release`, `Debug`, and `Profile` modes.
- **Live SSE Log Streaming**: Stream live Flutter build logs to your terminal and to a browser web dashboard in real time.
- **Embedded Web Dashboard**: A built-in dark-mode web dashboard featuring build status, metadata, live console logs, and a one-click APK download button.
- **LAN Distribution**: Automatically binds to your local network IP (e.g. `http://192.168.1.15:8080`), making APK installation effortless for QA teams and test devices.
- **Cross-Platform**: Runs on macOS, Linux, and Windows.

---

## 🚀 Installation

Install FLANB globally using Dart:

```bash
dart pub global activate flanb
```

Make sure your Dart global binaries directory is added to your system `PATH`.

---

## 📖 User Manual & Usage

### 1. Interactive Mode (Default)

Navigate to the root directory of any Flutter project and run:

```bash
cd my_flutter_project
flanb
```

FLANB will guide you through an interactive menu:

```text
╭────────────────────────────────────╮
│              FLANB                 │
│       Flutter LAN Build            │
╰────────────────────────────────────╯

✓ Flutter project detected: my_flutter_project

ℹ Discovered Android flavors: development, staging, production

? Select Android Flavor:
  [1] No flavor (default)
  [2] development (default)
  [3] production
  [4] staging

? Select Dart Entry Point:
  [1] lib/main.dart (default)
  [2] lib/main_dev.dart
  [3] lib/main_staging.dart

? Select Build Mode:
  [1] Release (optimised for deployment) (default)
  [2] Debug (faster build, larger binary)
  [3] Profile (for performance testing)
```

After selection, FLANB will start a local LAN server, open the web dashboard, and begin building the APK.

---

### 2. Command Line Flags (Non-Interactive / Scripting)

You can pass command-line arguments to skip prompts or automate builds:

```bash
# Build staging flavor in release mode using main_staging.dart
flanb --flavor staging --target lib/main_staging.dart --mode release

# Use short aliases
flanb -f staging -t lib/main_staging.dart -m release -p 8080

# Share any custom file (APKs, PDFs, ZIPs) over LAN and Public Tunnel
flanb --file ./my_app_build.apk

# Non-interactive build (uses defaults for omitted options)
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
| `--tunnel` | `-u` | Public HTTP tunnel service (`cloudflared`, `ngrok`, `lt`, `ssh`) | `none` |
| `--show-tunnels` | | List supported tunnels & their installation status | |
| `--no-browser` | | Do not open the browser automatically | `false` |
| `--non-interactive` | | Skip all terminal prompts | `false` |
| `--help` | `-h` | Display usage information | |
| `--version` | `-v` | Display FLANB version | |

---

## 📱 Web Dashboard & Local Network Share

When FLANB starts, it launches an embedded HTTP server and prints the accessible local and LAN URLs:

```text
╭──────────────────────────────────────────────────╮
│                 LAN SERVER ACTIVE                │
╰──────────────────────────────────────────────────╯

  Local:
    http://localhost:8080

  Network (LAN):
    http://192.168.1.15:8080

  (Open the LAN URL on mobile devices connected to the same Wi-Fi)
```

1. Open the LAN URL (`http://192.168.1.15:8080`) on any smartphone or tablet connected to the same Wi-Fi network.
2. Watch live build progress and output in the embedded web log viewer.
3. Once the build completes successfully, tap **Download APK** to download and install the build directly onto the device.

---

## 🛠 Supported Flavor Configurations

FLANB parses product flavors automatically from both Groovy and Kotlin DSL Gradle files.

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
    }
}
```

---

## 📄 License

FLANB is released under the [MIT License](LICENSE).
