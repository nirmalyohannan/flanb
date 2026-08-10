import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../build/build_config.dart';

class AndroidBuildManager {
  final String projectRoot;
  final String? flavor;
  final BuildMode mode;

  Process? _process;

  AndroidBuildManager({
    required this.projectRoot,
    this.flavor,
    required this.mode,
  });

  /// Computes the Gradle assemble task name (e.g. assembleRelease, assembleDevelopmentRelease).
  String get taskName {
    final modeCapitalized = _capitalize(mode.name);
    if (flavor != null && flavor!.isNotEmpty) {
      final flavorCapitalized = _capitalize(flavor!);
      return 'assemble$flavorCapitalized$modeCapitalized';
    }
    return 'assemble$modeCapitalized';
  }

  /// Builds the Native Android project using gradlew (or system gradle).
  Future<bool> build({required void Function(String line) onLog}) async {
    final wrapper = Platform.isWindows ? 'gradlew.bat' : './gradlew';
    final wrapperFile = File(p.join(projectRoot, Platform.isWindows ? 'gradlew.bat' : 'gradlew'));

    String executable;
    List<String> args;

    if (wrapperFile.existsSync()) {
      executable = wrapper;
      args = [taskName];
    } else {
      executable = 'gradle';
      args = [taskName];
    }

    onLog('[INFO] Executing Gradle command: $executable ${args.join(' ')}');

    try {
      _process = await Process.start(
        executable,
        args,
        workingDirectory: projectRoot,
        runInShell: true,
      );

      _process!.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        onLog(line);
      });

      _process!.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        onLog('[ERR] $line');
      });

      final exitCode = await _process!.exitCode;
      _process = null;

      if (exitCode == 0) {
        onLog('[INFO] Gradle build finished cleanly (exit code 0).');
        return true;
      } else {
        onLog('[ERR] Gradle build failed with exit code $exitCode.');
        return false;
      }
    } catch (e) {
      onLog('[ERR] Exception occurred during Gradle build: $e');
      _process = null;
      return false;
    }
  }

  void cancel() {
    _process?.kill(ProcessSignal.sigkill);
    _process = null;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
