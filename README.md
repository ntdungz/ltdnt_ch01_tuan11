# Chủ đề 01 - OOP nâng cao và Design Patterns trong Dart

Phần thực hiện của **SV1**, dùng bài toán quản lý sinh viên để minh họa OOP,
Repository Pattern và Factory Pattern. Mã nguồn hiện tại là module **Dart thuần**,
chạy độc lập bằng terminal và có thể đưa vào ứng dụng Flutter khi ghép phần SV2.

## Phân công và phạm vi

Tài liệu phân công được gửi kèm xác định SV1 làm Domain/Repository, SV2 làm
pipeline xử lý lỗi. PDF đề cương quy định yêu cầu cho cả nhóm, không chia sẵn
từng file cho mỗi người. Dự án sử dụng cách chia dưới đây:

| Thành viên | Công việc | Trạng thái |
| --- | --- | --- |
| SV1 | Entity, abstract Repository generic, StudentRepository, mixin kiểm tra nghiệp vụ | Đã viết |
| SV1 | StudentModel với factory JSON, Repository lưu trong RAM, CRUD và tìm kiếm | Đã viết |
| SV1 | Demo Dart, unit test, hướng dẫn chạy và bàn giao | Đã viết |
| SV2 | AppException, các exception con và ExceptionFactory | Để trống |
| SV2 | ErrorHandler, AppLogger, ánh xạ lỗi tại Repository | Để trống |
| SV2 | Flutter UI, thông báo lỗi và error boundary | Để trống |

**Chưa có giao diện Flutter, lưu trữ bền vững, giả lập mất mạng hoặc pipeline
ghi log lỗi.** Đây là phần SV1 để ghép tiếp, chưa phải demo hoàn chỉnh của nhóm.
Không cần API key, `.env`, Firebase hoặc cơ sở dữ liệu để chạy phần này.

## Cấu trúc

```text
bin/sv1_demo.dart                      Demo CRUD thành công
lib/
  domain/
    entities/entity.dart              Lớp trừu tượng có id
    entities/student.dart             Entity bất biến, named constructor
    repositories/repository.dart      Repository<T extends Entity>
    repositories/student_repository.dart
    mixins/student_validation.dart    mixin ... on StudentRepository
  data/
    models/student_model.dart         factory fromJson/fromEntity, toJson
    repositories/in_memory_student_repository.dart
  core/                               PHẦN SV2: các file rỗng
    errors/app_exception.dart
    errors/exception_factory.dart
    errors/error_handler.dart
    logger/app_logger.dart
  presentation/main.dart              PHẦN SV2: file rỗng
test/
  student_repository_test.dart
  student_model_test.dart
```

`Domain` không import `Data`, Flutter hoặc thư viện giao diện.
`Data` phụ thuộc các hợp đồng trong `Domain`.
`bin/sv1_demo.dart` khởi tạo implementation rồi truyền vào hàm demo thông qua
`StudentRepository`. Sau này UI cũng nhận hợp đồng này qua constructor.

## Cài đặt và chạy trên PowerShell

Cần Dart SDK từ 3.4 đến dưới 4.0, có thể dùng Dart đi kèm Flutter.
Môi trường dùng để kiểm tra dự án: Dart 3.12.2 đi kèm bộ Flutter trên máy.

Nếu `dart` đã có trong PATH:

```powershell
cd E:\ltdnt\ch01
dart pub get
dart run bin/sv1_demo.dart
dart analyze
dart test
```

Trên máy hiện tại, Dart được tìm thấy ở đường dẫn sau. Nếu terminal báo không
nhận diện `dart`, dùng:

```powershell
cd E:\ltdnt\ch01
$dartSdk = 'E:\fluter\flutter_windows_3.44.9-stable\flutter\bin\dart.bat'
& $dartSdk pub get
& $dartSdk run bin/sv1_demo.dart
& $dartSdk analyze
& $dartSdk test
```

Giữ `pubspec.lock` trong Git để hai thành viên dùng cùng phiên bản package.
`lints` và `test` chỉ phục vụ phát triển; code nghiệp vụ không cần package ngoài.

## Kịch bản demo SV1

1. Tạo `SV001` bằng `StudentModel.fromJson`, tạo `SV002` bằng `Student.freshman`.
2. Thêm hai sinh viên qua interface `StudentRepository`, đọc danh sách.
3. Sửa GPA của `SV001` từ 3.2 thành 3.8 bằng `copyWith` và `update`.
4. Tìm tên chứa `minh` và chuyển một entity thành JSON.
5. Xóa `SV002`, đọc lại danh sách còn `SV001`.

Mỗi lần chạy demo tạo Repository mới. Dữ liệu chỉ nằm trong RAM, không lưu sau
khi chương trình dừng. GPA theo thang 4. Tìm kiếm bỏ khoảng trắng hai đầu và
không phân biệt chữ hoa/thường; chưa hỗ trợ tìm không dấu.

