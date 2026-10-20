// Cấu hình đọc từ file .env thông qua cờ --dart-define-from-file=.env
// (tính năng có sẵn của Flutter, không cần thêm package).
//
//   flutter run --dart-define-from-file=.env
//
// Không truyền cờ (ví dụ khi chạy `flutter test`) thì dùng giá trị mặc định.
class AppConfig {
  const AppConfig({
    required this.dataSource,
    required this.apiBaseUrl,
    required this.apiTimeout,
    required this.simulateOffline,
  });

  // NAMED CONSTRUCTOR: đọc biến môi trường lúc biên dịch.
  const AppConfig.fromEnvironment()
      : dataSource =
            const String.fromEnvironment('DATA_SOURCE', defaultValue: 'memory'),
        apiBaseUrl = const String.fromEnvironment('API_BASE_URL',
            defaultValue: 'https://dummyjson.com'),
        apiTimeout = const Duration(
            seconds: int.fromEnvironment('API_TIMEOUT_SECONDS', defaultValue: 10)),
        simulateOffline = const bool.fromEnvironment('SIMULATE_OFFLINE');

  // NAMED CONSTRUCTOR: cấu hình mặc định, dùng cho test.
  const AppConfig.defaults()
      : dataSource = 'memory',
        apiBaseUrl = 'https://dummyjson.com',
        apiTimeout = const Duration(seconds: 10),
        simulateOffline = false;

  /// memory | remote - RepositoryFactory dựa vào giá trị này để chọn Repository.
  final String dataSource;
  final String apiBaseUrl;
  final Duration apiTimeout;
  final bool simulateOffline;

  @override
  String toString() {
    return 'AppConfig(dataSource: $dataSource, api: $apiBaseUrl, '
        'timeout: ${apiTimeout.inSeconds}s, offline: $simulateOffline)';
  }
}
