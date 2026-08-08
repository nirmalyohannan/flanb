import 'dart:io';
import 'package:path/path.dart' as p;

class EntrypointDiscovery {
  /// Discovers main*.dart entry point files in the project's `lib/` directory.
  /// Returns relative paths from project root, e.g. `lib/main.dart`, `lib/main_dev.dart`.
  static List<String> discover(String projectRoot) {
    final libDir = Directory(p.join(projectRoot, 'lib'));
    if (!libDir.existsSync()) return ['lib/main.dart'];

    final List<String> candidates = [];

    try {
      final files = libDir.listSync(recursive: true, followLinks: false);
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final filename = p.basename(entity.path);
          if (filename.startsWith('main')) {
            // Verify if it contains main(...) or void main(...)
            try {
              final content = entity.readAsStringSync();
              if (RegExp(r'\bvoid\s+main\b|\bmain\s*\(').hasMatch(content)) {
                final relativePath = p.relative(entity.path, from: projectRoot);
                candidates.add(relativePath);
              }
            } catch (_) {
              // Ignore unreadable files
            }
          }
        }
      }
    } catch (_) {
      // Fallback
    }

    if (candidates.isEmpty) {
      candidates.add('lib/main.dart');
    } else {
      // Put lib/main.dart first if it exists, otherwise sort alphabetically
      candidates.sort((a, b) {
        if (a == 'lib/main.dart') return -1;
        if (b == 'lib/main.dart') return 1;
        return a.compareTo(b);
      });
    }

    return candidates;
  }
}
