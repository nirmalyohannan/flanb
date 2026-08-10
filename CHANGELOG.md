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
