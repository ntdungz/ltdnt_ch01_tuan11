# Chủ đề 01 - OOP nâng cao và Design Patterns trong Dart

Dự án của nhóm **Dũng – Tiên**, dùng bài toán quản lý sinh viên để minh họa OOP,
Repository Pattern, Factory Pattern và cơ chế xử lý ngoại lệ tập trung
(Centralized Error Handling Pipeline). Phần Domain/Data hiện là module
**Dart thuần**, chạy độc lập bằng terminal và sẽ được đưa vào ứng dụng Flutter
khi hoàn thiện giao diện.

## Phân công và phạm vi

PDF đề cương quy định yêu cầu cho cả nhóm, không chia sẵn từng file cho mỗi
người. Nhóm thống nhất: **Dũng** làm Domain/Repository và phần xử lý lỗi nâng cao;
**Tiên** làm các lớp lỗi, ExceptionFactory, ghi log, giao diện và slide.
Bảng dưới sắp theo thứ tự thực hiện:

| STT | Thành viên | Công việc | Trạng thái |
| --- | --- | --- | --- |
| 1 | Dũng | Entity, abstract Repository generic, StudentRepository, mixin kiểm tra nghiệp vụ | Đã viết |
| 2 | Dũng | StudentModel với factory JSON, Repository lưu trong RAM, CRUD và tìm kiếm | Đã viết |
| 3 | Dũng | Demo Dart, unit test, hướng dẫn chạy và bàn giao | Đã viết |
| 4 | Tiên | AppException và các exception con | Chưa làm |
| 5 | Tiên | ExceptionFactory: chuyển lỗi gốc thành exception của ứng dụng | Chưa làm |
| 6 | Tiên | AppLogger và giả lập mất mạng | Chưa làm |
| 7 | Dũng | ErrorHandler, ánh xạ lỗi tại Repository và cập nhật unit test | Chưa làm |
| 8 | Dũng | Bắt lỗi toàn cục và error boundary | Chưa làm |
| 9 | Tiên | Flutter UI: danh sách, thêm/xóa, thông báo lỗi bằng SnackBar | Chưa làm |
| 10 | Tiên | Slide, chạy demo trên máy ảo, README phần của Tiên | Chưa làm |

**Chưa có giao diện Flutter, lưu trữ bền vững, giả lập mất mạng hoặc pipeline
ghi log lỗi.** Không cần API key, `.env`, Firebase hoặc cơ sở dữ liệu để chạy
dự án.

## Cấu trúc

```text
bin/sv1_demo.dart                      Demo CRUD thành công (Dũng)
lib/
  domain/                             (Dũng)
    entities/entity.dart              Lớp trừu tượng có id
    entities/student.dart             Entity bất biến, named constructor
    repositories/repository.dart      Repository<T extends Entity>
    repositories/student_repository.dart
    mixins/student_validation.dart    mixin ... on StudentRepository
  data/                               (Dũng)
    models/student_model.dart         factory fromJson/fromEntity, toJson
    repositories/in_memory_student_repository.dart
  core/                               Đang trống, chờ làm
    errors/app_exception.dart         Tiên - bước 4
    errors/exception_factory.dart     Tiên - bước 5
    logger/app_logger.dart            Tiên - bước 6
    errors/error_handler.dart         Dũng - bước 7, 8
  presentation/main.dart              Tiên - bước 9, đang trống
test/
  student_repository_test.dart
  student_model_test.dart
```

`Domain` không import `Data`, Flutter hoặc thư viện giao diện.
`Data` phụ thuộc các hợp đồng trong `Domain`.
`bin/sv1_demo.dart` khởi tạo implementation rồi truyền vào hàm demo thông qua
`StudentRepository`. Sau này UI cũng nhận hợp đồng này qua constructor.

## Cài đặt và chạy

Cần Dart SDK từ 3.4 đến dưới 4.0, có thể dùng Dart đi kèm Flutter.

```powershell
git clone https://github.com/ntdungz/ltdnt_ch01_tuan11.git
cd ltdnt_ch01_tuan11
git checkout feature/domain-repository
dart pub get
dart run bin/sv1_demo.dart
dart analyze
dart test
```

Nếu terminal báo không nhận diện `dart`, gọi trực tiếp file `dart.bat` trong thư
mục cài Flutter, ví dụ:

```powershell
$dartSdk = 'E:\fluter\flutter_windows_3.44.9-stable\flutter\bin\dart.bat'
& $dartSdk pub get
& $dartSdk test
```

