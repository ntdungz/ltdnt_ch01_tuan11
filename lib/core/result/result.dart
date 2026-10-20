// GENERICS: kiểu kết quả thống nhất cho mọi thao tác có thể thất bại.
// Result<T> là một "hộp" chứa HOẶC dữ liệu kiểu T (Success) HOẶC lỗi (Failure).
// UI nhận Result thay vì phải tự viết try/catch ở mỗi màn hình.
import '../errors/app_exception.dart';

sealed class Result<T> {
  const Result();

  // Redirecting factory constructor: Result.success(x) tạo ra Success<T>.
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppException error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull {
    final Result<T> self = this;
    return self is Success<T> ? self.data : null;
  }

  AppException? get errorOrNull {
    final Result<T> self = this;
    return self is Failure<T> ? self.error : null;
  }

  // Generic method: biến đổi dữ liệu bên trong sang kiểu R nếu thành công.
  Result<R> map<R>(R Function(T data) transform) {
    final Result<T> self = this;
    if (self is Success<T>) {
      return Result<R>.success(transform(self.data));
    }
    return Result<R>.failure((self as Failure<T>).error);
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}
