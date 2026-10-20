# Chủ đề 01 - OOP nâng cao và xử lý ngoại lệ tập trung trong Dart

Ứng dụng Flutter quản lý sinh viên, dùng để minh họa OOP nâng cao, Repository Pattern, Factory Pattern và luồng xử lý ngoại lệ tập trung trong môn Dart & Flutter.

Đây là dự án Flutter dành cho **Android**. Thư mục `lib/` sử dụng bản mã nguồn nâng cấp; dự án không cần Firebase hoặc database để chạy demo mặc định.

## 1. Chức năng

- Xem danh sách và chi tiết sinh viên; thêm, sửa, xóa và tìm kiếm theo tên/MSSV.
- Kiểm tra MSSV, họ tên, email và GPA theo thang 4.
- Chuyển giữa hai nguồn dữ liệu: bộ nhớ RAM và Remote API.
- Chạy các tình huống lỗi, xem thông báo và nhật ký ngay trong ứng dụng.
- Giả lập mất mạng để minh họa chuẩn hóa lỗi và phục hồi thao tác.

## 2. Môi trường

Môi trường dùng để kiểm tra bản dự án này:

| Thành phần | Phiên bản/cấu hình |
| --- | --- |
| Flutter | 3.47.7 stable |
| Dart | 3.13.5, đi kèm Flutter |
| Android Gradle Plugin | 9.1.0 |
| Gradle wrapper | 9.3.1 |
| Kotlin Gradle Plugin | 2.4.0 |
| Java khi build trên máy chuẩn bị | JBR 25.0.3 đi kèm Android Studio |
| Java/Kotlin compilation target | 17 |

Cài Flutter SDK và Android Studio kèm Android SDK, command-line tools, build-tools theo kết quả `flutter doctor -v`. Nên dùng cùng phiên bản Flutter ở trên khi tái hiện bản demo. Dự án có Gradle wrapper, không cần cài Gradle riêng.

Kiểm tra môi trường và chấp nhận Android SDK licenses nếu chưa thực hiện:

```powershell
flutter --version
flutter doctor -v
flutter doctor --android-licenses
```

Để chạy app cần điện thoại Android bật Developer options/USB debugging và cấp quyền kết nối máy tính, hoặc Android Emulator đã khởi động. Nếu chỉ build APK thì không cần kết nối thiết bị.

## 3. Cài đặt và chạy

Tải/clone repository, mở terminal tại thư mục chứa `pubspec.yaml`:

```powershell
flutter pub get
flutter devices
flutter run -d <device-id>
```

Thay `<device-id>` bằng ID thiết bị Android trong kết quả `flutter devices`. Nếu chỉ có một thiết bị Android, có thể dùng `flutter run`.

Lần build đầu cần Internet để tải dependency và thành phần Android còn thiếu. Không cần chạy `flutter create`: cấu hình Android đã nằm trong repository. Các file cục bộ như `android/local.properties` được Flutter tạo khi build.

Ứng dụng mặc định dùng kho RAM, khởi tạo 5 sinh viên mẫu và tắt giả lập mất mạng. Chế độ này không cần Internet khi sử dụng app sau khi cài.

### Dùng Flutter từ Puro trên Windows

Nếu `flutter` chưa có trong PATH hoặc lệnh `puro` không hoạt động, có thể gọi trực tiếp Flutter đã cài trong môi trường `stable`:

```powershell
$flutterBin = Join-Path $env:USERPROFILE '.puro\envs\stable\flutter\bin\flutter.bat'
& $flutterBin pub get
& $flutterBin run -d <device-id>
```

Cách gọi này chỉ áp dụng khi môi trường Puro `stable` đã tồn tại. Với SDK đặt ở nơi khác, thay đường dẫn tương ứng.

## 4. Cấu hình môi trường

Dự án dùng `String.fromEnvironment`, `int.fromEnvironment` và `bool.fromEnvironment`. Flutter nhận các giá trị **lúc biên dịch**, không đọc file `.env` trực tiếp khi app đang chạy. Không cần thêm thư viện dotenv.

Tạo cấu hình cục bộ từ file mẫu:

```powershell
Copy-Item .env.example .env
flutter run -d <device-id> --dart-define-from-file=.env
```

Nội dung mẫu:

```dotenv
DATA_SOURCE=memory
API_BASE_URL=https://dummyjson.com
API_TIMEOUT_SECONDS=10
SIMULATE_OFFLINE=false
```

| Biến | Giá trị mặc định | Ý nghĩa |
| --- | --- | --- |
| `DATA_SOURCE` | `memory` | `memory`: kho RAM; `remote`: gọi API |
| `API_BASE_URL` | `https://dummyjson.com` | URL gốc của API có cấu trúc tương thích DummyJSON users |
| `API_TIMEOUT_SECONDS` | `10` | Thời gian timeout cho từng giai đoạn request, tính bằng giây; nên đặt số nguyên dương |
| `SIMULATE_OFFLINE` | `false` | `true`: bật giả lập mất mạng; `false`: tắt |

