// Lưu nhật ký cho Exception pipeline: ghi ra console và giữ 200 bản ghi trong bộ nhớ.

// Mức log dùng enhanced enum (enum có field và constructor) thay cho chuỗi.
enum LogLevel {
  info('INFO'),
  warning('WARNING'),
  error('ERROR'),
  fatal('FATAL');

  const LogLevel(this.label);

  final String label;

  bool isAtLeast(LogLevel other) => index >= other.index;
}

// Một bản ghi gom thông tin cần xem khi giải thích hoặc truy tìm lỗi.
class AppLog {
  final DateTime time;
  final LogLevel level;
  final String message;
  final String stackTrace;

  AppLog(this.time, this.level, this.message, this.stackTrace);

  // FACTORY CONSTRUCTOR: tạo bản ghi tại thời điểm hiện tại, chuẩn hoá stack trace.
  factory AppLog.now(LogLevel level, String message, StackTrace? stackTrace) {
    return AppLog(
        DateTime.now(), level, message, stackTrace?.toString() ?? '');
  }

  String format() {
    return '${time.toIso8601String()} [${level.label}] $message';
  }
}

// Bộ nhớ static giúp mọi trang cùng đọc một nhật ký, tối đa 200 bản ghi.
class AppLogger {
  static const int maxLogs = 200;
  static final List<AppLog> _logs = <AppLog>[];

  static void info(String message) {
    log(LogLevel.info, message);
  }

  static void warning(String message, [StackTrace? stackTrace]) {
    log(LogLevel.warning, message, stackTrace);
  }

  static void error(String message, [StackTrace? stackTrace]) {
    log(LogLevel.error, message, stackTrace);
  }

  static void fatal(String message, [StackTrace? stackTrace]) {
    log(LogLevel.fatal, message, stackTrace);
  }

  // Trả bản sao để bên ngoài không thể xóa hay thêm trực tiếp vào bộ nhớ log.
  static List<AppLog> getLogs() {
    return List<AppLog>.of(_logs);
  }

  static void clear() {
    _logs.clear();
  }

  // Chỉ một hàm ghi log để giới hạn dung lượng và định dạng nhất quán.
  static void log(LogLevel level, String message, [StackTrace? stackTrace]) {
    final AppLog entry = AppLog.now(level, message, stackTrace);
    _logs.add(entry);
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }
    // In console là yêu cầu demo; nhật ký cũng được lưu để xem trên ứng dụng.
    // ignore: avoid_print
    print(entry.format());
    if (level.isAtLeast(LogLevel.error) && entry.stackTrace.isNotEmpty) {
      // ignore: avoid_print
      print(entry.stackTrace.split('\n').take(8).join('\n'));
    }
  }
}
