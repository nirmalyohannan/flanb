import 'dart:async';

class LogManager {
  final List<String> _history = [];
  final StreamController<String> _controller = StreamController<String>.broadcast();

  List<String> get history => List.unmodifiable(_history);

  void addLog(String message) {
    _history.add(message);
    _controller.add(message);
  }

  /// Returns a stream formatted for Server-Sent Events (SSE).
  Stream<String> get sseStream async* {
    // Send existing history first
    for (final line in _history) {
      yield 'data: $line\n\n';
    }
    // Stream new logs
    yield* _controller.stream.map((line) => 'data: $line\n\n');
  }

  void dispose() {
    _controller.close();
  }
}
