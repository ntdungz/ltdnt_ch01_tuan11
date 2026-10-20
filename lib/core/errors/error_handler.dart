// CENTRALIZED ERROR HANDLING PIPELINE
//
// Mọi lỗi trong ứng dụng - từ Repository, UI, FlutterError.onError,
// PlatformDispatcher.onError hay runZonedGuarded - đều đi qua `report()`:
//
//   (1) Chuẩn hoá  : ExceptionFactory.from(error)  -> AppException
//   (2) Ghi log    : AppLogger, mức log theo loại lỗi
//   (3) Thông báo  : chọn câu tiếng Việt thân thiện cho người dùng
//   (4) Báo UI     : phát ErrorEvent qua Stream -> ErrorBoundary hiện SnackBar
import 'dart:async';

import '../logger/app_logger.dart';
import '../result/result.dart';
import 'app_exception.dart';
import 'exception_factory.dart';

// Sự kiện lỗi gửi cho tầng giao diện.
class ErrorEvent {
  const ErrorEvent({
    required this.exception,
    required this.message,
    required this.source,
    required this.level,
  });

  final AppException exception;
  final String message;
  final String source;
  final LogLevel level;
}

// Exception thường biểu diễn sự cố dự kiến có thể xử lý (như dữ liệu sai).
// Error thường do lỗi lập trình; pipeline vẫn ghi nhận để ứng dụng không im lặng.
class ErrorHandler {
  ErrorHandler._();

  static final StreamController<ErrorEvent> _events =
      StreamController<ErrorEvent>.broadcast();

  // ErrorBoundary lắng nghe stream này để hiện SnackBar cho MỌI lỗi.
  static Stream<ErrorEvent> get events => _events.stream;

  // Giữ chữ ký cũ: trả về thông báo cho người dùng.
  static String handle(Object error, [StackTrace? stackTrace]) {
    return report(error, stackTrace);
  }

  // Điểm vào DUY NHẤT của pipeline.
  static String report(
    Object error,
    StackTrace? stackTrace, {
    String source = 'App',
    bool fatal = false,
    bool notifyUi = true,
  }) {
    // (1) Chuẩn hoá
    final AppException exception = ExceptionFactory.from(error, stackTrace);
    // (2) Ghi log - mỗi lỗi chỉ tạo đúng một bản ghi phân loại
    final LogLevel level = fatal ? LogLevel.fatal : _levelFor(exception);
    final Object? cause = exception.cause;
    final String origin =
        cause == null || identical(cause, exception) ? '' : ' | gốc: $cause';
    AppLogger.log(level, '[$source] $exception$origin',
        stackTrace ?? exception.stackTrace);
    // (3) Chọn thông báo
    final String message = messageFor(exception);
    // (4) Báo UI
    if (notifyUi) {
      _events.add(ErrorEvent(
        exception: exception, message: message, source: source, level: level));
    }
    return message;
  }

  // GENERIC METHOD: chạy một tác vụ bất đồng bộ, bắt lỗi tập trung, trả Result<T>.
  // UI chỉ cần gọi guard thay vì tự viết try/catch ở mọi nơi.
  static Future<Result<T>> guard<T>(
    Future<T> Function() action, {
    required String source,
    bool notifyUi = true,
  }) async {
    try {
      final T data = await action();
      return Result<T>.success(data);
    } catch (error, stackTrace) {
      final AppException exception = ExceptionFactory.from(error, stackTrace);
      report(exception, stackTrace, source: source, notifyUi: notifyUi);
      return Result<T>.failure(exception);
    }
  }

  // Lỗi người dùng tự sửa được là WARNING, còn lại là ERROR.
  static LogLevel _levelFor(AppException exception) {
    switch (exception) {
      case ValidationException():
      case NotFoundException():
      case DuplicateException():
        return LogLevel.warning;
      case NetworkException():
      case ServerException():
      case ConfigException():
      case UnknownException():
        return LogLevel.error;
    }
  }

  // switch trên sealed class: thiếu một loại lỗi là trình biên dịch báo ngay.
  static String messageFor(AppException exception) {
    switch (exception) {
      case ValidationException():
        return 'Dữ liệu chưa hợp lệ: ${exception.message}';
      case NotFoundException():
        return 'Không tìm thấy sinh viên. Vui lòng tải lại danh sách.';
      case DuplicateException():
        return 'Mã số sinh viên đã tồn tại. Vui lòng dùng mã khác.';
      case NetworkException():
        if (exception.code == 'TIMEOUT') {
          return 'Máy chủ phản hồi quá chậm. Vui lòng thử lại.';
        }
        return 'Không thể kết nối. Kiểm tra mạng hoặc tắt giả lập mất mạng rồi thử lại.';
      case ServerException():
        return 'Máy chủ gặp sự cố hoặc trả dữ liệu không hợp lệ. Vui lòng thử lại.';
      case ConfigException():
        return 'Cấu hình chưa đúng. Vui lòng kiểm tra file .env.';
      case UnknownException():
        return 'Đã xảy ra lỗi bất ngờ. Vui lòng thử lại hoặc xem nhật ký.';
    }
  }
}
