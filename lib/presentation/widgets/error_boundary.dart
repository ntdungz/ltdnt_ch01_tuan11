// ERROR BOUNDARY cấp ứng dụng: lắng nghe ErrorHandler.events và hiện SnackBar
// cho MỌI lỗi, kể cả lỗi từ hook toàn cục trong main.dart. Nhờ vậy các trang
// không phải tự viết try/catch rồi tự hiện SnackBar nữa.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/errors/error_handler.dart';
import '../../core/logger/app_logger.dart';

class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    super.key,
    required this.messengerKey,
    required this.child,
  });

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  StreamSubscription<ErrorEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ErrorHandler.events.listen(_onError);
  }

  void _onError(ErrorEvent event) {
    // Nếu lỗi xảy ra giữa lúc đang dựng giao diện thì đợi khung hình xong mới hiện.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _show(event);
      });
    } else {
      _show(event);
    }
  }

  void _show(ErrorEvent event) {
    final ScaffoldMessengerState? messenger = widget.messengerKey.currentState;
    if (messenger == null || !mounted) {
      return;
    }
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        backgroundColor: _colorFor(event.level),
        content: Text(event.message),
      ));
  }

  Color _colorFor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return Colors.teal.shade700;
      case LogLevel.warning:
        return Colors.orange.shade800;
      case LogLevel.error:
        return Colors.red.shade700;
      case LogLevel.fatal:
        return Colors.red.shade900;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
