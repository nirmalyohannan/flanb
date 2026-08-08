import 'dart:io';
import 'package:flanb/build/apk_locator.dart';
import 'package:flanb/build/build_config.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ApkLocator', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('flanb_apk_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('locates flavored release APK correctly', () {
      final apkDir = Directory(p.join(tempDir.path, 'build', 'app', 'outputs', 'flutter-apk'))
        ..createSync(recursive: true);

      File(p.join(apkDir.path, 'app-dev-release.apk')).writeAsStringSync('apk1');
      File(p.join(apkDir.path, 'app-staging-release.apk')).writeAsStringSync('apk2');

      final config = BuildConfig(
        flavor: 'staging',
        mode: BuildMode.release,
      );

      final located = ApkLocator.locate(tempDir.path, config);
      expect(located, isNotNull);
      expect(p.basename(located!.path), equals('app-staging-release.apk'));
    });
  });
}
