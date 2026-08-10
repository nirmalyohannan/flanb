import '../server/qr_generator.dart';

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
    print('$cyan$bold│       Flutter LAN Build            │$reset');
    print('$cyan$bold│        by Nirmal Yohannan          │$reset');
    print('$cyan$bold╰────────────────────────────────────╯$reset');
    print('');
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

  static void printServerUrls({
    required int port,
    required List<String> lanIps,
  }) {
    print('');
    print('$cyan$bold╭──────────────────────────────────────────────────╮$reset');
    print('$cyan$bold│                 LAN SERVER ACTIVE                │$reset');
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

      final primaryUrl = 'http://${lanIps.first}:$port';
      final qrString = QrGenerator.renderTerminalQr(primaryUrl);
      if (qrString.isNotEmpty) {
        print('  $cyan${bold}Scan QR Code to open on mobile:$reset');
        print(qrString);
      }
    } else {
      print('  $yellow⚠ No active LAN network interface detected.$reset\n');
    }
    print('  $dim(Open the LAN URL on mobile devices connected to the same Wi-Fi)$reset');
    print('  ${dim}Press Ctrl+C to stop the server cleanly.$reset');
    print('');
  }

  static void printBuildCompletion({
    required bool success,
    String? apkPath,
    String? apkSizeMb,
    String? primaryLanUrl,
  }) {
    print('');
    if (success) {
      print('$green$bold╭──────────────────────────────────────────────────╮$reset');
      print('$green$bold│              ✓ BUILD FINISHED CLEANLY            │$reset');
      print('$green$bold╰──────────────────────────────────────────────────╯$reset');
      if (apkPath != null) {
        print('  APK:  $green$bold$apkPath$reset${apkSizeMb != null ? ' ($apkSizeMb MB)' : ''}');
      }
      if (primaryLanUrl != null) {
        print('  Share URL: $cyan$bold$primaryLanUrl$reset');
      }
    } else {
      print('$red$bold╭──────────────────────────────────────────────────╮$reset');
      print('$red$bold│                ✗ BUILD FAILED                    │$reset');
      print('$red$bold╰──────────────────────────────────────────────────╯$reset');
      print('  Check the logs above or in the Web UI for error details.');
    }
    print('\n${CliOutput.dim}Server is active. Press Ctrl+C to stop.${CliOutput.reset}\n');
  }
}