Không truyền file cấu hình thì app dùng các giá trị mặc định trong `AppConfig`. Sau khi sửa `.env`, dừng app và chạy lại bằng lệnh có `--dart-define-from-file=.env` để áp dụng cấu hình mới. `.env.example` được đưa lên Git; `.env` cục bộ được bỏ qua.

Ví dụ chạy Remote API không cần tạo `.env`:

```powershell
flutter run -d <device-id> --dart-define=DATA_SOURCE=remote
```

App cũng có menu **Đổi nguồn dữ liệu** để chuyển RAM/Remote khi đang chạy. Android release đã khai báo quyền `INTERNET`; Remote API cần kết nối Internet thật.

## 5. Build APK và cài trên điện thoại

Build bản mặc định, dùng RAM:

```powershell
flutter build apk --release
```

Hoặc build với cấu hình riêng:

```powershell
flutter build apk --release --dart-define-from-file=.env
```

APK được tạo tại:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Chép APK sang điện thoại Android và mở file để cài; cấp quyền cài ứng dụng từ nguồn tương ứng nếu điện thoại yêu cầu. Cũng có thể cài qua USB bằng Android Platform Tools:

```powershell
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Bản release hiện dùng debug signing của Flutter template để phục vụ bài demo, chưa cấu hình khóa phát hành lên Google Play.

## 6. Cấu trúc mã nguồn và nội dung chủ đề

```text
lib/
  core/
    config/       AppConfig, cấu hình lúc biên dịch
    errors/       AppException, ExceptionFactory, ErrorHandler
    logger/       AppLogger, LogLevel, Loggable
    mixins/       Validatable
    network/      NetworkSimulator dùng chung
    result/       Result<T>, Success<T>, Failure<T>
  domain/
    entities/     Entity<ID>, Student và quy tắc kiểm tra dữ liệu
    repositories/ Repository<T, ID>, StudentRepository
  data/
    models/       StudentModel, chuyển đổi JSON/API
    repositories/ Kho RAM, Remote API, Factory, chuẩn hóa lỗi repository
  presentation/
    widgets/      ErrorBoundary, FallbackErrorWidget
    ...           Danh sách, form, demo ngoại lệ, nhật ký
  main.dart       Khởi tạo, chọn Repository và đăng ký xử lý lỗi toàn cục
android/          Cấu hình và tài nguyên Android
test/             Unit test và widget test
.env.example      Cấu hình mẫu
```

| Nội dung | Đoạn mã chính |
| --- | --- |
| Factory/named constructor | [Student](lib/domain/entities/student.dart), [StudentModel](lib/data/models/student_model.dart), [AppConfig](lib/core/config/app_config.dart) |
| Mixins | [Validatable](lib/core/mixins/validatable.dart), [Loggable](lib/core/logger/loggable.dart), [RepositoryErrorMapper](lib/data/repositories/repository_error_mapper.dart) |
| Generics | [Repository](lib/domain/repositories/repository.dart), [Result](lib/core/result/result.dart), `ErrorHandler.guard<T>()` |
| Domain Layer riêng | [domain](lib/domain), không import Flutter hay lớp triển khai ở Data |
| Repository Pattern | [StudentRepository](lib/domain/repositories/student_repository.dart) và hai lớp triển khai trong Data |
| Factory Pattern | [RepositoryFactory](lib/data/repositories/repository_factory.dart) |
| Custom exceptions | [AppException và các lớp con](lib/core/errors/app_exception.dart) |
| `try/catch/finally`, `rethrow` | `StudentRepositoryImpl.add()`, `RemoteStudentRepository._send()` |
| Pipeline tập trung | [ExceptionFactory](lib/core/errors/exception_factory.dart), [ErrorHandler](lib/core/errors/error_handler.dart), [AppLogger](lib/core/logger/app_logger.dart) |
| Error boundary và lỗi toàn cục | [ErrorBoundary](lib/presentation/widgets/error_boundary.dart), [FallbackErrorWidget](lib/presentation/widgets/fallback_error_widget.dart), [main.dart](lib/main.dart) |

Luồng thao tác thông thường:

```text
UI -> ErrorHandler.guard<T> -> StudentRepository (interface)
                              -> Kho RAM hoặc Remote API do Factory chọn
Thành công -> Success<T> -> UI cập nhật
Thất bại  -> chuẩn hóa AppException -> ErrorHandler.report
          -> ghi log + phát ErrorEvent -> ErrorBoundary hiện SnackBar
          -> Failure<T> trả về tầng gọi
