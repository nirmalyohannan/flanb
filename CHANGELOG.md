## 0.1.0

- Initial release of **FLANB (Flutter LAN Build)** CLI.
- Automatic Flutter project detection and pubspec validation.
- Android product flavor discovery for Groovy (`build.gradle`) and Kotlin DSL (`build.gradle.kts`).
- Dart entry point scanning (`lib/main*.dart`).
- Interactive terminal menus for flavor, target, build mode, and port selection.
- CLI argument parsing for non-interactive scripting.
- Live Server-Sent Events (SSE) log streaming to terminal and browser web console.
- Embedded dark-mode web dashboard with real-time build status and direct APK download stream.
- LAN IP resolution and port auto-binding.
