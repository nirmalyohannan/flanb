import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../build/build_config.dart';
import '../tunnel/tunnel_provider.dart';
import 'output.dart';

class Prompts {
  /// Renders a list selection menu and captures arrow key inputs (↑ / ↓) or numbers.
  static T selectFromList<T>({
    required String title,
    required List<T> choices,
    required String Function(T choice) displayItem,
    int defaultIndex = 0,
  }) {
    if (choices.isEmpty) {
      throw ArgumentError('Choices list cannot be empty.');
    }

    try {
      if (!stdin.hasTerminal) {
        return _selectFromListFallback(
          title: title,
          choices: choices,
          displayItem: displayItem,
          defaultIndex: defaultIndex,
        );
      }
    } catch (_) {
      return _selectFromListFallback(
        title: title,
        choices: choices,
        displayItem: displayItem,
        defaultIndex: defaultIndex,
      );
    }

    int selectedIndex = defaultIndex;
    bool originalLine = true;
    bool originalEcho = true;

    try {
      originalLine = stdin.lineMode;
      originalEcho = stdin.echoMode;
    } catch (_) {}

    try {
      stdin.lineMode = false;
      stdin.echoMode = false;

      print('\n${CliOutput.cyan}? $title${CliOutput.reset} ${CliOutput.dim}(Use ↑/↓ arrows, Enter to confirm)${CliOutput.reset}');
      _renderMenu(choices, selectedIndex, displayItem);

      while (true) {
        final byte = stdin.readByteSync();

        if (byte == 10 || byte == 13) {
          // Enter key
          break;
        } else if (byte == 27) {
          // ANSI Escape sequence start
          final next1 = stdin.readByteSync();
          if (next1 == 91) {
            final next2 = stdin.readByteSync();
            if (next2 == 65) {
              // Arrow Up
              if (selectedIndex > 0) {
                selectedIndex--;
                _renderMenu(choices, selectedIndex, displayItem, isUpdate: true);
              }
            } else if (next2 == 66) {
              // Arrow Down
              if (selectedIndex < choices.length - 1) {
                selectedIndex++;
                _renderMenu(choices, selectedIndex, displayItem, isUpdate: true);
              }
            }
          }
        } else if (byte >= 49 && byte <= 57) {
          // Number keys 1-9
          final index = byte - 49;
          if (index < choices.length) {
            selectedIndex = index;
            _renderMenu(choices, selectedIndex, displayItem, isUpdate: true);
            break;
          }
        }
      }
    } catch (_) {
      return _selectFromListFallback(
        title: title,
        choices: choices,
        displayItem: displayItem,
        defaultIndex: defaultIndex,
      );
    } finally {
      try {
        stdin.lineMode = originalLine;
        stdin.echoMode = originalEcho;
      } catch (_) {}
    }

    print('');
    return choices[selectedIndex];
  }

  /// Numbered input fallback for non-raw mode terminals.
  static T _selectFromListFallback<T>({
    required String title,
    required List<T> choices,
    required String Function(T choice) displayItem,
    int defaultIndex = 0,
  }) {
    print('\n${CliOutput.cyan}? $title${CliOutput.reset}');

    for (int i = 0; i < choices.length; i++) {
      final isDefault = i == defaultIndex;
      final defaultMark = isDefault ? ' ${CliOutput.dim}(default)${CliOutput.reset}' : '';
      print('  ${CliOutput.bold}[${i + 1}]${CliOutput.reset} ${displayItem(choices[i])}$defaultMark');
    }

    stdout.write('${CliOutput.cyan}Enter selection [1-${choices.length}] (default ${defaultIndex + 1}): ${CliOutput.reset}');
    final input = stdin.readLineSync()?.trim();

    if (input == null || input.isEmpty) {
      return choices[defaultIndex];
    }

    final parsedIndex = int.tryParse(input);
    if (parsedIndex != null && parsedIndex >= 1 && parsedIndex <= choices.length) {
      return choices[parsedIndex - 1];
    }

    print('${CliOutput.yellow}Invalid choice "$input", using default (${defaultIndex + 1}).${CliOutput.reset}');
    return choices[defaultIndex];
  }

  /// Selects a flavor from discovered flavors. Returns null if user chooses default/no flavor.
  static String? selectFlavor(List<String> discoveredFlavors) {
    if (discoveredFlavors.isEmpty) return null;

    final options = ['No flavor (default)', ...discoveredFlavors];
    final selected = selectFromList<String>(
      title: 'Select Android Flavor:',
      choices: options,
      displayItem: (item) => item,
      defaultIndex: 0,
    );

    return selected == 'No flavor (default)' ? null : selected;
  }

  /// Selects a Dart entrypoint from discovered candidates.
  static String selectEntrypoint(List<String> discoveredEntrypoints) {
    if (discoveredEntrypoints.isEmpty) return 'lib/main.dart';
    if (discoveredEntrypoints.length == 1) return discoveredEntrypoints.first;

    return selectFromList<String>(
      title: 'Select Dart Entry Point:',
      choices: discoveredEntrypoints,
      displayItem: (item) => item,
      defaultIndex: 0,
    );
  }

  /// Selects build mode (Debug, Profile, Release).
  static BuildMode selectBuildMode() {
    final modes = [BuildMode.release, BuildMode.debug, BuildMode.profile];
    return selectFromList<BuildMode>(
      title: 'Select Build Mode:',
      choices: modes,
      displayItem: (mode) {
        switch (mode) {
          case BuildMode.release:
            return 'Release (optimised for deployment)';
          case BuildMode.debug:
            return 'Debug (faster build, larger binary)';
          case BuildMode.profile:
            return 'Profile (for performance testing)';
        }
      },
      defaultIndex: 0,
    );
  }

