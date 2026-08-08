enum BuildMode {
  debug,
  profile,
  release;

  String get name => toString().split('.').last;

  static BuildMode fromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'debug':
        return BuildMode.debug;
      case 'profile':
        return BuildMode.profile;
      case 'release':
      default:
        return BuildMode.release;
    }
  }
}

class BuildConfig {
  final String? flavor;
  final String entryPoint;
  final BuildMode mode;

  const BuildConfig({
    this.flavor,
    this.entryPoint = 'lib/main.dart',
    this.mode = BuildMode.release,
  });

  List<String> toFlutterArgs() {
    final List<String> args = ['build', 'apk', '--${mode.name}'];

    if (flavor != null && flavor!.isNotEmpty) {
      args.addAll(['--flavor', flavor!]);
    }

    if (entryPoint.isNotEmpty) {
      args.addAll(['-t', entryPoint]);
    }

    return args;
  }

  @override
  String toString() {
    return 'BuildConfig(flavor: $flavor, entryPoint: $entryPoint, mode: ${mode.name})';
  }
}
