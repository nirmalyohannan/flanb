import 'dart:io';
import 'package:flanb/project/flutter_project.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FlutterProject Validation', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('flanb_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('throws FlutterProjectValidationException when directory is empty', () {
      expect(
        () => FlutterProject.fromDirectory(tempDir.path),
        throwsA(isA<FlutterProjectValidationException>()),
      );
    });

    test('throws FlutterProjectValidationException when pubspec lacks flutter dependency', () {
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('name: my_app\n');
      Directory(p.join(tempDir.path, 'lib')).createSync();
      Directory(p.join(tempDir.path, 'android')).createSync();

      expect(
        () => FlutterProject.fromDirectory(tempDir.path),
        throwsA(isA<FlutterProjectValidationException>()),
      );
    });

    test('validates successfully when valid Flutter project files exist', () {
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: sample_flutter
dependencies:
  flutter:
    sdk: flutter
''');
      Directory(p.join(tempDir.path, 'lib')).createSync();
      Directory(p.join(tempDir.path, 'android')).createSync();

      final project = FlutterProject.fromDirectory(tempDir.path);
      expect(project.name, equals('sample_flutter'));
      expect(project.rootPath, equals(tempDir.path));
    });
  });
}
