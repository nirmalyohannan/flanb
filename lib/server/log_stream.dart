import 'dart:async';
import 'dart:convert';

class LogManager {
  final List<String> _history = [];
  final StreamController<String> _controller = StreamController<String>.broadcast();

  List<String> get history => List.unmodifiable(_history);

  void addLog(String message) {
    _history.add(message);
    _controller.add(message);
  }

  /// Returns a byte stream (`Stream<List<int>>`) properly formatted for Server-Sent Events (SSE).
  Stream<List<int>> get sseByteStream async* {
    // Send existing history first
    for (final line in _history) {
      yield utf8.encode(_formatSseData(line));
    }

    // Stream incoming logs as byte chunks
    await for (final line in _controller.stream) {
      yield utf8.encode(_formatSseData(line));
    }
  }

  /// Formats a log line into valid SSE protocol data format.
  String _formatSseData(String line) {
    // Replace newlines inside a single line to prevent breaking SSE field boundaries
    final sanitized = line.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final sublines = sanitized.split('\n');
    final buffer = StringBuffer();
    for (final sub in sublines) {
      buffer.write('data: $sub\n');
    }
    buffer.write('\n');
    return buffer.toString();
  }

  void dispose() {
    _controller.close();
  }
}
