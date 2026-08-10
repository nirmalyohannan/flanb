import 'dart:io';

enum ProjectType {
  flutter,
  android,
  customFile,
}

class ProjectDetector {
  /// Detects the project type for the given directory path.
  /// First checks if it is a valid Flutter project.
  /// If not, checks if it is a valid Native Android project.
  /// Returns null if neither is detected.
  static ProjectType? detect([String? directoryPath]) {
    final path = directoryPath ?? Directory.current.path;

    if (isFlutterProject(path)) {
      return ProjectType.flutter;
    }

    if (isAndroidProject(path)) {
      return ProjectType.android;
    }

    return null;
  }

  /// Checks if directory is a valid Flutter project.
  static bool isFlutterProject(String directoryPath) {
    final pubspecFile = File('$directoryPath/pubspec.yaml');
    if (!pubspecFile.existsSync()) return false;

    try {
      final content = pubspecFile.readAsStringSync();
      return content.contains('sdk: flutter') ||
          content.contains('flutter:') ||
          (content.contains('dependencies:') && content.contains('flutter:'));
    } catch (_) {
      return false;
    }
  }

  /// Checks if directory is a valid Native Android project.
  static bool isAndroidProject(String directoryPath) {
    final hasAppDir = Directory('$directoryPath/app').existsSync();
    final hasBuildGradle = File('$directoryPath/build.gradle').existsSync() ||
        File('$directoryPath/build.gradle.kts').existsSync() ||
        File('$directoryPath/settings.gradle').existsSync() ||
        File('$directoryPath/settings.gradle.kts').existsSync();
    final hasAppBuildGradle = File('$directoryPath/app/build.gradle').existsSync() ||
        File('$directoryPath/app/build.gradle.kts').existsSync();

    final isNotFlutter = !isFlutterProject(directoryPath);

    return isNotFlutter && (hasAppDir || hasBuildGradle) && hasAppBuildGradle;
  }
}
