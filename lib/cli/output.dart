
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
    } else {
      print('  $yellow⚠ No active LAN network interface detected.$reset\n');
    }
    print('  $dim(Open the LAN URL on mobile devices connected to the same Wi-Fi)$reset');
    print('  ${dim}Press Ctrl+C to stop the server cleanly.$reset');
    print('');
  }
}
