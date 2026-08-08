## 0.2.1

- Added native Web Notifications API integration on build **Success** (`✓ Build Successful`) or **Failure** (`✗ Build Failed`).
- Added interactive arrow key (**↑/↓**) menu selection with instant visual cursor (`❯`).
- Added Super Dark color scheme for the web dashboard.
- Added glowing blinking thick console cursor at the active log line end.
- Added project version extraction and display pill badge.
- Redesigned web UI with compact floating glassmorphic appbar and full-body 100vh console layout.
- Added author watermark (`Nirmal Yohannan`) in CLI banner and web header.
- Fixed SSE byte stream output and added REST log fallback API (`GET /api/logs`).

## 0.1.0

- Initial release of **FLANB (Flutter LAN Build)** CLI.
- Automatic Flutter project detection and pubspec validation.
- Android product flavor discovery for Groovy (`build.gradle`) and Kotlin DSL (`build.gradle.kts`).
- Dart entry point scanning (`lib/main*.dart`).
- Interactive terminal menus and CLI argument flags (`-f`, `-t`, `-m`, `-p`, `--no-browser`, `--non-interactive`).
- Embedded web dashboard with direct APK download stream.
- LAN IP resolution and port auto-binding.
