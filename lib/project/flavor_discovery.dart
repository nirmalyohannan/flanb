import 'dart:io';
import 'package:path/path.dart' as p;

class FlavorDiscovery {
  static const Set<String> _ignoredKeywords = {
    'create',
    'register',
    'getByName',
    'all',
    'dimension',
    'dimensions',
    'flavorDimensions',
    'manifestPlaceholders',
    'matchingFallbacks',
    'applicationId',
    'applicationIdSuffix',
    'versionName',
    'versionNameSuffix',
    'versionCode',
    'resValue',
    'buildConfigField',
    'signingConfig',
    'proguardFiles',
    'minSdkVersion',
    'targetSdkVersion',
    'compileSdkVersion',
  };

  /// Discovers Android product flavors in the given Flutter project root directory.
  /// Returns a list of flavor names, or an empty list if none are found.
  static List<String> discover(String projectRoot) {
    final groovyFile = File(p.join(projectRoot, 'android', 'app', 'build.gradle'));
    final ktsFile = File(p.join(projectRoot, 'android', 'app', 'build.gradle.kts'));

    if (groovyFile.existsSync()) {
      final flavors = _parseGradleFile(groovyFile.readAsStringSync());
      if (flavors.isNotEmpty) return flavors;
    }

    if (ktsFile.existsSync()) {
      final flavors = _parseGradleFile(ktsFile.readAsStringSync());
      if (flavors.isNotEmpty) return flavors;
    }

    return [];
  }

  /// Extracts the content between matching { and } braces for a named block.
  static String? _extractBlock(String content, String blockName) {
    final index = content.indexOf(blockName);
    if (index == -1) return null;

    final openBraceIndex = content.indexOf('{', index);
    if (openBraceIndex == -1) return null;

    int depth = 1;
    int i = openBraceIndex + 1;
    while (i < content.length && depth > 0) {
      final char = content[i];
      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
      }
      i++;
    }

    if (depth == 0) {
      return content.substring(openBraceIndex + 1, i - 1);
    }

    return null;
  }

  /// Parses contents of build.gradle or build.gradle.kts to discover product flavors.
  static List<String> _parseGradleFile(String content) {
    final Set<String> flavors = {};

    final blockContent = _extractBlock(content, 'productFlavors');
    if (blockContent == null || blockContent.trim().isEmpty) {
      return [];
    }

    // Strategy 1: Kotlin DSL create("flavorName") or register("flavorName")
    final dslMatches = RegExp(
      '(?:create|register)\\s*\\(\\s*["\']([^"\']+)["\']\\s*\\)',
    ).allMatches(blockContent);

    for (final match in dslMatches) {
      final name = match.group(1)?.trim();
      if (name != null && name.isNotEmpty && !_ignoredKeywords.contains(name)) {
        flavors.add(name);
      }
    }

    // Strategy 2: Groovy or Kotlin block syntax flavorName { ... }
    final blockMatches = RegExp(
      r'^\s*([a-zA-Z0-9_\-]+)\s*\{',
      multiLine: true,
    ).allMatches(blockContent);

    for (final match in blockMatches) {
      final name = match.group(1)?.trim();
      if (name != null && name.isNotEmpty && !_ignoredKeywords.contains(name)) {
        flavors.add(name);
      }
    }

    return flavors.toList()..sort();
  }
}
