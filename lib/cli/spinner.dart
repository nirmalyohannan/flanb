import 'dart:async';
import 'dart:io';
import 'output.dart';

class TerminalSpinner {
  static const List<String> _frames = [
    '⠋',
    '⠙',
    '⠹',
    '⠸',
    '⠼',
    '⠴',
    '⠦',
    '⠧',
    '⠇',
    '⠏',
  ];

  Timer? _timer;
  int _frameIndex = 0;
  final String message;

  TerminalSpinner({required this.message});

  /// Starts the rotating spinner animation on stdout.
  void start() {
    try {
      stdout.write('\x1B[?25l'); // Hide terminal cursor
    } catch (_) {}

    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      final frame = _frames[_frameIndex % _frames.length];
      _frameIndex++;
      try {
        stdout.write('\r${CliOutput.cyan}$frame $message${CliOutput.reset}\x1B[K');
      } catch (_) {}
    });
  }

  /// Stops the spinner animation and restores terminal cursor.
  void stop() {
    _timer?.cancel();
    _timer = null;
    try {
      stdout.write('\r\x1B[K\x1B[?25h'); // Clear line and show cursor
    } catch (_) {}
  }
}
