// Kiểm thử phân loại lỗi, mức log, stack trace và giới hạn lưu trữ.
import 'package:flutter_test/flutter_test.dart';
import 'package:oop_error_demo/core/errors/app_exception.dart';
import 'package:oop_error_demo/core/errors/error_handler.dart';
import 'package:oop_error_demo/core/logger/app_logger.dart';

// Kiểm tra chung bảo đảm mỗi lỗi chỉ tạo một bản ghi phân loại tại handler.
void expectHandled(Object error, String message, LogLevel level) {
  final int before = AppLogger.getLogs().length;
  final StackTrace trace = StackTrace.current;
  final String result = ErrorHandler.handle(error, trace);
  expect(result, isNotEmpty);
  expect(result, contains(message));
  final List<AppLog> logs = AppLogger.getLogs();
  expect(logs.length, before + 1);
  expect(logs.last.level, level);
  expect(logs.last.stackTrace, trace.toString());
  expect(logs.last.message, contains(error.toString()));
}

void main() {
  setUp(() {
    AppLogger.clear();
  });

  test('ValidationException trả thông báo kèm chi tiết', () {
    expectHandled(ValidationException('Tên quá ngắn.'),
        'Dữ liệu chưa hợp lệ: Tên quá ngắn.', LogLevel.warning);
  });
  test('NotFoundException trả thông báo tải lại', () {
    expectHandled(
        NotFoundException('ID -1'),
        'Không tìm thấy sinh viên. Vui lòng tải lại danh sách.',
        LogLevel.warning);
  });
  test('DuplicateException trả thông báo đổi mã', () {
    expectHandled(DuplicateException('SV0001'),
        'Mã số sinh viên đã tồn tại. Vui lòng dùng mã khác.', LogLevel.warning);
  });
  test('NetworkException trả thông báo kết nối', () {
    expectHandled(
        NetworkException('Mất mạng'),
        'Không thể kết nối. Kiểm tra mạng hoặc tắt giả lập mất mạng rồi thử lại.',
        LogLevel.error);
  });
  test('ConfigException trả thông báo cấu hình không lộ chi tiết nội bộ', () {
    expectHandled(ConfigException('Chi tiết nội bộ'),
        'Cấu hình chưa đúng. Vui lòng kiểm tra file .env.', LogLevel.error);
  });
  test('Error cũng đi qua nhánh lỗi bất ngờ', () {
    expectHandled(
        StateError('Trạng thái sai'),
        'Đã xảy ra lỗi bất ngờ. Vui lòng thử lại hoặc xem nhật ký.',
        LogLevel.error);
  });
  test('FormatException được chuẩn hóa thành lỗi phản hồi máy chủ', () {
    expectHandled(
        const FormatException('Sai định dạng'),
        'Máy chủ gặp sự cố hoặc trả dữ liệu không hợp lệ. Vui lòng thử lại.',
        LogLevel.error);
  });
  test('handler hỗ trợ không truyền stack trace', () {
    ErrorHandler.handle(ValidationException('Sai'));
    expect(AppLogger.getLogs().single.stackTrace, '');
  });
  test('logger chỉ giữ 200 log mới nhất và trả bản sao', () {
    for (int i = 0; i < 205; i++) {
      AppLogger.info('Log $i');
    }
    final List<AppLog> logs = AppLogger.getLogs();
    expect(logs.length, 200);
    expect(logs.first.message, 'Log 5');
    expect(logs.last.message, 'Log 204');
    logs.clear();
    expect(AppLogger.getLogs().length, 200);
    AppLogger.clear();
    expect(AppLogger.getLogs(), isEmpty);
  });
}
