import 'dart:io';
import 'package:flanb/build/build_config.dart';
import 'package:flanb/build/build_manager.dart';
import 'package:test/test.dart';

void main() {
  group('Clean Build Unit Tests', () {
    test('BuildManager.performCleanBuild handles lockfile deletion and logging', () async {
      final tempDir = Directory.systemTemp.createTempSync('clean_test_');
      try {
        final lockFile = File('${tempDir.path}/pubspec.lock');
        lockFile.writeAsStringSync('# Test pubspec.lock');

        expect(lockFile.existsSync(), isTrue);

        final manager = BuildManager(
          projectRoot: tempDir.path,
          config: BuildConfig(entryPoint: 'lib/main.dart', mode: BuildMode.release),
        );

        final logs = <String>[];
        // Running on tempDir (no flutter project), commands will log warnings/errors cleanly
        await manager.performCleanBuild(onLog: (line) {
          logs.add(line);
        });

        expect(lockFile.existsSync(), isFalse, reason: 'pubspec.lock should be deleted by clean build');
        expect(logs.any((l) => l.contains('Deleting pubspec.lock')), isTrue);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
