import 'dart:io';
import 'package:flanb/android/android_project.dart';
import 'package:flanb/project/project_type.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectDetector & AndroidProject Tests', () {
    test('ProjectDetector correctly detects Native Android project', () {
      final sampleAndroidPath = '/Users/apple/Documents/Work/Projects/AndroidNativeProjects/ChorandApp';
      final type = ProjectDetector.detect(sampleAndroidPath);
      expect(type, equals(ProjectType.android));
    });

    test('AndroidProject.fromDirectory parses project name correctly', () {
      final sampleAndroidPath = '/Users/apple/Documents/Work/Projects/AndroidNativeProjects/ChorandApp';
      final project = AndroidProject.fromDirectory(sampleAndroidPath);
      expect(project.name, equals('Chorand App'));
      expect(project.hasWrapper, isTrue);
    });

    test('ProjectDetector returns null for invalid directory', () {
      final tempDir = Directory.systemTemp.createTempSync('invalid_proj_');
      try {
        final type = ProjectDetector.detect(tempDir.path);
        expect(type, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