  /// Selects build mode for Native Android (Release or Debug only).
  static BuildMode selectAndroidBuildMode() {
    final modes = [BuildMode.release, BuildMode.debug];
    return selectFromList<BuildMode>(
      title: 'Select Build Mode (Native Android):',
      choices: modes,
      displayItem: (mode) {
        switch (mode) {
          case BuildMode.release:
            return 'Release (optimised for deployment)';
          case BuildMode.debug:
            return 'Debug (faster build, larger binary)';
          case BuildMode.profile:
            return 'Profile (for performance testing)';
        }
      },
      defaultIndex: 0,
    );
  }

  /// Prompts user whether to perform a Clean Build before building.
  static bool selectCleanBuild() {
    final choices = [false, true];
    return selectFromList<bool>(
      title: 'Perform Clean Build before building? (pub cache clean, rm lockfile, pub get)',
      choices: choices,
      displayItem: (choice) {
        return choice
            ? 'Yes (clean cache, delete pubspec.lock & run pub get)'
            : 'No (incremental build, faster)';
      },
      defaultIndex: 0,
    );
  }

  /// Prompts user to select a tunnel provider from available discovered options.
  static TunnelProvider selectTunnelProvider(List<TunnelProvider> availableProviders) {
    if (availableProviders.length <= 1) return TunnelProvider.none;

    return selectFromList<TunnelProvider>(
      title: 'Select Public Tunnel Service:',
      choices: availableProviders,
      displayItem: (provider) {
        if (provider == TunnelProvider.none) {
          return 'No Tunnel (Local LAN Server only)';
        }
        return '${provider.displayName}${provider.executableName != null ? ' (${provider.executableName})' : ''}';
      },
      defaultIndex: 0,
    );
  }

  /// Listens non-blockingly for terminal keypresses after a build completes or fails.
  /// Returns [RebuildAction.rebuildSameConfig] for 'r' / 'Ctrl+r',
  /// or [RebuildAction.restartConfig] for 'c'.
  static Future<RebuildAction> listenForRebuildAction() async {
    CliOutput.printRebuildPrompt();

    try {
      if (!stdin.hasTerminal) {
        return await _listenForRebuildActionFallback();
      }
    } catch (_) {
      return await _listenForRebuildActionFallback();
    }

    bool originalEcho = true;
    bool originalLine = true;

    try {
      originalEcho = stdin.echoMode;
      originalLine = stdin.lineMode;
    } catch (_) {}

    final completer = Completer<RebuildAction>();
    StreamSubscription<List<int>>? subscription;

    try {
      stdin.echoMode = false;
      stdin.lineMode = false;

      subscription = stdin.listen((List<int> event) {
        for (final byte in event) {
          if (byte == 114 || byte == 82 || byte == 18) {
            // 'r', 'R', or Ctrl+R
            print('');
            if (!completer.isCompleted) {
              completer.complete(RebuildAction.rebuildSameConfig);
            }
            break;
          } else if (byte == 99 || byte == 67) {
            // 'c' or 'C'
            print('');
            if (!completer.isCompleted) {
              completer.complete(RebuildAction.restartConfig);
            }
            break;
          } else if (byte == 3) {
            // Ctrl+C
            print('\nShutting down FLANB...');
            exit(0);
          }
        }
      });

      return await completer.future;
    } catch (_) {
      return await _listenForRebuildActionFallback();
    } finally {
      await subscription?.cancel();
      try {
        stdin.lineMode = originalLine;
        stdin.echoMode = originalEcho;
      } catch (_) {}
    }
  }

  static Future<RebuildAction> _listenForRebuildActionFallback() async {
    stdout.write('${CliOutput.cyan}Enter choice [r=rebuild, c=change config]: ${CliOutput.reset}');
    final completer = Completer<String>();
    StreamSubscription<String>? sub;

    sub = stdin.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (!completer.isCompleted) {
        completer.complete(line);
      }
    });

    final input = (await completer.future).trim().toLowerCase();
    await sub.cancel();

    if (input == 'c' || input == 'change') {
      return RebuildAction.restartConfig;
    }
    return RebuildAction.rebuildSameConfig;
  }

  static void _renderMenu<T>(
    List<T> choices,
    int selectedIndex,
    String Function(T choice) displayItem, {
    bool isUpdate = false,
  }) {
    if (isUpdate) {
      // Clear previous menu lines: move cursor up and clear down
      stdout.write('\x1B[${choices.length}A');
    }

    final terminalWidth = stdout.hasTerminal ? stdout.terminalColumns : 80;

    for (int i = 0; i < choices.length; i++) {
      final isSelected = i == selectedIndex;
      final prefix = isSelected ? '  ${CliOutput.cyan}❯ ' : '    ';
      final text = displayItem(choices[i]);
      final color = isSelected ? '${CliOutput.cyan}${CliOutput.bold}' : '';

      final rawLine = '$prefix$text';
      final truncatedLine = _truncateToTerminalWidth(rawLine, terminalWidth);

      // ANSI: \x1B[1G (move cursor to col 1) + \x1B[0J (clear down)
      stdout.write('\x1B[1G\x1B[0J$color$truncatedLine${CliOutput.reset}\n');
    }
  }

  static String _truncateToTerminalWidth(String line, int width) {
    if (line.length <= width) return line;
    if (width <= 5) return line.substring(0, width);
    return '${line.substring(0, width - 3)}...';
  }
}

enum RebuildAction {
  rebuildSameConfig,
  restartConfig,
}
