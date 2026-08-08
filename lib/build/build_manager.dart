import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'build_config.dart';

enum BuildStatus {
  idle,
  discovering,
  building,
  success,
  failed,
  serving,
  stopped,
}

class BuildManager {
  final String projectRoot;
  final BuildConfig config;

  BuildStatus status = BuildStatus.idle;
  int? exitCode;
  DateTime? startTime;
  DateTime? endTime;
  Process? _process;

  BuildManager({
    required this.projectRoot,
    required this.config,
  });

  /// Executes `flutter build apk` with the configured options.
  /// Logs are emitted line by line to [onLog].
  Future<bool> build({void Function(String line)? onLog}) async {
    status = BuildStatus.building;
    startTime = DateTime.now();

    final args = config.toFlutterArgs();
    final commandStr = 'flutter ${args.join(' ')}';
    onLog?.call('▶ Running command: $commandStr');
    onLog?.call('📁 Working directory: $projectRoot\n');

    try {
      _process = await Process.start(
        'flutter',
        args,
        workingDirectory: projectRoot,
        runInShell: Platform.isWindows,
      );

      final stdoutFuture = _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        onLog?.call(line);
      }).asFuture();

      final stderrFuture = _process!.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        onLog?.call('[ERR] $line');
      }).asFuture();

      await Future.wait([stdoutFuture, stderrFuture]);
      exitCode = await _process!.exitCode;
      endTime = DateTime.now();

      if (exitCode == 0) {
        status = BuildStatus.success;
        onLog?.call('\n✓ Build finished successfully (exit code 0)');
        return true;
      } else {
        status = BuildStatus.failed;
        onLog?.call('\n✗ Build failed with exit code $exitCode');
        return false;
      }
    } catch (e) {
      status = BuildStatus.failed;
      endTime = DateTime.now();
      onLog?.call('\n✗ Failed to execute flutter process: $e');
      return false;
    } finally {
      _process = null;
    }
  }

  void cancel() {
    _process?.kill();
    status = BuildStatus.stopped;
  }
}
