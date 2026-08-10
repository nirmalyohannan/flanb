import '../server/qr_generator.dart';
import '../tunnel/tunnel_provider.dart';

class CliOutput {
  // ANSI Color escape codes
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';
  static const String cyan = '\x1B[36m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String red = '\x1B[31m';
  static const String blue = '\x1B[34m';

  static void printBanner() {
    print('');
    print('$cyan$bold╭────────────────────────────────────╮$reset');
    print('$cyan$bold│              FLANB                 │$reset');
    print('$cyan$bold│   Flutter & Android LAN Build      │$reset');
    print('$cyan$bold│        by Nirmal Yohannan          │$reset');
    print('$cyan$bold╰────────────────────────────────────╯$reset');
    print('');
  }

  static void printFileSharerBanner(String fileName, String fileSizeMb) {
    print('');
    print('$cyan$bold╭────────────────────────────────────╮$reset');
    print('$cyan$bold│         FLANB FILE SHARER          │$reset');
    print('$cyan$bold│        by Nirmal Yohannan          │$reset');
    print('$cyan$bold╰────────────────────────────────────╯$reset');
    print('');
    print('  Sharing File: $green$bold$fileName$reset ($fileSizeMb MB)\n');
  }

  static void printSuccess(String message) {
    print('$green✓ $message$reset');
  }

  static void printError(String message) {
    print('$red✗ $message$reset');
  }

  static void printWarning(String message) {
    print('$yellow⚠ $message$reset');
  }

  static void printInfo(String message) {
    print('$cyanℹ $message$reset');
  }

  static void printInvalidProjectError() {
    print('');
    print('$red$bold╭──────────────────────────────────────────────────╮$reset');
    print('$red$bold│ ✗ INVALID PROJECT DIRECTORY                      │$reset');
    print('$red$bold╰──────────────────────────────────────────────────╯$reset');
    print('');
    print('  The current directory is not a recognized project type:');
    print('    • $bold${cyan}Flutter$reset  (missing pubspec.yaml with flutter dependency)');
    print('    • $bold${green}Android$reset  (missing gradlew or app/build.gradle[.kts])');
    print('');
    print('  ${dim}Use flanb --file <PATH> to share custom files, or run flanb --help for details.$reset');
    print('');
  }

  static void printServerUrls({
    required int port,
    required List<String> lanIps,
    String? tunnelUrl,
  }) {
    print('');
    print('$cyan$bold╭──────────────────────────────────────────────────╮$reset');
    print('$cyan$bold│                 SERVER IS ACTIVE                 │$reset');
    print('$cyan$bold╰──────────────────────────────────────────────────╯$reset');
    print('');
    print('  Local:');
    print('    $green${bold}http://localhost:$port$reset');
    print('');
    if (lanIps.isNotEmpty) {
      print('  Network (LAN):');
      for (final ip in lanIps) {
        print('    $green${bold}http://$ip:$port$reset');
      }
      print('');
    } else {
      print('  $yellow⚠ No active LAN network interface detected.$reset\n');
    }

    if (tunnelUrl != null && tunnelUrl.isNotEmpty) {
      print('  Public Tunnel:');
      print('    $green$bold$tunnelUrl$reset');
      print('');
      final qrString = QrGenerator.renderTerminalQr(tunnelUrl);
      if (qrString.isNotEmpty) {
        print('  $cyan${bold}Scan QR Code to open Public Tunnel on mobile:$reset');
        print(qrString);
      }
    } else if (lanIps.isNotEmpty) {
      final primaryUrl = 'http://${lanIps.first}:$port';
      final qrString = QrGenerator.renderTerminalQr(primaryUrl);
      if (qrString.isNotEmpty) {
        print('  $cyan${bold}Scan QR Code to open Web Dashboard on mobile:$reset');
        print(qrString);
      }
    }

    print('  $dim(Open URL on mobile devices connected to same Wi-Fi or via Public Tunnel)$reset');
    print('');
  }

  static void printBuildCompletion({
    required bool success,
    String? apkPath,
    String? apkSizeMb,
    String? primaryLanUrl,
    String? tunnelUrl,
    bool showQr = true,
  }) {
    print('');
    if (success) {
      print('$green$bold╭──────────────────────────────────────────────────╮$reset');
      print('$green$bold│              ✓ BUILD FINISHED CLEANLY            │$reset');
      print('$green$bold╰──────────────────────────────────────────────────╯$reset');
      if (apkPath != null) {
        print('  APK:  $green$bold$apkPath$reset${apkSizeMb != null ? ' ($apkSizeMb MB)' : ''}');
      }
      if (showQr) {
        if (tunnelUrl != null && tunnelUrl.isNotEmpty) {
          final tunnelDownload = '$tunnelUrl/download';
          print('  Public Download URL: $cyan$bold$tunnelDownload$reset');
          print('');
          final downloadQr = QrGenerator.renderTerminalQr(tunnelDownload);
          if (downloadQr.isNotEmpty) {
            print('  $green${bold}Scan QR Code to download APK via Public Tunnel:$reset');
            print(downloadQr);
          }
        } else if (primaryLanUrl != null) {
          final downloadUrl = '$primaryLanUrl/download';
          print('  Direct Download URL: $cyan$bold$downloadUrl$reset');
          print('');
          final downloadQr = QrGenerator.renderTerminalQr(downloadUrl);
          if (downloadQr.isNotEmpty) {
            print('  $green${bold}Scan QR Code to download APK directly onto your device:$reset');
            print(downloadQr);
          }
        }
      }
    } else {
      print('$red$bold╭──────────────────────────────────────────────────╮$reset');
      print('$red$bold│                ✗ BUILD FAILED                    │$reset');
      print('$red$bold╰──────────────────────────────────────────────────╯$reset');
      print('  Check the logs in the Web UI for error details.');
    }
    print('');
  }

  static void printRebuildPrompt() {
    print('${CliOutput.cyan}${CliOutput.bold}Actions:${CliOutput.reset} '
        'Press ${CliOutput.green}${CliOutput.bold}[r]${CliOutput.reset} to Rebuild (same config) │ '
        '${CliOutput.yellow}${CliOutput.bold}[c]${CliOutput.reset} to Change config / Restart │ '
        '${CliOutput.dim}[Ctrl+C] to Exit${CliOutput.reset}');
  }

  static void printSupportedTunnels(List<TunnelProvider> installedTunnels) {
    final allSupported = [
      TunnelProvider.cloudflared,
      TunnelProvider.ngrok,
      TunnelProvider.localtunnel,
      TunnelProvider.localhostRun,
    ];

    print('');
    print('$cyan$bold╭──────────────────────────────────────────────────╮$reset');
    print('$cyan$bold│             SUPPORTED TUNNEL SERVICES            │$reset');
    print('$cyan$bold╰──────────────────────────────────────────────────╯$reset');
    print('');

    for (final provider in allSupported) {
      final isInstalled = installedTunnels.contains(provider);
      final statusBadge = isInstalled
          ? '$green$bold[ INSTALLED ]$reset'
          : '$yellow$bold[ NOT INSTALLED ]$reset';
      final nameStr = provider.displayName.padRight(32);
      final hintStr = provider.installHint ?? '';

      print('  $nameStr $statusBadge  $dim$hintStr$reset');
    }

    print('');
    print('  ${dim}To run FLANB with a specific tunnel:$reset');
    print('    $green${bold}flanb --tunnel cloudflared$reset');
    print('    $green${bold}flanb -u ngrok$reset');
    print('');
  }
}