Giữ `pubspec.lock` trong Git để hai thành viên dùng cùng phiên bản package.
`lints` và `test` chỉ phục vụ phát triển; code nghiệp vụ không cần package ngoài.

## Kịch bản demo phần Domain/Data

1. Tạo `SV001` bằng `StudentModel.fromJson`, tạo `SV002` bằng `Student.freshman`.
2. Thêm hai sinh viên qua interface `StudentRepository`, đọc danh sách.
3. Sửa GPA của `SV001` từ 3.2 thành 3.8 bằng `copyWith` và `update`.
4. Tìm tên chứa `minh` và chuyển một entity thành JSON.
5. Xóa `SV002`, đọc lại danh sách còn `SV001`.

Mỗi lần chạy demo tạo Repository mới. Dữ liệu chỉ nằm trong RAM, không lưu sau
khi chương trình dừng. GPA theo thang 4. Tìm kiếm bỏ khoảng trắng hai đầu và
không phân biệt chữ hoa/thường; chưa hỗ trợ tìm không dấu.

## Kiến thức OOP trong phần Domain/Data

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

## Điểm nối cho phần xử lý lỗi

Các file `lib/core/**/*.dart` và `lib/presentation/main.dart` hiện có kích thước
0 byte, chưa được import. `presentation/main.dart` chưa phải entry point Flutter
có thể chạy; khi làm giao diện cần bổ sung cấu hình ứng dụng Flutter và thư mục
nền tảng, đồng thời giữ nguyên Domain độc lập.

Các lỗi hiện được phát sinh và truyền nguyên ra bên gọi:

| Tình huống | Lỗi hiện tại | Hướng tích hợp |
| --- | --- | --- |
| Mã rỗng/có khoảng trắng hai đầu, tên trống, email sai, GPA sai | `ArgumentError` | Chuyển thành `ValidationException` |
| Trùng mã, đọc/sửa/xóa mã không tồn tại | `StateError` | Phân loại duplicate và not-found trong lớp adapter hoặc tại nơi phát sinh |
| JSON thiếu field hoặc sai kiểu | `FormatException` | Chuyển thành exception dữ liệu |

Validation nghiệp vụ xảy ra tại `add`/`update`, trước khi đổi dữ liệu. Factory
chỉ kiểm tra cấu trúc/kiểu JSON; dữ liệu đúng kiểu nhưng sai nghiệp vụ vẫn bị
Repository từ chối khi ghi.

Lưu ý khi làm:

- Không suy ra mọi `StateError` đều là not-found; cần phân biệt trùng mã với
  không tồn tại. Không nuốt lỗi bằng cách trả danh sách rỗng.
- `ArgumentError` và `StateError` kế thừa `Error`, không phải `Exception`;
  `on Exception` sẽ không bắt được chúng. Cần bắt đúng từng kiểu tại điểm
  chuyển đổi, không gom mọi lỗi lập trình thành lỗi nghiệp vụ.
- Khi đổi loại lỗi, cập nhật unit test cho đúng hợp đồng mới.

Các hook `FlutterError.onError`, `PlatformDispatcher.instance.onError`,
`runZonedGuarded`, giả lập lỗi mạng, ghi log và SnackBar/Dialog là phần chưa làm.
Demo trực tiếp trên thiết bị/emulator được thực hiện sau khi nhóm hoàn thiện
phần Flutter.

## Kết quả kiểm tra hiện tại

- Demo terminal hoàn thành đủ thêm, đọc, cập nhật, tìm kiếm và xóa.
- 28 unit test kiểm tra JSON, CRUD, dữ liệu không hợp lệ và bảo toàn dữ liệu.
- Chạy `dart analyze` để kiểm tra tĩnh trước khi bàn giao.

## Quy trình Git của nhóm

- `feature/domain-repository`: nhánh làm việc chung của nhóm.
- `main`: chỉ chứa bản hoàn chỉnh cuối cùng.
- Mỗi phần việc làm trên một nhánh riêng, tách ra từ `feature/domain-repository`:

```powershell
git checkout feature/domain-repository
git pull
git checkout -b feature/ten-phan-viec
# ... viết code ...
git add .
git commit -m "Mô tả ngắn phần đã làm"
git push -u origin feature/ten-phan-viec
```

Sau đó tạo Pull Request với **base** là `feature/domain-repository` để thành
viên còn lại xem trước khi merge. Mỗi người tự commit phần của mình để lịch sử
commit thể hiện đúng phân công.
