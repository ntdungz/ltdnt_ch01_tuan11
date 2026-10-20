// Giả lập mất mạng dùng chung cho mọi Repository (bộ nhớ và Remote API).
// Khi bật, ném SocketException "thô" giống hệt lúc mất mạng thật, để
// ExceptionFactory phải chuẩn hoá nó thành NetworkException.
import 'dart:io';

import '../logger/loggable.dart';

class NetworkSimulator with Loggable {
  NetworkSimulator({bool offline = false}) : _offline = offline;

  bool _offline;

  bool get isOffline => _offline;

  void setOffline(bool value) {
    _offline = value;
    logInfo('Giả lập mất mạng: $value');
  }

  // Chờ như một request mạng, rồi ném lỗi nếu đang giả lập mất mạng.
  Future<void> ensureOnline(
      {Duration delay = const Duration(milliseconds: 500)}) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (_offline) {
      throw const SocketException('Giả lập: mất kết nối tới máy chủ');
    }
  }
}
