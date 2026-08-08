import 'dart:io';
import 'package:flanb/project/entrypoint_discovery.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('EntrypointDiscovery', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('flanb_entry_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('discovers lib/main.dart and custom entry points containing main()', () {
      final libDir = Directory(p.join(tempDir.path, 'lib'))..createSync(recursive: true);
      final flavorDir = Directory(p.join(libDir.path, 'flavors'))..createSync(recursive: true);

      File(p.join(libDir.path, 'main.dart')).writeAsStringSync('void main() {}');
      File(p.join(libDir.path, 'main_dev.dart')).writeAsStringSync('void main(List<String> args) {}');
      File(p.join(flavorDir.path, 'main_prod.dart')).writeAsStringSync('Future<void> main() async {}');
      File(p.join(libDir.path, 'helper.dart')).writeAsStringSync('class Helper {}');

      final entrypoints = EntrypointDiscovery.discover(tempDir.path);

      expect(entrypoints, contains('lib/main.dart'));
      expect(entrypoints, contains('lib/main_dev.dart'));
      expect(entrypoints, contains(p.join('lib', 'flavors', 'main_prod.dart')));
      expect(entrypoints, isNot(contains('lib/helper.dart')));
      expect(entrypoints.first, equals('lib/main.dart'));
    });
  });
}
