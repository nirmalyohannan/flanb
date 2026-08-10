import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'tunnel_provider.dart';

class TunnelService {
  final TunnelProvider provider;
  Process? _process;
  String? _publicUrl;

  TunnelService(this.provider);

  String? get publicUrl => _publicUrl;

  /// Starts the selected tunnel provider for local port [port].
  /// Returns the public HTTPS URL if successful, or null on failure/timeout.
  Future<String?> start(int port) async {
    if (provider == TunnelProvider.none) return null;

    final completer = Completer<String?>();
    Timer? timeoutTimer;

    try {
      final List<String> args = _getCommandArgs(port);
      final executable = provider.executableName!;

      _process = await Process.start(
        executable,
        args,
        runInShell: Platform.isWindows,
      );

      // Safety timeout: fallback if tunnel doesn't yield URL within 7 seconds
      timeoutTimer = Timer(const Duration(seconds: 7), () {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      // Stream stdout and stderr to parse the public URL
      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        final url = extractUrlFromLine(provider, line);
        if (url != null && !completer.isCompleted) {
          completer.complete(url);
        }
      });

      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        final url = extractUrlFromLine(provider, line);
        if (url != null && !completer.isCompleted) {
          completer.complete(url);
        }
      });

      _process!.exitCode.then((code) {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      });

      _publicUrl = await completer.future;
      timeoutTimer.cancel();

      if (_publicUrl == null) {
        stop();
      }

      return _publicUrl;
    } catch (_) {
      timeoutTimer?.cancel();
      stop();
      return null;
    }
  }

  List<String> _getCommandArgs(int port) {
    switch (provider) {
      case TunnelProvider.cloudflared:
        return ['tunnel', '--url', 'http://localhost:$port'];
      case TunnelProvider.ngrok:
        return ['http', '$port'];
      case TunnelProvider.localtunnel:
        return ['--port', '$port'];
      case TunnelProvider.localhostRun:
        return [
          '-o',
          'StrictHostKeyChecking=no',
          '-R',
          '80:localhost:$port',
          'nokey@localhost.run',
        ];
      case TunnelProvider.none:
        return [];
    }
  }

  /// Extracts public HTTPS URL from a tunnel log line based on [provider].
  static String? extractUrlFromLine(TunnelProvider provider, String line) {
    switch (provider) {
      case TunnelProvider.cloudflared:
        final match = RegExp(r'https://[a-zA-Z0-9\-]+\.trycloudflare\.com').firstMatch(line);
        return match?.group(0);

      case TunnelProvider.ngrok:
        final match = RegExp(r'https://[a-zA-Z0-9\-]+\.(?:ngrok-free\.app|ngrok\.io|ngrok\.app)').firstMatch(line);
        return match?.group(0);

      case TunnelProvider.localtunnel:
        final match = RegExp(r'https://[a-zA-Z0-9\-]+\.loca\.lt').firstMatch(line);
        if (match != null) return match.group(0);
        final match2 = RegExp(r'your url is:\s*(https://[^\s]+)').firstMatch(line);
        return match2?.group(1);

      case TunnelProvider.localhostRun:
        final match = RegExp(r'https://[a-zA-Z0-9\-]+\.lhr\.life').firstMatch(line);
        return match?.group(0);

      case TunnelProvider.none:
        return null;
    }
  }

  /// Stops the active tunnel process.
  void stop() {
    _process?.kill();
    _process = null;
    _publicUrl = null;
  }
}
