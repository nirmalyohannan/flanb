import 'dart:io';
import '../build/build_config.dart';
import 'output.dart';

class Prompts {
  /// Prompts the user to select an item from a list.
  /// If the terminal is non-interactive or choices is empty, returns [defaultIndex].
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
}