## Các đoạn SV1 cần hiểu khi trình bày

- **Abstract class và generics:** `Repository<T extends Entity>` là hợp đồng
  CRUD; ràng buộc `extends Entity` đảm bảo kiểu dữ liệu có `id`.
- **Kế thừa:** `Student extends Entity`, `StudentRepository extends
  Repository<Student>`. Implementation kế thừa abstract repository và phải
  viết đủ các phương thức. Có thể dùng `implements` nếu chỉ muốn nhận hợp đồng,
  nhưng mixin có `on StudentRepository` ở đây cần quan hệ kế thừa phù hợp.
- **Named constructor:** `Student.freshman` có tên riêng và gán GPA mặc định 0.
- **Factory constructor:** `StudentModel.fromJson` kiểm tra kiểu dữ liệu trước
  khi trả về model; `fromEntity` chuyển entity sang model để serialize.
  Factory không có nghĩa bắt buộc là singleton hoặc cache instance.
- **Mixin:** `StudentValidation` tái sử dụng kiểm tra nghiệp vụ bằng `with`;
  `on StudentRepository` giới hạn lớp được phép áp dụng mixin.
- **Bất biến:** các field là `final`; sửa qua `copyWith`. Danh sách trả về là
  snapshot chỉ đọc để bên gọi không sửa được collection nội bộ.

## Điểm nối dành cho SV2

Các file `lib/core/**/*.dart` và `lib/presentation/main.dart` hiện có kích thước
0 byte, chưa được import. Không thêm code xử lý lỗi tập trung vào chúng ở bước
SV1 này. `presentation/main.dart` là chỗ giữ phần việc, chưa phải entry point
Flutter có thể chạy. SV2 cần bổ sung cấu hình ứng dụng Flutter và thư mục nền
tảng khi làm giao diện, đồng thời giữ nguyên Domain độc lập.

Các lỗi hiện được phát sinh và truyền nguyên ra bên gọi:

| Tình huống | Lỗi hiện tại | Hướng tích hợp SV2 |
| --- | --- | --- |
| Mã rỗng/có khoảng trắng hai đầu, tên trống, email sai, GPA sai | `ArgumentError` | Chuyển thành `ValidationException` |
| Trùng mã, đọc/sửa/xóa mã không tồn tại | `StateError` | Phân loại duplicate và not-found trong lớp adapter hoặc tại nơi phát sinh |
| JSON thiếu field hoặc sai kiểu | `FormatException` | Chuyển thành exception dữ liệu |

Validation nghiệp vụ xảy ra tại `add`/`update`, trước khi đổi dữ liệu. Factory
chỉ kiểm tra cấu trúc/kiểu JSON; dữ liệu đúng kiểu nhưng sai nghiệp vụ vẫn bị
Repository từ chối khi ghi. Các lỗi chuẩn nêu trên là tín hiệu tạm thời của
module SV1, chưa phải hệ thống custom exceptions.

SV2 có thể tạo decorator `StudentRepository` để bắt/chuyển đổi lỗi, hoặc thống
nhất sửa phần implementation. Không suy ra mọi `StateError` đều là not-found;
cần phân biệt trùng mã với không tồn tại. Khi đổi loại lỗi, cập nhật unit test
cho đúng hợp đồng mới. Không nuốt lỗi bằng cách trả danh sách rỗng.

`ArgumentError` và `StateError` kế thừa `Error`, không phải `Exception`;
`on Exception` sẽ không bắt được chúng. Khi ghép pipeline, cần thống nhất thay
các tín hiệu nghiệp vụ này bằng custom exceptions hoặc bắt đúng từng kiểu tại
điểm chuyển đổi. Không gom mọi lỗi lập trình thành lỗi nghiệp vụ.

Các hook `FlutterError.onError`, `PlatformDispatcher.instance.onError`,
`runZonedGuarded`, giả lập lỗi mạng, ghi log và SnackBar/Dialog là phần chưa làm.
Demo trực tiếp trên thiết bị/emulator theo đề cương được thực hiện sau khi nhóm
hoàn thiện phần Flutter.

## Kết quả kiểm tra phần SV1

- Demo terminal hoàn thành đủ thêm, đọc, cập nhật, tìm kiếm và xóa.
- 28 unit test kiểm tra JSON, CRUD, dữ liệu không hợp lệ và bảo toàn dữ liệu.
- Chạy `dart analyze` để kiểm tra tĩnh trước khi bàn giao.

## Git

Mã nguồn được để ở máy, **chưa commit và chưa push** trong lần thực hiện này.
Để giữ commit riêng cho SV1, bạn có thể chạy các lệnh sau khi đã xem và hiểu code:

```powershell
git switch -c feature/domain-repository
git add .
git commit -m "feat: implement SV1 domain and student repository"
```

Lệnh push chỉ chạy khi bạn muốn đưa phần này lên GitHub.