```

`FlutterError.onError`, `PlatformDispatcher.instance.onError` và `runZonedGuarded` cũng chuyển lỗi về `ErrorHandler.report()`. `ErrorWidget.builder` tạo giao diện dự phòng cho widget dựng thất bại. Pipeline ghi nhận và hiển thị lỗi; không tự khôi phục toàn bộ trạng thái ứng dụng sau mọi lỗi lập trình.

## 7. Kịch bản live demo

Chọn **Bộ nhớ (RAM)** để demo nghiệp vụ và các lỗi trùng MSSV một cách ổn định.

1. Mở app, xem 5 sinh viên mẫu; chạm vào một sinh viên để xem chi tiết.
2. Thêm sinh viên hợp lệ, thử sửa, tìm theo tên/MSSV và xóa có xác nhận.
3. Mở **Demo ngoại lệ**, lần lượt thử không tìm thấy, dữ liệu sai và trùng MSSV.
4. Bật giả lập mất mạng, xem thông báo; nhấn lại cùng nút để tắt và thử tải lại.
5. Thử lỗi ép kiểu, mở nhật ký và giải thích lỗi đã được chuyển thành `UnknownException`.
6. Trên app chạy thật, thử lỗi bất đồng bộ không được bắt và widget lỗi khi dựng; xem log và giao diện dự phòng. Nhấn lại nút widget lỗi để ẩn widget đó.
7. Nếu có Internet, chuyển Remote API để minh họa Factory thay nguồn dữ liệu mà vẫn dùng cùng giao diện.

Trạng thái giả lập mất mạng dùng chung cho các trang. Cần tắt bằng nút số 4 trước khi quay về danh sách để tải dữ liệu bình thường. Trong debug, IDE có thể dừng tại lỗi cố ý nếu bật tùy chọn break on exceptions; dùng Continue hoặc chạy `flutter run --release` khi demo trên thiết bị.

## 8. Kiểm tra

```powershell
flutter analyze
flutter test
flutter build apk --release
```

Test gồm kiểm tra JSON/model, validation, CRUD kho RAM, không tái sử dụng ID, giả lập mất mạng, phân loại thông báo/log và luồng giao diện thêm sinh viên, xem lỗi, xem/xóa nhật ký. Test không gọi API công khai và không thay thế việc live demo lỗi toàn cục trên thiết bị thật.

Kết quả kiểm tra khi chuẩn bị bản nộp:

| Kiểm tra | Kết quả |
| --- | --- |
| `flutter analyze` | Không có vấn đề |
| `flutter test --reporter expanded` | 23/23 test thành công |
| `flutter build apk --release --dart-define-from-file=.env.example` | Build thành công, APK khoảng 48 MB |
| Đối chiếu thư mục `lib/` | 25/25 file khớp từng byte với bản lib nâng cấp dùng để chuẩn bị gói |

Đây là kết quả phân tích, test và build trên máy chuẩn bị; vẫn cần chạy live demo trên điện thoại hoặc máy ảo khi báo cáo.

## 9. Giới hạn hiện tại

- Kho RAM chỉ giữ dữ liệu trong tiến trình đang chạy. Khi tiến trình kết thúc, dữ liệu thay đổi và nhật ký mất; lần khởi động mới tạo lại 5 sinh viên mẫu.
- DummyJSON chỉ giả lập thêm/sửa/xóa, không lưu thay đổi bền vững. Tải lại danh sách sau thao tác có thể vẫn thấy dữ liệu gốc. Kịch bản trùng MSSV nên chạy với kho RAM vì Remote API không thực thi cùng quy tắc này.
- Nhật ký giữ tối đa 200 bản ghi trong RAM và đồng thời in ra console, chưa ghi file hoặc gửi lên máy chủ.
- Remote dùng `dart:io`, nên bản này chưa hỗ trợ Flutter Web. Cấu hình nền tảng được bàn giao là Android.
- Chưa có SQLite, lưu trữ lâu dài, xác thực hay DI container. Các phụ thuộc hiện được truyền qua constructor và ghép tại Factory.

## 10. Thành viên và phân công

Trước khi nộp, điền tên/MSSV của hai thành viên và điều chỉnh bảng dưới đây theo công việc thực tế. Đây là bảng chờ hoàn thiện thông tin, không phải xác nhận phân công đã thực hiện.

| Thành viên | Họ tên, MSSV | Phần việc thực tế |
| --- | --- | --- |
| Thành viên 1 | Chưa điền | Chưa điền |
| Thành viên 2 | Chưa điền | Chưa điền |

Nhóm cần có bảng WBS rõ nhiệm vụ và người phụ trách, cùng lịch sử commit thể hiện đúng đóng góp của từng thành viên theo đề bài.

Slide thuyết trình là sản phẩm bàn giao riêng; có thể bổ sung vào `docs/` nếu muốn lưu chung repository. APK có thể đính kèm trong GitHub Releases; không cần đưa `build/` lên Git.

## 11. Tài liệu tham khảo

- [Dart language](https://dart.dev/language)
- [Flutter documentation](https://docs.flutter.dev/)
- [DummyJSON Users API](https://dummyjson.com/docs/users)
