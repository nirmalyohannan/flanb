import 'dart:io';
import 'package:path/path.dart' as p;
import 'build_config.dart';

class ApkLocator {
  /// Searches for the generated APK in the Flutter project build output.
  /// Returns the absolute path of the generated APK, or null if not found.
  static File? locate(
    String projectRoot,
    BuildConfig config, {
    DateTime? buildStartTime,
  }) {
    final searchDirs = [
      Directory(p.join(projectRoot, 'build', 'app', 'outputs', 'flutter-apk')),
      Directory(p.join(projectRoot, 'build', 'app', 'outputs', 'apk')),
    ];

    final List<File> apkCandidates = [];

    for (final dir in searchDirs) {
      if (!dir.existsSync()) continue;

      try {
        final entities = dir.listSync(recursive: true, followLinks: false);
        for (final entity in entities) {
          if (entity is File && entity.path.endsWith('.apk')) {
            // Exclude intermediate unaligned / unsigned / tmp apks if necessary
            final name = p.basename(entity.path).toLowerCase();
            if (name.contains('unaligned') || name.contains('unsigned')) {
              continue;
            }
            apkCandidates.add(entity);
          }
        }
      } catch (_) {}
    }

    if (apkCandidates.isEmpty) return null;

    // Filter by timestamp if provided (with 10-second margin of safety)
    final cutoffTime = buildStartTime?.subtract(const Duration(seconds: 10));
    final validCandidates = cutoffTime == null
        ? apkCandidates
        : apkCandidates.where((file) {
            try {
              return file.lastModifiedSync().isAfter(cutoffTime);
            } catch (_) {
              return true;
            }
          }).toList();

    if (validCandidates.isEmpty) {
      // Fall back to all candidates if timestamp filter excluded everything
      validCandidates.addAll(apkCandidates);
    }

    final modeStr = config.mode.name.toLowerCase();
    final flavorStr = config.flavor?.toLowerCase();

    // Score candidates based on match relevance
    File? bestMatch;
    int highestScore = -1;

    for (final file in validCandidates) {
      final name = p.basename(file.path).toLowerCase();
      int score = 0;

      if (name.contains(modeStr)) score += 10;
      if (flavorStr != null && flavorStr.isNotEmpty) {
        if (name.contains(flavorStr)) score += 20;
      }
      if (name.startsWith('app-')) score += 5;

      // Newer files preferred
      try {
        final modified = file.lastModifiedSync().millisecondsSinceEpoch;
        score += (modified ~/ 1000000); // Slight boost for timestamp
      } catch (_) {}

      if (score > highestScore) {
        highestScore = score;
        bestMatch = file;
      }
    }

    return bestMatch;
  }
}
