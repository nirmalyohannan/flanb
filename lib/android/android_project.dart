import 'dart:io';
import 'package:path/path.dart' as p;
import '../project/flavor_discovery.dart';

class AndroidProject {
  final String rootPath;
  final String name;

  AndroidProject({
    required this.rootPath,
    required this.name,
  });

  /// Factory constructor to validate and instantiate [AndroidProject].
  factory AndroidProject.fromDirectory([String? directoryPath]) {
    final rootPath = p.canonicalize(directoryPath ?? Directory.current.path);

    final appBuildGradle = File(p.join(rootPath, 'app', 'build.gradle'));
    final appBuildGradleKts = File(p.join(rootPath, 'app', 'build.gradle.kts'));

    if (!appBuildGradle.existsSync() && !appBuildGradleKts.existsSync()) {
      throw AndroidProjectValidationException(
        'Not a valid Native Android project. Missing app/build.gradle or app/build.gradle.kts',
      );
    }

    final name = _extractProjectName(rootPath);

    return AndroidProject(
      rootPath: rootPath,
      name: name,
    );
  }

  /// Discovers Android product flavors if any.
  List<String> get discoveredFlavors {
    return FlavorDiscovery.discover(rootPath);
  }

  /// Checks whether `./gradlew` (or `gradlew.bat` on Windows) exists.
  bool get hasWrapper {
    final wrapperScript = Platform.isWindows ? 'gradlew.bat' : 'gradlew';
    return File(p.join(rootPath, wrapperScript)).existsSync();
  }

  static String _extractProjectName(String rootPath) {
    final settingsGradle = File(p.join(rootPath, 'settings.gradle'));
    final settingsGradleKts = File(p.join(rootPath, 'settings.gradle.kts'));

    File? targetSettings;
    if (settingsGradleKts.existsSync()) {
      targetSettings = settingsGradleKts;
    } else if (settingsGradle.existsSync()) {
      targetSettings = settingsGradle;
    }

    if (targetSettings != null) {
      try {
        final content = targetSettings.readAsStringSync();
        final regex = RegExp(r'''rootProject\.name\s*=\s*["']([^"']+)["']''');
        final match = regex.firstMatch(content);
        if (match != null && match.group(1) != null) {
          return match.group(1)!.trim();
        }
      } catch (_) {}
    }

    return p.basename(rootPath);
  }
}

class AndroidProjectValidationException implements Exception {
  final String message;
  AndroidProjectValidationException(this.message);

  @override
  String toString() => message;
}
