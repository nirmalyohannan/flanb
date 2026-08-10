import 'dart:io';
import 'tunnel_provider.dart';

class TunnelDiscovery {
  /// Discovers installed tunneling CLI binaries available in system PATH.
  /// Always includes [TunnelProvider.none].
  static Future<List<TunnelProvider>> discoverAvailable() async {
    final List<TunnelProvider> available = [TunnelProvider.none];

    final candidates = [
      TunnelProvider.cloudflared,
      TunnelProvider.ngrok,
      TunnelProvider.localtunnel,
      TunnelProvider.localhostRun,
    ];

    for (final provider in candidates) {
      if (provider.executableName != null) {
        final installed = await _isCommandInstalled(provider.executableName!);
        if (installed) {
          available.add(provider);
        }
      }
    }

    return available;
  }

  /// Checks if [command] exists in system PATH.
  static Future<bool> _isCommandInstalled(String command) async {
    try {
      final isWindows = Platform.isWindows;
      final checkCmd = isWindows ? 'where' : 'which';
      final result = await Process.run(checkCmd, [command]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
