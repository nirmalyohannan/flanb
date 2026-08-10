import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'package:flanb/browser/browser_launcher.dart';
import 'package:flanb/build/apk_locator.dart';
import 'package:flanb/build/build_config.dart';
import 'package:flanb/build/build_manager.dart';
import 'package:flanb/cli/output.dart';
import 'package:flanb/cli/prompts.dart';
import 'package:flanb/cli/spinner.dart';
import 'package:flanb/project/entrypoint_discovery.dart';
import 'package:flanb/project/flavor_discovery.dart';
import 'package:flanb/project/flutter_project.dart';
import 'package:flanb/server/log_stream.dart';
import 'package:flanb/server/network.dart';
import 'package:flanb/server/server.dart';

const String version = '0.3.1';

ArgParser buildParser() {
  return ArgParser()
    ..addOption(
      'flavor',
      abbr: 'f',
      help: 'Build a specific Android flavor (e.g. staging, dev, prod).',
    )
    ..addOption(
      'target',
      abbr: 't',
      help: 'The main Dart file to run (e.g. lib/main_staging.dart).',
    )
    ..addOption(
      'mode',
      abbr: 'm',
      allowed: ['debug', 'profile', 'release'],
      defaultsTo: 'release',
      help: 'Build mode: release, debug, or profile.',
    )
    ..addOption(
      'port',
      abbr: 'p',
      defaultsTo: '8080',
      help: 'Port for the local HTTP server.',
    )
    ..addFlag(
      'no-browser',
      negatable: false,
      help: 'Do not automatically open the browser.',
    )
    ..addFlag(
      'non-interactive',
      negatable: false,
      help: 'Run non-interactively using defaults or provided flags.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print usage information.',
    )
    ..addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print FLANB version.',
    );
}

void printUsage(ArgParser parser) {
  print('FLANB — Flutter LAN Build CLI v$version');
  print('Usage: flanb [options]\n');
  print(parser.usage);
}

Future<void> main(List<String> arguments) async {
  final parser = buildParser();
  ArgResults results;

  try {
    results = parser.parse(arguments);
  } on FormatException catch (e) {
    CliOutput.printError(e.message);
    printUsage(parser);
    exit(1);
  }

  if (results.flag('help')) {
    printUsage(parser);
    return;
  }

  if (results.flag('version')) {
    print('flanb version: $version');
    return;
  }

  CliOutput.printBanner();

  // 1. Validate Flutter Project
  FlutterProject project;
  try {
    project = FlutterProject.fromDirectory();
    CliOutput.printSuccess('Flutter project detected: ${project.name}');
  } on FlutterProjectValidationException catch (e) {
    CliOutput.printError(e.message);
    CliOutput.printInfo('Make sure you are running FLANB from the root directory of a Flutter project.');
    exit(1);
  }

  final bool nonInteractive = results.flag('non-interactive');

  // 2. Discover Flavors
  final discoveredFlavors = FlavorDiscovery.discover(project.rootPath);
  String? selectedFlavor = results['flavor'] as String?;

  if (selectedFlavor == null && !nonInteractive) {
    if (discoveredFlavors.isNotEmpty) {
      CliOutput.printInfo('Discovered Android flavors: ${discoveredFlavors.join(', ')}');
      selectedFlavor = Prompts.selectFlavor(discoveredFlavors);
    }
  }

  // 3. Discover Entry Points
  final discoveredEntrypoints = EntrypointDiscovery.discover(project.rootPath);
  String selectedEntrypoint = (results['target'] as String?) ?? '';

  if (selectedEntrypoint.isEmpty) {
    if (nonInteractive || discoveredEntrypoints.length <= 1) {
      selectedEntrypoint = discoveredEntrypoints.first;
    } else {
      selectedEntrypoint = Prompts.selectEntrypoint(discoveredEntrypoints);
    }
  }

  // 4. Select Build Mode
  BuildMode selectedMode;
  if (results.wasParsed('mode') || nonInteractive) {
    selectedMode = BuildMode.fromString(results['mode'] as String);
  } else {
    selectedMode = Prompts.selectBuildMode();
  }

  final config = BuildConfig(
    flavor: selectedFlavor,
    entryPoint: selectedEntrypoint,
    mode: selectedMode,
  );

  print('\n${CliOutput.bold}Build Configuration:${CliOutput.reset}');
  print('  Project:    ${project.name}');
  print('  Version:    ${project.version}');
  print('  Flavor:     ${config.flavor ?? 'default (none)'}');
  print('  Entrypoint: ${config.entryPoint}');
  print('  Mode:       ${config.mode.name}\n');

  // 5. Initialize Build Manager and Server
  final logManager = LogManager();
  final buildManager = BuildManager(
    projectRoot: project.rootPath,
    config: config,
  );

  File? locatedApk;

  final port = int.tryParse(results['port'] as String) ?? 8080;
  final server = LanServer(
    projectName: project.name,
    projectVersion: project.version,
    buildConfig: config,
    buildManager: buildManager,
    logManager: logManager,
    getApkFile: () => locatedApk,
    requestedPort: port,
  );

  final actualPort = await server.start();
  final lanIps = (await NetworkUtils.getLanIps()).map((info) => info.ipAddress).toList();

  CliOutput.printServerUrls(port: actualPort, lanIps: lanIps);

  if (!results.flag('no-browser')) {
    unawaited(BrowserLauncher.openUrl('http://localhost:$actualPort'));
  }

  // 6. Start Flutter Build with single-line animated spinner
  final buildStartTime = DateTime.now();
  final flavorTag = config.flavor ?? 'default';
  final spinner = TerminalSpinner(
    message: 'Building Flutter APK ($flavorTag | ${config.mode.name} | ${config.entryPoint})...',
  );
  spinner.start();

  final buildSuccess = await buildManager.build(onLog: (line) {
    logManager.addLog(line);
  });
  spinner.stop();

  final primaryLanUrl = lanIps.isNotEmpty ? 'http://${lanIps.first}:$actualPort' : 'http://localhost:$actualPort';

  if (buildSuccess) {
    locatedApk = ApkLocator.locate(
      project.rootPath,
      config,
      buildStartTime: buildStartTime,
    );

    if (locatedApk != null && locatedApk.existsSync()) {
      final sizeMB = (locatedApk.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
      final relPath = p.relative(locatedApk.path, from: project.rootPath);
      CliOutput.printBuildCompletion(
        success: true,
        apkPath: relPath,
        apkSizeMb: sizeMB,
        primaryLanUrl: primaryLanUrl,
      );
    } else {
      CliOutput.printWarning('Build completed, but could not locate the generated APK file.');
      CliOutput.printInfo('Checked directory: build/app/outputs/flutter-apk/');
    }
  } else {
    CliOutput.printBuildCompletion(
      success: false,
    );
  }

  final completer = Completer<void>();
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n\nShutting down FLANB LAN server...');
    await server.stop();
    logManager.dispose();
    completer.complete();
    exit(0);
  });

  await completer.future;
}
