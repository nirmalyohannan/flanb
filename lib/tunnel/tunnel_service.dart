import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'tunnel_provider.dart';

class TunnelService {
  final TunnelProvider provider;
  final Duration timeoutDuration;
  Process? _process;
  String? _publicUrl;
  String? _failureReason;

  TunnelService(
    this.provider, {
    this.timeoutDuration = const Duration(seconds: 15),
  });

  String? get publicUrl => _publicUrl;
  String? get failureReason => _failureReason;

  /// Starts the selected tunnel provider for local port [port].
  /// Returns the public HTTPS URL if successful, or null on failure/timeout.
  Future<String?> start(int port) async {
    if (provider == TunnelProvider.none) return null;

    final completer = Completer<String?>();
    Timer? timeoutTimer;
    String lastOutputLine = '';

    try {
      final List<String> args = _getCommandArgs(port);
      final executable = provider.executableName!;

      _process = await Process.start(
        executable,
        args,
        runInShell: Platform.isWindows,
      );

      // Safety timeout: fallback if tunnel doesn't yield URL within timeout duration (default 15s)
      timeoutTimer = Timer(timeoutDuration, () {
        if (!completer.isCompleted) {
          _failureReason = 'Connection timed out after ${timeoutDuration.inSeconds} seconds.';
          completer.complete(null);
        }
      });

      // Stream stdout to parse public URL and capture error context
      _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.trim().isNotEmpty) {
          lastOutputLine = line.trim();
        }
        final url = extractUrlFromLine(provider, line);
        if (url != null && !completer.isCompleted) {
          completer.complete(url);
        }
      });

      // Stream stderr to parse public URL and capture error context
      _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.trim().isNotEmpty) {
          lastOutputLine = line.trim();
        }
        final url = extractUrlFromLine(provider, line);
        if (url != null && !completer.isCompleted) {
          completer.complete(url);
        }
      });

      _process!.exitCode.then((code) {
        if (!completer.isCompleted) {
          if (code != 0) {
            _failureReason = 'Process exited with code $code${lastOutputLine.isNotEmpty ? ': "$lastOutputLine"' : ''}';
          } else {
            _failureReason = 'Process exited unexpectedly before producing a tunnel URL.';
          }
          completer.complete(null);
        }
      });

      _publicUrl = await completer.future;
      timeoutTimer.cancel();

      if (_publicUrl == null) {
        stop();
      }

      return _publicUrl;
    } catch (e) {
      timeoutTimer?.cancel();
      _failureReason = 'Command failed to start: ${e.toString()}';
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
