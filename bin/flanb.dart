import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as p;

import 'package:flanb/android/android_apk_locator.dart';
import 'package:flanb/android/android_build_manager.dart';
import 'package:flanb/android/android_project.dart';
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
import 'package:flanb/project/project_type.dart';
import 'package:flanb/server/log_stream.dart';
import 'package:flanb/server/network.dart';
import 'package:flanb/server/server.dart';
import 'package:flanb/tunnel/tunnel_discovery.dart';
import 'package:flanb/tunnel/tunnel_provider.dart';
import 'package:flanb/tunnel/tunnel_service.dart';

const String version = '0.7.2';

ArgParser buildParser() {
  return ArgParser()
    ..addOption(
      'file',
      help: 'Share any custom file over LAN and Public Tunnel (e.g. flanb --file ./my_app.apk).',
    )
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
    ..addOption(
      'tunnel',
      abbr: 'u',
      help: 'Tunnel local server to a public HTTPS URL (cloudflared, ngrok, lt, ssh, none).',
    )
    ..addFlag(
      'show-tunnels',
      negatable: false,
      help: 'List supported tunneling services and their installation status on this device.',
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
  print('FLANB — Flutter & Android LAN Build CLI v$version');
  print('Usage: flanb [options]\n');
  print(parser.usage);
}

Future<void> main(List<String> rawArguments) async {
  // Pre-process arguments if user passed `--file` without an explicit path
  final List<String> arguments = List.from(rawArguments);
  final fileFlagIndex = arguments.indexOf('--file');
  if (fileFlagIndex != -1) {
    final isLast = fileFlagIndex == arguments.length - 1;
    final nextIsFlag = !isLast && arguments[fileFlagIndex + 1].startsWith('-');
    if (isLast || nextIsFlag) {
      arguments.insert(fileFlagIndex + 1, '');
    }
  }

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

  if (results.flag('show-tunnels')) {
    final installed = await TunnelDiscovery.discoverAvailable();
    CliOutput.printSupportedTunnels(installed);
    return;
  }

  final bool nonInteractive = results.flag('non-interactive');

  // 1. Check for Custom File Sharing Mode
  if (results.wasParsed('file')) {
    await runFileShareFlow(results: results, nonInteractive: nonInteractive);
    return;
  }

  CliOutput.printBanner();

  // 2. Detect Project Type (Flutter vs Native Android)
  final projectType = ProjectDetector.detect();

  if (projectType == ProjectType.flutter) {
    await runFlutterFlow(results: results, nonInteractive: nonInteractive);
  } else if (projectType == ProjectType.android) {
    await runAndroidFlow(results: results, nonInteractive: nonInteractive);
  } else {
    CliOutput.printInvalidProjectError();
    exit(1);
  }
}

// -----------------------------------------------------------------------------
// FLOW 1: CUSTOM FILE SHARING FLOW (`flanb --file [PATH]`)
// -----------------------------------------------------------------------------
Future<void> runFileShareFlow({
  required ArgResults results,
  required bool nonInteractive,
}) async {
  final rawPath = (results['file'] as String?)?.trim() ?? '';
  File sharedFile;

  if (rawPath.isEmpty) {
    final currentDirFiles = Directory.current
        .listSync()
        .whereType<File>()
        .where((f) => !p.basename(f.path).startsWith('.'))
        .toList();

    currentDirFiles.sort((a, b) =>
        p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase()));

    if (currentDirFiles.isEmpty) {
      CliOutput.printError('No shareable files found in current directory.');
      exit(1);
    }

    if (currentDirFiles.length > 25) {
      CliOutput.printError(
          'Too many files (${currentDirFiles.length} files found) to display in current directory.');
      CliOutput.printInfo(
          'Please specify a file path with the argument (e.g. flanb --file ./app-release.apk).');
      exit(1);
    }

    if (nonInteractive) {
      sharedFile = currentDirFiles.first;
    } else {
      sharedFile = Prompts.selectFromList<File>(
        title: 'Select a file to share from current directory:',
        choices: currentDirFiles,
        displayItem: (f) {
          final sizeMB = (f.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
          return '${p.basename(f.path)} ($sizeMB MB)';
        },
      );
    }
  } else {
    final entityType = FileSystemEntity.typeSync(rawPath);

    if (entityType == FileSystemEntityType.directory) {
      CliOutput.printError('Directory sharing is not supported as of now.');
      CliOutput.printInfo(
          'Please specify a file path (e.g. flanb --file ./my_app.apk).');
      exit(1);
    }

    sharedFile = File(rawPath);

    if (!sharedFile.existsSync()) {
      CliOutput.printError('File not found at path: "$rawPath"');
      exit(1);
    }
  }

  final fileName = p.basename(sharedFile.path);
  final sizeMB = (sharedFile.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
  CliOutput.printFileSharerBanner(fileName, sizeMB);

  final availableTunnels = await TunnelDiscovery.discoverAvailable();
  TunnelProvider selectedTunnel;

  if (results.wasParsed('tunnel')) {
    selectedTunnel = TunnelProvider.fromString(results['tunnel'] as String);
  } else if (!nonInteractive && availableTunnels.length > 1) {
    selectedTunnel = Prompts.selectTunnelProvider(availableTunnels);
  } else {
    selectedTunnel = TunnelProvider.none;
  }

  final logManager = LogManager();
  final dummyConfig = BuildConfig(entryPoint: fileName, mode: BuildMode.release);
  final buildManager = BuildManager(projectRoot: Directory.current.path, config: dummyConfig);

  final port = int.tryParse(results['port'] as String) ?? 8080;
  final server = LanServer(
    projectName: 'FLANB File Sharer',
    projectVersion: version,
    buildConfig: dummyConfig,
    buildManager: buildManager,
    logManager: logManager,
    getApkFile: () => sharedFile,
    requestedPort: port,
    customSharedFile: sharedFile,
  );

  final actualPort = await server.start();
  final lanIps = (await NetworkUtils.getLanIps()).map((info) => info.ipAddress).toList();
  final primaryLanUrl = lanIps.isNotEmpty ? 'http://${lanIps.first}:$actualPort' : 'http://localhost:$actualPort';
  server.primaryLanUrl = primaryLanUrl;

  TunnelService? tunnelService;
  if (selectedTunnel != TunnelProvider.none) {
    tunnelService = TunnelService(selectedTunnel);
    final tunnelSpinner = TerminalSpinner(
      message: 'Establishing ${selectedTunnel.displayName}...',
    );
    tunnelSpinner.start();
    final publicUrl = await tunnelService.start(actualPort);
    tunnelSpinner.stop();

    if (publicUrl != null) {
      server.tunnelUrl = publicUrl;
      CliOutput.printSuccess('Public Tunnel established: $publicUrl');
    } else {
      final reason = tunnelService.failureReason ?? 'Unknown error';
      CliOutput.printWarning('${selectedTunnel.displayName} failed ($reason).');
      CliOutput.printInfo('Falling back seamlessly to Local LAN Server.');
    }
  }

  CliOutput.printServerUrls(
    port: actualPort,
    lanIps: lanIps,
    tunnelUrl: server.tunnelUrl,
  );

  final downloadUrl = server.tunnelUrl != null ? '${server.tunnelUrl}/download' : '$primaryLanUrl/download';

  print('${CliOutput.green}${CliOutput.bold}✓ File Share Active! Direct Download URL:${CliOutput.reset} ${CliOutput.cyan}${CliOutput.bold}$downloadUrl${CliOutput.reset}');
  print('\n${CliOutput.dim}Server is active. Press Ctrl+C to stop sharing.${CliOutput.reset}\n');

  if (!results.flag('no-browser')) {
    unawaited(BrowserLauncher.openUrl('http://localhost:$actualPort'));
  }

  final completer = Completer<void>();
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n\nShutting down FLANB file sharer...');
    tunnelService?.stop();
    await server.stop();
    logManager.dispose();
    completer.complete();
    exit(0);
  });

  await completer.future;
}

