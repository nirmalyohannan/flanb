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

  /// Executes clean build commands before building:
  /// 1. `flutter pub cache clean --force`
  /// 2. `flutter clean`
  /// 3. Deletes `pubspec.lock`
  /// 4. `flutter pub get`
  Future<bool> performCleanBuild({void Function(String line)? onLog}) async {
    onLog?.call('🧹 Starting Clean Build Sequence...');

    // 1. flutter pub cache clean --force
    onLog?.call('▶ Executing: flutter pub cache clean --force');
    final res1 = await _runCommand('flutter', ['pub', 'cache', 'clean', '--force'], onLog: onLog);
    if (!res1) onLog?.call('⚠ pub cache clean warning (continuing clean sequence)');

    // 2. flutter clean
    onLog?.call('▶ Executing: flutter clean');
    final res2 = await _runCommand('flutter', ['clean'], onLog: onLog);
    if (!res2) onLog?.call('⚠ flutter clean warning (continuing clean sequence)');

    // 3. Remove pubspec.lock
    final lockFile = File('$projectRoot/pubspec.lock');
    if (lockFile.existsSync()) {
      onLog?.call('▶ Deleting pubspec.lock...');
      try {
        lockFile.deleteSync();
        onLog?.call('✓ Deleted pubspec.lock');
      } catch (e) {
        onLog?.call('⚠ Could not delete pubspec.lock: $e');
      }
    } else {
      onLog?.call('ℹ pubspec.lock does not exist (skipping deletion)');
    }

    // 4. flutter pub get
    onLog?.call('▶ Executing: flutter pub get');
    final res4 = await _runCommand('flutter', ['pub', 'get'], onLog: onLog);
    if (!res4) {
      onLog?.call('✗ flutter pub get failed');
      return false;
    }

    onLog?.call('✓ Clean build sequence finished successfully.\n');
    return true;
  }

  Future<bool> _runCommand(
    String executable,
    List<String> arguments, {
    void Function(String line)? onLog,
  }) async {
    try {
      final proc = await Process.start(
        executable,
        arguments,
        workingDirectory: projectRoot,
        runInShell: Platform.isWindows,
      );

      final stdoutFuture = proc.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        onLog?.call(line);
      }).asFuture();

      final stderrFuture = proc.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        onLog?.call('[ERR] $line');
      }).asFuture();

      await Future.wait([stdoutFuture, stderrFuture]);
      final code = await proc.exitCode;
      return code == 0;
    } catch (e) {
      onLog?.call('[ERR] Exception running $executable ${arguments.join(' ')}: $e');
      return false;
    }
  }

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
