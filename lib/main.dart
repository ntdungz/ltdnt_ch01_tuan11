// Điểm vào Flutter: đọc cấu hình .env, chọn Repository qua Factory và cài
// 3 lớp bắt lỗi toàn cục, tất cả đổ về MỘT ErrorHandler (pipeline tập trung):
//
//   1. FlutterError.onError        -> lỗi trong framework (build, layout, callback)
//   2. PlatformDispatcher.onError  -> lỗi bất đồng bộ không được bắt
//   3. runZonedGuarded             -> lưới cuối cùng cho lỗi còn sót trong zone
//   + ErrorWidget.builder          -> giao diện dự phòng thay "màn hình đỏ"
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/errors/error_handler.dart';
import 'core/logger/app_logger.dart';
import 'data/repositories/repository_factory.dart';
import 'presentation/student_list_page.dart';
import 'presentation/widgets/error_boundary.dart';
import 'presentation/widgets/fallback_error_widget.dart';

// Binding và runApp cùng zone để tránh lỗi khác zone khi Flutter khởi động.
void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      ErrorHandler.report(details.exception, details.stack,
          source: 'FlutterError', fatal: true);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      ErrorHandler.report(error, stack,
          source: 'PlatformDispatcher', fatal: true);
      return true;
    };
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return FallbackErrorWidget(details: details);
    };
    _configureRepository();
    runApp(const StudentApp());
  }, (Object error, StackTrace stack) {
    ErrorHandler.report(error, stack, source: 'runZonedGuarded', fatal: true);
  });
}

// Đọc .env; DATA_SOURCE sai thì ghi lỗi cấu hình và quay về kho bộ nhớ.
void _configureRepository() {
  const AppConfig config = AppConfig.fromEnvironment();
  AppLogger.info('Khởi động với $config');
  try {
    RepositoryFactory.configure(config);
  } catch (error, stackTrace) {
    ErrorHandler.report(error, stackTrace,
        source: 'AppConfig', notifyUi: false);
    RepositoryFactory.use(RepositoryType.memory);
  }
}

// Theme dùng Material có sẵn, không cần thêm package giao diện.
class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  // Key toàn cục để ErrorBoundary hiện SnackBar từ bất kỳ đâu.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý sinh viên',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F8C)),
        scaffoldBackgroundColor: const Color(0xFFF3F7F8),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // Error boundary bọc toàn bộ cây widget của ứng dụng.
      builder: (BuildContext context, Widget? child) {
        return ErrorBoundary(
          messengerKey: messengerKey,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const StudentListPage(),
    );
  }
}