// -----------------------------------------------------------------------------
// FLOW 2: FLUTTER BUILD ENGINE FLOW
// -----------------------------------------------------------------------------
Future<void> runFlutterFlow({
  required ArgResults results,
  required bool nonInteractive,
}) async {
  final project = FlutterProject.fromDirectory();
  CliOutput.printSuccess('Flutter project detected: ${project.name}');

  while (true) {
    final discoveredFlavors = FlavorDiscovery.discover(project.rootPath);
    String? selectedFlavor = results['flavor'] as String?;

    if (selectedFlavor == null && !nonInteractive) {
      if (discoveredFlavors.isNotEmpty) {
        CliOutput.printInfo('Discovered Android flavors: ${discoveredFlavors.join(', ')}');
        selectedFlavor = Prompts.selectFlavor(discoveredFlavors);
      }
    }

    final discoveredEntrypoints = EntrypointDiscovery.discover(project.rootPath);
    String selectedEntrypoint = (results['target'] as String?) ?? '';

    if (selectedEntrypoint.isEmpty) {
      if (nonInteractive || discoveredEntrypoints.length <= 1) {
        selectedEntrypoint = discoveredEntrypoints.first;
      } else {
        selectedEntrypoint = Prompts.selectEntrypoint(discoveredEntrypoints);
      }
    }

    BuildMode selectedMode;
    if (results.wasParsed('mode') || nonInteractive) {
      selectedMode = BuildMode.fromString(results['mode'] as String);
    } else {
      selectedMode = Prompts.selectBuildMode();
    }

    final availableTunnels = await TunnelDiscovery.discoverAvailable();
    TunnelProvider selectedTunnel;

    if (results.wasParsed('tunnel')) {
      selectedTunnel = TunnelProvider.fromString(results['tunnel'] as String);
    } else if (!nonInteractive && availableTunnels.length > 1) {
      selectedTunnel = Prompts.selectTunnelProvider(availableTunnels);
    } else {
      selectedTunnel = TunnelProvider.none;
    }

    final config = BuildConfig(
      flavor: selectedFlavor,
      entryPoint: selectedEntrypoint,
      mode: selectedMode,
    );

    print('\n${CliOutput.bold}Build Configuration (Flutter):${CliOutput.reset}');
    print('  Project:    ${project.name}');
    print('  Version:    ${project.version}');
    print('  Flavor:     ${config.flavor ?? 'default (none)'}');
    print('  Entrypoint: ${config.entryPoint}');
    print('  Mode:       ${config.mode.name}');
    print('  Tunnel:     ${selectedTunnel.displayName}\n');

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
    final primaryLanUrl = lanIps.isNotEmpty ? 'http://${lanIps.first}:$actualPort' : 'http://localhost:$actualPort';
    server.primaryLanUrl = primaryLanUrl;

    TunnelService? tunnelService;
    if (selectedTunnel != TunnelProvider.none) {
      tunnelService = TunnelService(selectedTunnel);
      final tunnelSpinner = TerminalSpinner(
        message: 'Establishing ${selectedTunnel.displayName}...',
      );
      tunnelSpinner.start();
      final publicUrl = await tunnelService.start(actualPort);
      tunnelSpinner.stop();

      if (publicUrl != null) {
        server.tunnelUrl = publicUrl;
        CliOutput.printSuccess('Public Tunnel established: $publicUrl');
      } else {
        final reason = tunnelService.failureReason ?? 'Unknown error';
        CliOutput.printWarning('${selectedTunnel.displayName} failed ($reason).');
        CliOutput.printInfo('Falling back seamlessly to Local LAN Server.');
      }
    }

    CliOutput.printServerUrls(
      port: actualPort,
      lanIps: lanIps,
      tunnelUrl: server.tunnelUrl,
    );

    if (!results.flag('no-browser')) {
      unawaited(BrowserLauncher.openUrl('http://localhost:$actualPort'));
    }

    bool isFirstBuild = true;

    while (true) {
      if (!isFirstBuild) {
        logManager.addLog('\n--- REBUILDING FLUTTER APK ---');
      }

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
            primaryLanUrl: server.primaryLanUrl,
            tunnelUrl: server.tunnelUrl,
            showQr: isFirstBuild,
          );
        } else {
          CliOutput.printWarning('Build completed, but could not locate the generated APK file.');
          CliOutput.printInfo('Checked directory: build/app/outputs/flutter-apk/');
        }
      } else {
        CliOutput.printBuildCompletion(
          success: false,
          tunnelUrl: server.tunnelUrl,
          showQr: isFirstBuild,
        );
      }

      if (nonInteractive) {
        final completer = Completer<void>();
        ProcessSignal.sigint.watch().listen((_) async {
          print('\n\nShutting down FLANB server...');
          tunnelService?.stop();
          await server.stop();
          logManager.dispose();
          completer.complete();
          exit(0);
        });
        await completer.future;
        return;
      }

      final action = await Prompts.listenForRebuildAction();
      if (action == RebuildAction.rebuildSameConfig) {
        isFirstBuild = false;
        continue;
      } else {
        print('\nShutting down active server and restarting configuration flow...');
        tunnelService?.stop();
        await server.stop();
        logManager.dispose();
        break;
      }
    }
  }
}

