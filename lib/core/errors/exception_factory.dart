// ExceptionFactory: bước CHUẨN HOÁ của pipeline.
// Nhận bất kỳ thứ gì bị ném ra (Exception, Error, String...) và trả về
// đúng một lớp con AppException, để các tầng sau chỉ phải xử lý một kiểu lỗi.
import 'dart:async';
import 'dart:io';

import 'app_exception.dart';

class ExceptionFactory {
  // Constructor private: lớp chỉ chứa hàm static, không cần tạo đối tượng.
  const ExceptionFactory._();

  // Chuyển lỗi gốc thành exception của ứng dụng, giữ lại lỗi gốc trong `cause`.
  static AppException from(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }
    if (error is SocketException) {
      return NetworkException.noInternet(cause: error, stackTrace: stackTrace);
    }
    if (error is TimeoutException) {
      return NetworkException.timeout(cause: error, stackTrace: stackTrace);
    }
    if (error is HttpException) {
      return NetworkException('Lỗi giao thức HTTP: ${error.message}',
          cause: error, stackTrace: stackTrace);
    }
    if (error is FormatException) {
      return ServerException.badResponse('Dữ liệu trả về không hợp lệ ($error)',
          cause: error, stackTrace: stackTrace);
    }
    return UnknownException(error.toString(),
        cause: error, stackTrace: stackTrace);
  }

  // Chọn đúng lớp con theo mã trạng thái HTTP khi gọi API.
  static AppException fromHttpStatus(int statusCode, String url) {
    final String detail = 'HTTP $statusCode - $url';
    switch (statusCode) {
      case 400:
      case 422:
        return ValidationException('Yêu cầu không hợp lệ ($detail).');
      case 404:
        return NotFoundException('Không tìm thấy dữ liệu ($detail).');
      case 408:
      case 504:
        return const NetworkException.timeout();
      default:
        return ServerException('Máy chủ báo lỗi ($detail).',
            statusCode: statusCode);
    }
  }
}
