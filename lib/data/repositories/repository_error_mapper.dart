// Ánh xạ lỗi tại Repository: mọi lỗi "thô" thoát ra từ Repository
// (SocketException, TimeoutException, FormatException, TypeError...) đều được
// đổi thành AppException trước khi lên tầng trên.
//
// MIXIN có ràng buộc `on Loggable`: chỉ lớp đã có Loggable mới dùng được,
// vì mixin này gọi lại logInfo của Loggable.
import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_factory.dart';
import '../../core/logger/loggable.dart';

mixin RepositoryErrorMapper on Loggable {
  // GENERIC METHOD: dùng cho mọi kiểu trả về (List<Student>, Student, void...).
  Future<T> mapErrors<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      final AppException mapped = ExceptionFactory.from(error, stackTrace);
      if (!identical(mapped, error)) {
        logInfo('$operation: chuyển ${error.runtimeType} thành ${mapped.code}');
      }
      // Ném lỗi đã chuẩn hoá nhưng GIỮ stack trace gốc để dễ truy vết.
      Error.throwWithStackTrace(mapped, stackTrace);
    }
  }
}