// -----------------------------------------------------------------------------
// FLOW 3: NATIVE ANDROID BUILD ENGINE FLOW
// -----------------------------------------------------------------------------
Future<void> runAndroidFlow({
  required ArgResults results,
  required bool nonInteractive,
}) async {
  final androidProject = AndroidProject.fromDirectory();
  CliOutput.printSuccess('Native Android project detected: ${androidProject.name}');

  while (true) {
    final discoveredFlavors = androidProject.discoveredFlavors;
    String? selectedFlavor = results['flavor'] as String?;

    if (selectedFlavor == null && !nonInteractive) {
      if (discoveredFlavors.isNotEmpty) {
        CliOutput.printInfo('Discovered Android flavors: ${discoveredFlavors.join(', ')}');
        selectedFlavor = Prompts.selectFlavor(discoveredFlavors);
      }
    }

    BuildMode selectedMode;
    if (results.wasParsed('mode') || nonInteractive) {
      selectedMode = BuildMode.fromString(results['mode'] as String);
      if (selectedMode == BuildMode.profile) {
        selectedMode = BuildMode.release;
      }
    } else {
      selectedMode = Prompts.selectAndroidBuildMode();
    }

    final availableTunnels = await TunnelDiscovery.discoverAvailable();
    TunnelProvider selectedTunnel;

    if (results.wasParsed('tunnel')) {
      selectedTunnel = TunnelProvider.fromString(results['tunnel'] as String);
    } else if (!nonInteractive && availableTunnels.length > 1) {
      selectedTunnel = Prompts.selectTunnelProvider(availableTunnels);
    } else {
      selectedTunnel = TunnelProvider.none;
    }

    print('\n${CliOutput.bold}Build Configuration (Native Android):${CliOutput.reset}');
    print('  Project:    ${androidProject.name}');
    print('  Flavor:     ${selectedFlavor ?? 'default (none)'}');
    print('  Mode:       ${selectedMode.name}');
    print('  Tunnel:     ${selectedTunnel.displayName}\n');

    final logManager = LogManager();
    final androidBuildManager = AndroidBuildManager(
      projectRoot: androidProject.rootPath,
      flavor: selectedFlavor,
      mode: selectedMode,
    );

    File? locatedApk;
    final dummyConfig = BuildConfig(entryPoint: 'Android App', mode: selectedMode, flavor: selectedFlavor);
    final dummyFlutterBuildMgr = BuildManager(projectRoot: androidProject.rootPath, config: dummyConfig);

    final port = int.tryParse(results['port'] as String) ?? 8080;
    final server = LanServer(
      projectName: androidProject.name,
      projectVersion: 'Android',
      buildConfig: dummyConfig,
      buildManager: dummyFlutterBuildMgr,
      logManager: logManager,
      getApkFile: () => locatedApk,
      requestedPort: port,
    );

    final actualPort = await server.start();
    final lanIps = (await NetworkUtils.getLanIps()).map((info) => info.ipAddress).toList();
    final primaryLanUrl = lanIps.isNotEmpty ? 'http://${lanIps.first}:$actualPort' : 'http://localhost:$actualPort';
    server.primaryLanUrl = primaryLanUrl;

    TunnelService? tunnelService;
    if (selectedTunnel != TunnelProvider.none) {
      tunnelService = TunnelService(selectedTunnel);
      final tunnelSpinner = TerminalSpinner(
        message: 'Establishing ${selectedTunnel.displayName}...',
      );
      tunnelSpinner.start();
      final publicUrl = await tunnelService.start(actualPort);
      tunnelSpinner.stop();

      if (publicUrl != null) {
        server.tunnelUrl = publicUrl;
        CliOutput.printSuccess('Public Tunnel established: $publicUrl');
      } else {
        final reason = tunnelService.failureReason ?? 'Unknown error';
        CliOutput.printWarning('${selectedTunnel.displayName} failed ($reason).');
        CliOutput.printInfo('Falling back seamlessly to Local LAN Server.');
      }
    }

    CliOutput.printServerUrls(
      port: actualPort,
      lanIps: lanIps,
      tunnelUrl: server.tunnelUrl,
    );

    if (!results.flag('no-browser')) {
      unawaited(BrowserLauncher.openUrl('http://localhost:$actualPort'));
    }

    bool isFirstBuild = true;

    while (true) {
      if (!isFirstBuild) {
        logManager.addLog('\n--- REBUILDING NATIVE ANDROID APK ---');
      }

      final buildStartTime = DateTime.now();
      final taskTag = androidBuildManager.taskName;
      final spinner = TerminalSpinner(
        message: 'Building Native Android APK ($taskTag)...',
      );
      spinner.start();

      dummyFlutterBuildMgr.status = BuildStatus.building;
      final buildSuccess = await androidBuildManager.build(onLog: (line) {
        logManager.addLog(line);
      });
      spinner.stop();

      if (buildSuccess) {
        dummyFlutterBuildMgr.status = BuildStatus.success;
        locatedApk = AndroidApkLocator.locate(
          androidProject.rootPath,
          flavor: selectedFlavor,
          mode: selectedMode,
          buildStartTime: buildStartTime,
        );

        if (locatedApk != null && locatedApk.existsSync()) {
          final sizeMB = (locatedApk.lengthSync() / (1024 * 1024)).toStringAsFixed(1);
          final relPath = p.relative(locatedApk.path, from: androidProject.rootPath);
          CliOutput.printBuildCompletion(
            success: true,
            apkPath: relPath,
            apkSizeMb: sizeMB,
            primaryLanUrl: server.primaryLanUrl,
            tunnelUrl: server.tunnelUrl,
            showQr: isFirstBuild,
          );
        } else {
          CliOutput.printWarning('Gradle build completed, but could not locate generated APK file.');
          CliOutput.printInfo('Checked directory: app/build/outputs/apk/');
        }
      } else {
        dummyFlutterBuildMgr.status = BuildStatus.failed;
        CliOutput.printBuildCompletion(
          success: false,
          tunnelUrl: server.tunnelUrl,
          showQr: isFirstBuild,
        );
      }

      if (nonInteractive) {
        final completer = Completer<void>();
        ProcessSignal.sigint.watch().listen((_) async {
          print('\n\nShutting down FLANB server...');
          tunnelService?.stop();
          await server.stop();
          logManager.dispose();
          completer.complete();
          exit(0);
        });
        await completer.future;
        return;
      }

      final action = await Prompts.listenForRebuildAction();
      if (action == RebuildAction.rebuildSameConfig) {
        isFirstBuild = false;
        continue;
      } else {
        print('\nShutting down active server and restarting configuration flow...');
        tunnelService?.stop();
        await server.stop();
        logManager.dispose();
        break;
      }
    }
  }
}
