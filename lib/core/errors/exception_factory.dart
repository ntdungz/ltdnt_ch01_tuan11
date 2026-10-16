import 'dart:async';

import 'app_exception.dart';

/// Y nghia cua StateError tai noi phat sinh.
/// Cung la StateError nhung co the la "khong tim thay" hoac "trung ma",
/// nen noi goi phai cho biet, factory khong tu doan.
enum StateErrorKind { notFound, duplicate }

/// Factory Pattern: nhan mot loi bat ky va quyet dinh tao AppException nao.
/// Noi goi khong can biet lop con cu the, chi nhan ve mot AppException.
class ExceptionFactory {
  /// Constructor private: lop chi chua ham static, khong can tao doi tuong.
  const ExceptionFactory._();

  static AppException create(
    Object error, {
    StateErrorKind? stateErrorKind,
  }) {
    return switch (error) {
      // Da la loi cua ung dung thi giu nguyen, tranh boc hai lan.
      AppException e => e,
      ArgumentError e => ValidationException(
          '${e.message}',
          field: e.name,
          cause: e,
        ),
      StateError e when stateErrorKind == StateErrorKind.notFound =>
        NotFoundException(e.message, cause: e),
      StateError e when stateErrorKind == StateErrorKind.duplicate =>
        DuplicateException(e.message, cause: e),
      FormatException e => DataFormatException(e.message, cause: e),
      TimeoutException e => NetworkException(
          e.message ?? 'Het thoi gian cho mang.',
          cause: e,
        ),
      // StateError khong ro y nghia va moi loi khac: chua phan loai duoc.
      _ => UnknownException(error.toString(), cause: error),
    };
  }
}