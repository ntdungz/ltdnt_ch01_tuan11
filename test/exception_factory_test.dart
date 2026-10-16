import 'dart:async';

import 'package:ltdnt_ch01_tuan11/core/errors/app_exception.dart';
import 'package:ltdnt_ch01_tuan11/core/errors/exception_factory.dart';
import 'package:test/test.dart';

void main() {
  test('ArgumentError thanh ValidationException va giu ten truong', () {
    final error = ArgumentError.value('abc', 'email', 'Email khong hop le.');
    expect(
      ExceptionFactory.create(error),
      isA<ValidationException>().having((e) => e.field, 'field', 'email'),
    );
  });

  test('StateError duoc phan loai theo noi phat sinh', () {
    final error = StateError('Loi trang thai');
    expect(
      ExceptionFactory.create(error, stateErrorKind: StateErrorKind.notFound),
      isA<NotFoundException>(),
    );
    expect(
      ExceptionFactory.create(error, stateErrorKind: StateErrorKind.duplicate),
      isA<DuplicateException>(),
    );
    expect(ExceptionFactory.create(error), isA<UnknownException>());
  });

  test('FormatException thanh DataFormatException', () {
    expect(
      ExceptionFactory.create(const FormatException('JSON sai')),
      isA<DataFormatException>(),
    );
  });

  test('TimeoutException thanh NetworkException', () {
    expect(
      ExceptionFactory.create(TimeoutException('Het gio')),
      isA<NetworkException>(),
    );
  });

  test('AppException duoc giu nguyen', () {
    const original = NotFoundException('Khong co SV999');
    expect(identical(ExceptionFactory.create(original), original), isTrue);
  });

  test('giu loi goc trong cause', () {
    const error = FormatException('sai');
    expect(ExceptionFactory.create(error).cause, same(error));
  });
}