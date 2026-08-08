import 'dart:io';

class BrowserLauncher {
  /// Attempts to open [url] in the system's default web browser.
  static Future<bool> openUrl(String url) async {
    try {
      if (Platform.isMacOS) {
        await Process.run('open', [url]);
        return true;
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', url]);
        return true;
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
