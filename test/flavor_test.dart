import 'dart:io';
import 'package:flanb/project/flavor_discovery.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FlavorDiscovery', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('flanb_flavor_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('parses Groovy productFlavors correctly', () {
      final appDir = Directory(p.join(tempDir.path, 'android', 'app'))..createSync(recursive: true);
      final gradleFile = File(p.join(appDir.path, 'build.gradle'));

      gradleFile.writeAsStringSync('''
android {
    compileSdkVersion 33
    flavorDimensions "environment"

    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
        }
        production {
            dimension "environment"
        }
    }
}
''');

      final flavors = FlavorDiscovery.discover(tempDir.path);
      expect(flavors, equals(['development', 'production', 'staging']));
    });

    test('parses Kotlin DSL create("flavor") productFlavors correctly', () {
      final appDir = Directory(p.join(tempDir.path, 'android', 'app'))..createSync(recursive: true);
      final ktsFile = File(p.join(appDir.path, 'build.gradle.kts'));

      ktsFile.writeAsStringSync('''
android {
    flavorDimensions += listOf("environment")

    productFlavors {
        create("development") {
            dimension = "environment"
        }
        create("staging") {
            dimension = "environment"
        }
        register("production") {
            dimension = "environment"
        }
    }
}
''');

      final flavors = FlavorDiscovery.discover(tempDir.path);
      expect(flavors, equals(['development', 'production', 'staging']));
    });

    test('returns empty list when no flavors exist', () {
      final appDir = Directory(p.join(tempDir.path, 'android', 'app'))..createSync(recursive: true);
      File(p.join(appDir.path, 'build.gradle')).writeAsStringSync('''
android {
    compileSdkVersion 33
}
''');

      final flavors = FlavorDiscovery.discover(tempDir.path);
      expect(flavors, isEmpty);
    });
  });
}
