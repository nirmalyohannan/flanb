import 'dart:io';
import 'package:path/path.dart' as p;
import '../build/build_config.dart';

class AndroidApkLocator {
  /// Locates the generated APK file for a Native Android project.
  /// Checks `app/build/outputs/apk/` recursively for the most recently modified `.apk` file.
  static File? locate(
    String projectRoot, {
    String? flavor,
    required BuildMode mode,
    DateTime? buildStartTime,
  }) {
    final apkDir = Directory(p.join(projectRoot, 'app', 'build', 'outputs', 'apk'));
    if (!apkDir.existsSync()) {
      return null;
    }

    final List<File> candidateApks = [];

    try {
      final entities = apkDir.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.apk')) {
          candidateApks.add(entity);
        }
      }
    } catch (_) {
      return null;
    }

    if (candidateApks.isEmpty) {
      return null;
    }

    // Filter by build start time if provided
    List<File> validApks = candidateApks;
    if (buildStartTime != null) {
      final startTimeThreshold = buildStartTime.subtract(const Duration(seconds: 10));
      validApks = candidateApks.where((file) {
        try {
          return file.lastModifiedSync().isAfter(startTimeThreshold);
        } catch (_) {
          return true;
        }
      }).toList();
    }

    if (validApks.isEmpty) {
      validApks = candidateApks;
    }

    // Sort by last modified date descending (newest first)
    validApks.sort((a, b) {
      try {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      } catch (_) {
        return 0;
      }
    });

    return validApks.first;
  }
}
