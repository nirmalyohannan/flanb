## 0.7.2

- Fixed critical issue where `stdin.readByteSync()` in post-build rebuild prompt blocked the Dart isolate thread event loop after build completion, causing local HTTP server requests (`/`, `/status`, `/download`) to freeze or fail to resolve.
- Converted post-build keypress listening (`Prompts.listenForRebuildAction()`) to a non-blocking asynchronous stream listener (`stdin.listen(...)`), ensuring the Shelf HTTP server remains 100% active and responsive while waiting for terminal rebuild shortcuts (`r`, `Ctrl+r`, `c`).
- Added CORS middleware (`Access-Control-Allow-Origin: *`) to `LanServer` handling `OPTIONS` preflight requests across LAN and Public Tunnels.
- Added automatic reconnect and history fallback error handlers to Web UI SSE EventSource (`connectSse()`).
- Synchronized `BuildStatus` updates (`building`, `success`, `failed`) during Native Android build execution.

## 0.7.1

- Updated Native Android Build Mode Selection (`Prompts.selectAndroidBuildMode()`). Restricted options to `Release` and `Debug` (removing `Profile` mode, which is exclusive to Flutter).
- Added fallback logic converting `--mode profile` to `Release` mode when passed via non-interactive CLI flags for Native Android builds.

## 0.7.0

- Added Native Android Project Build Support (`ProjectType.android`). FLANB now automatically detects Native Android projects (`gradlew` / `build.gradle` / `app/build.gradle[.kts]`) in addition to Flutter projects.
- Refactored project pipeline architecture into modular separation of concerns flow runners (`runFlutterFlow`, `runAndroidFlow`, `runFileShareFlow`), making FLANB extensible for future frameworks and build pipelines.
- Added Gradle process execution engine (`AndroidBuildManager`) executing `./gradlew assemble<Variant>` (e.g. `assembleRelease`, `assembleDevelopmentRelease`, `assembleDebug`).
- Added Native Android APK Locator (`AndroidApkLocator`) locating output `.apk` files under `app/build/outputs/apk/`.
- Added decorative CLI error banner when a directory is neither Flutter nor Native Android.

## 0.6.6

- Fixed bug where `FlanbRoutes` was instantiated before `primaryLanUrl` was set on `LanServer`, causing `GET /status` and `GET /qr` to fall back to `localhost`.
- Replaced static URL parameters in `FlanbRoutes` with dynamic getters (`getPrimaryLanUrl` and `getTunnelUrl`).
- Updated `LanServer.start()` to automatically resolve the primary Wi-Fi LAN IP address before initializing routes.
- Guaranteed Web View QR codes and pill badges always display the actual LAN IP (`http://<LAN_IP>:<PORT>/download`) so smartphones on the same Wi-Fi network can scan and connect seamlessly.

## 0.6.5

- Fixed Web view SVG QR Code URL resolution (`GET /qr`). When `tunnelUrl` is absent, the QR code now resolves to the actual primary LAN IP URL (`http://<LAN_IP>:<PORT>/download`) instead of `localhost`, ensuring mobile device cameras can scan and download files directly on local Wi-Fi networks.
- Added Server Mode pill badge (`📶 Local LAN Server` vs `🌐 Public Tunnel`) to the File Sharer Dashboard View card in the embedded Web UI, showing exact connection mode and server URL details directly on the web page.

## 0.6.4

- Fixed interactive terminal menu re-printing issue when pressing arrow keys (↑/↓).
- Implemented `\x1B[1G\x1B[0J` ANSI cursor movement and clear-down sequences, ensuring smooth in-place cursor updates.
- Added automatic terminal column width detection (`stdout.terminalColumns`) and line truncation to prevent line wrapping duplication on narrower terminal windows or long file paths.

## 0.6.3

- Added directory path validation for `--file`. If a directory path is passed (e.g. `flanb --file ./my_folder/`), FLANB prints `✗ Directory sharing is not supported as of now.` with an example usage hint and exits safely.
- Added interactive file selection prompt when `flanb --file` is run without specifying a file path.
- Added 25-file terminal threshold limit. If the current directory contains more than 25 files, FLANB outputs a clean error message (`✗ Too many files (X files found) to display in current directory.`) to prevent spamming the terminal prompt.

