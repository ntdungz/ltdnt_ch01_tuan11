/// Muc do nghiem trong cua mot dong log.
enum LogLevel { info, warning, error }

/// Mot dong log: thoi diem, muc do, noi dung va loi goc (neu co).
class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime time;
  final LogLevel level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  /// Dinh dang: 23:31:05 [ERROR] noi dung | loi goc
  String format() {
    final clock = time.toIso8601String().substring(11, 19);
    final detail = error == null ? '' : ' | $error';
    return '$clock [${level.name.toUpperCase()}] $message$detail';
  }
}

/// Noi ghi log tap trung cua ung dung.
class AppLogger {
  AppLogger({void Function(String line)? output, this.maxEntries = 200})
      : _output = output ?? print;

  /// Noi in log ra, mac dinh la terminal. Test co the truyen ham khac vao.
  final void Function(String line) _output;

  /// So dong log toi da giu trong bo nho, tranh tran RAM.
  final int maxEntries;

  final List<LogEntry> _entries = [];
  final List<void Function(LogEntry entry)> _listeners = [];

  /// Ban sao chi doc, ben ngoai khong sua duoc danh sach log.
  List<LogEntry> get entries => List<LogEntry>.unmodifiable(_entries);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message, {Object? error}) =>
      _log(LogLevel.warning, message, error: error);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  /// Observer: dang ky nhan thong bao moi khi co log moi (giao dien dung).
  void addListener(void Function(LogEntry entry) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(LogEntry entry) listener) {
    _listeners.remove(listener);
  }

  void clear() {
    _entries.clear();
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      time: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
    _entries.add(entry);
    if (_entries.length > maxEntries) {
      _entries.removeAt(0);
    }
    _output(entry.format());
    for (final listener in List.of(_listeners)) {
      listener(entry);
    }
  }
}