// Khai báo custom exceptions để pipeline nhận biết từng lỗi nghiệp vụ.
//
// `sealed` cho trình biên dịch biết TẤT CẢ lớp con nằm trong file này,
// nên `switch` trên AppException bắt buộc xử lý đủ mọi loại lỗi (exhaustive).
// Thêm một loại lỗi mới mà quên xử lý ở ErrorHandler thì sẽ không biên dịch được.

// Lớp cha giữ thông báo, mã lỗi và lỗi gốc; không phụ thuộc giao diện Flutter.
sealed class AppException implements Exception {
  const AppException(this.message, this.code, {this.cause, this.stackTrace});
  final String message;
  final String code;
  final Object? cause;
  final StackTrace? stackTrace;
  @override
  String toString() {
    return '$code: $message';
  }
}

// Lỗi dữ liệu đầu vào có thể được người dùng sửa ngay trên form.
final class ValidationException extends AppException {
  const ValidationException(String message, {super.cause, super.stackTrace})
      : super(message, 'VALIDATION');

  // NAMED CONSTRUCTOR: gom danh sách lỗi từ Validatable thành một exception.
  ValidationException.fromErrors(List<String> errors)
      : super(errors.join('\n'), 'VALIDATION');
}

// Phân biệt bản ghi không tồn tại với lỗi kết nối.
final class NotFoundException extends AppException {
  const NotFoundException(String message, {super.cause, super.stackTrace})
      : super(message, 'NOT_FOUND');

  // NAMED CONSTRUCTOR: thông báo chuẩn khi không có sinh viên theo ID.
  NotFoundException.student(int id) : super('Không có sinh viên ID $id.', 'NOT_FOUND');
}

// Dùng riêng cho trường hợp MSSV đã được sử dụng.
final class DuplicateException extends AppException {
  const DuplicateException(String message, {super.cause, super.stackTrace})
      : super(message, 'DUPLICATE');
}

// Sự cố kết nối: mất mạng thật, giả lập mất mạng hoặc quá thời gian chờ.
final class NetworkException extends AppException {
  const NetworkException(String message,
      {String code = 'NETWORK', super.cause, super.stackTrace})
      : super(message, code);

  // NAMED CONSTRUCTOR cho từng tình huống mạng cụ thể.
  const NetworkException.noInternet({super.cause, super.stackTrace})
      : super('Không có kết nối mạng.', 'NETWORK');

  const NetworkException.timeout({super.cause, super.stackTrace})
      : super('Yêu cầu quá thời gian chờ.', 'TIMEOUT');
}

// Máy chủ trả lỗi 5xx hoặc dữ liệu trả về sai định dạng.
final class ServerException extends AppException {
  const ServerException(String message,
      {this.statusCode, super.cause, super.stackTrace})
      : super(message, 'SERVER');

  // NAMED CONSTRUCTOR: dữ liệu nhận về không đọc được (JSON hỏng...).
  const ServerException.badResponse(String message,
      {super.cause, super.stackTrace})
      : statusCode = null,
        super(message, 'BAD_RESPONSE');

  final int? statusCode;
}

// Cấu hình sai, ví dụ DATA_SOURCE trong .env không được hỗ trợ.
final class ConfigException extends AppException {
  const ConfigException(String message, {super.cause, super.stackTrace})
      : super(message, 'CONFIG');
}

// Mọi lỗi chưa biết (thường là lỗi lập trình: TypeError, StateError...).
final class UnknownException extends AppException {
  const UnknownException(String message, {super.cause, super.stackTrace})
      : super(message, 'UNKNOWN');
}