## 0.6.2

- Redesigned Web View for Custom File Sharing Mode (`flanb --file <PATH>`).
- Replaced Flutter console build log viewer with a dedicated, sleek **File Sharer Dashboard View**.
- Embedded direct download QR code directly on the file card page (eliminating popup modals for file sharing).
- Displayed prominent file icon, full filename, formatted file size badge (KB/MB/GB), and big glowing download button.

## 0.6.1

- Fixed `FormatException: Invalid HTTP header field value` when downloading files containing Unicode characters (e.g. non-breaking spaces `\u00A0`, special symbols, accents, or emojis) in their filename.
- Implemented RFC 6266 / RFC 5987 URI Percent Encoding (`filename*=UTF-8''...`) for HTTP `Content-Disposition` response headers, ensuring 100% specification compliance and full cross-browser Unicode support.

## 0.6.0

- Added Custom File Sharing Mode (`flanb --file <FILE_PATH>`).
- Bypasses Flutter project validation requirements when `--file` is passed, allowing developers to share any custom file (APKs, PDFs, ZIPs, images) over LAN and public HTTPS tunnels from any directory.
- Prompt for tunneling service when sharing custom files.
- Added custom file download streaming in `/download` endpoint with correct Content-Disposition attachment headers.
- Updated terminal output banner and QR code generation for custom file sharing.

## 0.5.1

- Added `--show-tunnels` CLI flag to inspect all supported tunneling services, their installation status (`INSTALLED` vs `NOT INSTALLED`), and installation commands on the host device.
- Added `installHint` metadata to `TunnelProvider`.
- Updated `README.md` documentation and CLI flags reference table.

## 0.5.0

- Added interactive terminal key listener allowing developers to instantly **Rebuild (`r` / `Ctrl+r`)** or **Change Config (`c`)** after a build completes or fails.
- Rebuilding with the same configuration keeps the existing HTTP server and Public Tunnel active without re-printing QR codes or server links.
- Choosing to change configuration cleanly stops active servers/tunnels and restarts the interactive setup flow.

## 0.4.1

- Increased default tunneling connection safety timeout from 7 seconds to **15 seconds** for slower network handshakes.
- Added detailed failure logging when a tunnel fails (e.g. process exit codes, stderr/stdout error messages, or timeout reasons).
- Improved CLI terminal output during tunnel fallback to display the exact failure cause.

## 0.4.0

- Added automatic system scanning for installed public tunneling services (`cloudflared`, `ngrok`, `lt` / Localtunnel, `ssh` / `localhost.run`).
- Added interactive terminal menu prompt for selecting a tunneling provider (default: `No Tunnel / Local LAN Server`).
- Added non-interactive `--tunnel` / `-u` CLI flag (e.g. `--tunnel cloudflared`, `--tunnel ngrok`).
- Added robust fail-safe engine with safety timeout. If a tunneling tool fails or times out, FLANB outputs a clear warning and seamlessly falls back to the default Local LAN Server without interrupting the build.
- Added public HTTPS URL & QR code terminal rendering for active tunnels.
- Added "Public Tunnel" pill badge and dual QR code support in Web View appbar.

## 0.3.1

- Replaced verbose terminal build log output with a clean, single-line animated spinner (`Building Flutter APK...`).
- Captured all Flutter/Gradle stdout & stderr streams for real-time Web Console streaming without bloating the terminal.
- Added terminal ANSI QR Code display for the direct APK download URL (`http://<LAN_IP>:<PORT>/download`) upon successful build completion.

## 0.3.0

- Added terminal ANSI QR Code rendering for the LAN URL so developers can scan their terminal screen directly with mobile cameras.
- Added a "📱 QR Code" button and modal popup in the Web Dashboard next to the Download APK button.
- Removed HTTP request logging middleware (`logRequests()`) to eliminate terminal bloat from web polling.
- Added clean build completion status banners (`✓ BUILD FINISHED CLEANLY` / `✗ BUILD FAILED`) in the terminal upon build completion.
- Added SVG QR Code generation endpoint (`GET /qr`).

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
