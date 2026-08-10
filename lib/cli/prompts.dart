import 'dart:io';
import '../build/build_config.dart';
import '../tunnel/tunnel_provider.dart';
import 'output.dart';

class Prompts {
  /// Prompts the user to select an item from a list using arrow keys (↑/↓) or numbered fallback.
  static T selectFromList<T>({
    required String title,
    required List<T> choices,
    required String Function(T choice) displayItem,
    int defaultIndex = 0,
  }) {
    if (choices.isEmpty) {
      throw ArgumentError('Choices list cannot be empty.');
    }
    if (choices.length == 1) {
      return choices.first;
    }

    // Fallback if terminal does not support raw mode
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
    bool originalEcho = true;
    bool originalLine = true;

    try {
      originalEcho = stdin.echoMode;
      originalLine = stdin.lineMode;
    } catch (_) {}

    void renderMenu({bool isFirst = false}) {
      int termCols = 80;
      try {
        if (stdout.hasTerminal) {
          termCols = stdout.terminalColumns;
        }
      } catch (_) {}

      if (!isFirst) {
        // Move to column 1, move up by choices count + 1 lines, and clear down
        stdout.write('\x1B[1G\x1B[${choices.length + 1}A\x1B[0J');
      }

      final titleStr = '? $title (Use ↑/↓ arrows, Enter to confirm)';
      final safeTitle = titleStr.length > termCols && termCols > 10
          ? '${titleStr.substring(0, termCols - 3)}...'
          : titleStr;
      stdout.write('${CliOutput.cyan}$safeTitle${CliOutput.reset}\x1B[K\n');

      for (int i = 0; i < choices.length; i++) {
        final isSelected = i == selectedIndex;
        final rawText = displayItem(choices[i]);
        final maxLen = termCols > 10 ? termCols - 4 : 76;
        final safeText = rawText.length > maxLen && maxLen > 10
            ? '${rawText.substring(0, maxLen - 3)}...'
            : rawText;

        final prefix = isSelected ? '${CliOutput.green}${CliOutput.bold}❯ ' : '  ';
        final formattedText = isSelected
            ? '${CliOutput.green}${CliOutput.bold}$safeText${CliOutput.reset}'
            : safeText;
        stdout.write('\x1B[1G\x1B[2K$prefix$formattedText\n');
      }
    }

    try {
      stdin.echoMode = false;
      stdin.lineMode = false;

      renderMenu(isFirst: true);

      while (true) {
        final byte = stdin.readByteSync();

        if (byte == 10 || byte == 13) {
          // Enter key confirmed
          break;
        } else if (byte == 27) {
          // ESC sequence
          final b2 = stdin.readByteSync();
          if (b2 == 91) {
            final b3 = stdin.readByteSync();
            if (b3 == 65) {
              // Up arrow
              selectedIndex = (selectedIndex - 1 + choices.length) % choices.length;
              renderMenu();
            } else if (b3 == 66) {
              // Down arrow
              selectedIndex = (selectedIndex + 1) % choices.length;
              renderMenu();
            }
          }
        }
      }
    } catch (_) {
      // Fallback if raw mode read throws
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
      defaultIndex: options.length > 1 ? 1 : 0,
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

  /// Prompts user to select a tunnel provider from available discovered options.
  static TunnelProvider selectTunnelProvider(List<TunnelProvider> availableProviders) {
    if (availableProviders.length <= 1) return TunnelProvider.none;

    return selectFromList<TunnelProvider>(
      title: 'Select Public Tunnel Service:',
      choices: availableProviders,
      displayItem: (provider) => provider.displayName,
      defaultIndex: 0,
    );
  }

  /// Listens for terminal keypresses after a build completes or fails.
  /// Returns [RebuildAction.rebuildSameConfig] for 'r' / 'Ctrl+r',
  /// or [RebuildAction.restartConfig] for 'c'.
  static Future<RebuildAction> listenForRebuildAction() async {
    CliOutput.printRebuildPrompt();

    try {
      if (!stdin.hasTerminal) {
        return _listenForRebuildActionFallback();
      }
    } catch (_) {
      return _listenForRebuildActionFallback();
    }

    bool originalEcho = true;
    bool originalLine = true;

    try {
      originalEcho = stdin.echoMode;
      originalLine = stdin.lineMode;
    } catch (_) {}

    try {
      stdin.echoMode = false;
      stdin.lineMode = false;

      while (true) {
        final byte = stdin.readByteSync();

        if (byte == 114 || byte == 82 || byte == 18) {
          // 'r', 'R', or Ctrl+R
          print('');
          return RebuildAction.rebuildSameConfig;
        } else if (byte == 99 || byte == 67) {
          // 'c' or 'C'
          print('');
          return RebuildAction.restartConfig;
        } else if (byte == 3) {
          // Ctrl+C
          print('\nShutting down FLANB...');
          exit(0);
        }
      }
    } catch (_) {
      return _listenForRebuildActionFallback();
    } finally {
      try {
        stdin.lineMode = originalLine;
        stdin.echoMode = originalEcho;
      } catch (_) {}
    }
  }

  static RebuildAction _listenForRebuildActionFallback() {
    stdout.write('${CliOutput.cyan}Enter choice [r=rebuild, c=change config]: ${CliOutput.reset}');
    final input = stdin.readLineSync()?.trim().toLowerCase();
    if (input == 'c' || input == 'change') {
      return RebuildAction.restartConfig;
    }
    return RebuildAction.rebuildSameConfig;
  }
}

enum RebuildAction {
  rebuildSameConfig,
  restartConfig,
}
