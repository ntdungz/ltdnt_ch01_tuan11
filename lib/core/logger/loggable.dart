// MIXIN: lớp nào `with Loggable` cũng có sẵn hàm ghi log gắn tên lớp,
// không cần kế thừa từ một lớp cha chung.
import 'app_logger.dart';

mixin Loggable {
  String get logTag => runtimeType.toString();

  void logInfo(String message) {
    AppLogger.info('[$logTag] $message');
  }

  void logWarning(String message) {
    AppLogger.warning('[$logTag] $message');
  }
}
