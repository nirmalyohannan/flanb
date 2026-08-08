import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class FlutterProjectValidationException implements Exception {
  final String message;
  FlutterProjectValidationException(this.message);

  @override
  String toString() => message;
}

class FlutterProject {
  final String rootPath;
  final String name;
  final String version;

  FlutterProject._({
    required this.rootPath,
    required this.name,
    required this.version,
  });

  /// Validates and returns a [FlutterProject] instance for the given directory.
  /// Throws [FlutterProjectValidationException] if validation fails.
  static FlutterProject fromDirectory([String? path]) {
    final rootDir = Directory(path ?? Directory.current.path).absolute;
    if (!rootDir.existsSync()) {
      throw FlutterProjectValidationException(
        'Directory does not exist: ${rootDir.path}',
      );
    }

    final rootPath = rootDir.path;
    final pubspecFile = File(p.join(rootPath, 'pubspec.yaml'));
    final libDir = Directory(p.join(rootPath, 'lib'));
    final androidDir = Directory(p.join(rootPath, 'android'));

    if (!pubspecFile.existsSync()) {
      throw FlutterProjectValidationException(
        'pubspec.yaml not found in ${rootDir.path}',
      );
    }

    if (!libDir.existsSync()) {
      throw FlutterProjectValidationException(
        'lib/ directory not found in ${rootDir.path}',
      );
    }

    if (!androidDir.existsSync()) {
      throw FlutterProjectValidationException(
        'android/ directory not found in ${rootDir.path}',
      );
    }

    try {
      final content = pubspecFile.readAsStringSync();
      final yaml = loadYaml(content);

      if (yaml is! YamlMap) {
        throw FlutterProjectValidationException(
          'pubspec.yaml is invalid or empty.',
        );
      }

      final projectName = yaml['name']?.toString() ?? p.basename(rootPath);
      final projectVersion = yaml['version']?.toString() ?? '1.0.0';
      final dependencies = yaml['dependencies'];

      bool hasFlutterDependency = false;
      if (dependencies is YamlMap) {
        if (dependencies.containsKey('flutter')) {
          hasFlutterDependency = true;
        }
      }

      if (!hasFlutterDependency) {
        throw FlutterProjectValidationException(
          'pubspec.yaml does not contain a flutter dependency.',
        );
      }

      return FlutterProject._(
        rootPath: rootPath,
        name: projectName,
        version: projectVersion,
      );
    } catch (e) {
      if (e is FlutterProjectValidationException) rethrow;
      throw FlutterProjectValidationException(
        'Failed to parse pubspec.yaml: $e',
      );
    }
  }

  String get pubspecPath => p.join(rootPath, 'pubspec.yaml');
  String get libPath => p.join(rootPath, 'lib');
  String get androidPath => p.join(rootPath, 'android');
  String get buildPath => p.join(rootPath, 'build');
}
