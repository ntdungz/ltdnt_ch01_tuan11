// Entity nghiệp vụ dùng Mixin và Generics, không phụ thuộc Data hay Flutter.
import '../../core/errors/app_exception.dart';
import '../../core/mixins/validatable.dart';
import 'entity.dart';

// Dữ liệu bất biến giúp tránh sửa kho dữ liệu qua đối tượng trả về.
// extends Entity<int>: kế thừa lớp generic với kiểu khoá là int.
class Student extends Entity<int> with Validatable {
  @override
  final int id;
  final String studentCode;
  final String name;
  final String email;
  final double gpa;

  Student({
    required this.id,
    required this.studentCode,
    required this.name,
    required this.email,
    required this.gpa,
  });

  // NAMED CONSTRUCTOR (redirecting): sinh viên mới, chưa được kho cấp ID.
  Student.draft({
    required String studentCode,
    required String name,
    required String email,
    required double gpa,
  }) : this(
            id: newId,
            studentCode: studentCode,
            name: name,
            email: email,
            gpa: gpa);

  // FACTORY CONSTRUCTOR: tạo Student từ dữ liệu thô người dùng nhập trên form.
  // Chuẩn hoá chuỗi, đọc GPA (chấp nhận dấu phẩy), rồi kiểm tra quy tắc nghiệp vụ.
  // Dữ liệu sai => ném ValidationException kèm toàn bộ lỗi để sửa một lần.
  factory Student.fromForm({
    int id = newId,
    required String studentCode,
    required String name,
    required String email,
    required String gpaText,
  }) {
    final double? gpa = double.tryParse(gpaText.trim().replaceAll(',', '.'));
    final Student student = Student(
      id: id,
      studentCode: studentCode.trim(),
      name: name.trim(),
      email: email.trim(),
      // GPA không đọc được => NaN, để validate() báo đúng câu lỗi về GPA.
      gpa: gpa ?? double.nan,
    );
    final List<String> errors = student.validate();
    if (errors.isNotEmpty) {
      throw ValidationException.fromErrors(errors);
    }
    return student;
  }

  // ID 0 nghĩa là chưa lưu; kho dữ liệu sẽ cấp ID thật khi thêm.
  static const int newId = 0;

  bool get isNew => id == newId;

  // Gom tất cả lỗi để người dùng có thể sửa nhiều trường trong một lần.
  @override
  List<String> validate() {
    final List<String> errors = <String>[];
    if (studentCode.length < 6 || studentCode.length > 12) {
      errors.add('MSSV phải có từ 6 đến 12 ký tự.');
    }
    if (!_hasOnlyLettersAndDigits(studentCode)) {
      errors.add('MSSV chỉ được chứa chữ cái A-Z, a-z và số 0-9.');
    }
    if (name.trim().length < 2) {
      errors.add('Họ tên phải có ít nhất 2 ký tự.');
    }
    if (!email.contains('@') || !email.contains('.')) {
      errors.add('Email phải chứa @ và dấu chấm.');
    }
    if (!gpa.isFinite || gpa < 0 || gpa > 4) {
      errors.add('GPA phải là số từ 0 đến 4.');
    }
    return errors;
  }

  // Kiểm tra mã ASCII từng ký tự, không cần biểu thức chính quy.
  bool _hasOnlyLettersAndDigits(String value) {
    for (final int code in value.codeUnits) {
      final bool isDigit = code >= 48 && code <= 57;
      final bool isUpper = code >= 65 && code <= 90;
      final bool isLower = code >= 97 && code <= 122;
      if (!isDigit && !isUpper && !isLower) {
        return false;
      }
    }
    return true;
  }
}
