// FACTORY PATTERN: nơi DUY NHẤT biết cách tạo Repository cụ thể.
// Phần còn lại của ứng dụng chỉ làm việc với interface StudentRepository.
// Đổi nguồn dữ liệu = đổi DATA_SOURCE trong .env (hoặc chọn trên giao diện),
// không phải sửa Domain hay UI.
import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/logger/app_logger.dart';
import '../../core/network/network_simulator.dart';
import '../../domain/repositories/student_repository.dart';
import 'remote_student_repository.dart';
import 'student_repository_impl.dart';

// Các loại Repository mà Factory tạo được (enhanced enum có nhãn hiển thị).
enum RepositoryType {
  memory('Bộ nhớ (RAM)'),
  remote('Remote API');

  const RepositoryType(this.label);

  final String label;

  // Đọc tên trong .env; tên lạ => ConfigException (custom exception).
  static RepositoryType parse(String name) {
    for (final RepositoryType type in RepositoryType.values) {
      if (type.name == name.trim().toLowerCase()) {
        return type;
      }
    }
    throw ConfigException('Không hỗ trợ kho dữ liệu $name.');
  }
}

class RepositoryFactory {
  RepositoryFactory._();

  // Công tắc giả lập mất mạng dùng chung cho mọi Repository.
  static final NetworkSimulator networkSimulator = NetworkSimulator();

  static AppConfig _config = const AppConfig.defaults();
  static RepositoryType _currentType = RepositoryType.memory;
  static StudentRepositoryImpl? _memory;
  static RemoteStudentRepository? _remote;

  // Gọi một lần trong main() với cấu hình đọc từ .env.
  static void configure(AppConfig config) {
    _config = config;
    _remote = null;
    networkSimulator.setOffline(config.simulateOffline);
    _currentType = RepositoryType.parse(config.dataSource);
    AppLogger.info('Factory dùng nguồn dữ liệu: ${_currentType.name}');
  }

  static RepositoryType get currentType => _currentType;

  // Repository đang được chọn; UI luôn lấy qua getter này.
  static StudentRepository get current => create(_currentType);

  // Đổi nguồn dữ liệu lúc ứng dụng đang chạy.
  static void use(RepositoryType type) {
    _currentType = type;
    AppLogger.info('Đổi nguồn dữ liệu sang: ${type.name}');
  }

  // FACTORY METHOD: trả về interface, ẩn lớp cụ thể.
  // Mỗi loại chỉ tạo một instance để các trang dùng chung dữ liệu.
  static StudentRepository create(RepositoryType type) {
    switch (type) {
      case RepositoryType.memory:
        return _memory ??=
            StudentRepositoryImpl(networkSimulator: networkSimulator);
      case RepositoryType.remote:
        return _remote ??= RemoteStudentRepository(
          baseUrl: _config.apiBaseUrl,
          timeout: _config.apiTimeout,
          networkSimulator: networkSimulator,
        );
    }
  }

  // Tạo theo tên (chuỗi trong .env); tên lạ => ConfigException.
  static StudentRepository createByName(String name) {
    return create(RepositoryType.parse(name));
  }
}
