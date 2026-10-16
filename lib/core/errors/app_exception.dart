/// Lop cha cua moi loi trong ung dung.
///
/// `sealed`: cac lop con bat buoc nam trong file nay, nen khi dung `switch`
/// tren AppException, Dart kiem tra giup da xu ly du moi loai loi chua.
/// `implements Exception`: day la loi nghiep vu can bat va bao nguoi dung,
/// khac voi `Error` la loi lap trinh.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Thong diep ky thuat, dung de ghi log.
  final String message;

  /// Loi goc truoc khi chuyen doi (ArgumentError, StateError, ...).
  final Object? cause;

  /// Ma loi ngan gon, dung khi ghi log va kiem thu.
  String get code;

  /// Thong diep than thien hien tren giao dien.
  String get userMessage;

  @override
  String toString() => '$runtimeType($code): $message';
}

/// Du lieu sai quy tac nghiep vu: email sai, ten trong, GPA ngoai [0, 4].
class ValidationException extends AppException {
  const ValidationException(super.message, {this.field, super.cause});

  /// Ten truong bi loi, vi du `email` hoac `gpa`.
  final String? field;

  @override
  String get code => 'VALIDATION';

  @override
  String get userMessage => 'Dữ liệu không hợp lệ: $message';
}

/// Khong tim thay ban ghi can doc, sua hoac xoa.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause});

  @override
  String get code => 'NOT_FOUND';

  @override
  String get userMessage => 'Không tìm thấy dữ liệu yêu cầu.';
}

/// Them ban ghi co ma da ton tai.
class DuplicateException extends AppException {
  const DuplicateException(super.message, {super.cause});

  @override
  String get code => 'DUPLICATE';

  @override
  String get userMessage => 'Mã sinh viên đã tồn tại.';
}

/// JSON thieu truong hoac sai kieu du lieu.
class DataFormatException extends AppException {
  const DataFormatException(super.message, {super.cause});

  @override
  String get code => 'DATA_FORMAT';

  @override
  String get userMessage => 'Dữ liệu nhận được bị sai định dạng.';
}

/// Mat ket noi hoac het thoi gian cho mang.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});

  @override
  String get code => 'NETWORK';

  @override
  String get userMessage => 'Không có kết nối mạng. Vui lòng thử lại.';
}

/// Loi chua phan loai duoc, thuong la loi lap trinh.
class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause});

  @override
  String get code => 'UNKNOWN';

  @override
  String get userMessage => 'Đã xảy ra lỗi không mong muốn.';
}