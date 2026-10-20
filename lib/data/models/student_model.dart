// Model chuyển JSON bằng factory/named constructor, phục vụ Repository.
import '../../core/errors/app_exception.dart';
import '../../domain/entities/student.dart';

// Kế thừa Entity để dùng chung quy tắc kiểm tra dữ liệu.
class StudentModel extends Student {
  StudentModel({
    required super.id,
    required super.studentCode,
    required super.name,
    required super.email,
    required super.gpa,
  });

  // FACTORY CONSTRUCTOR kiểm tra JSON trước khi trả về một model hợp lệ.
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    for (final String key in <String>[
      'id',
      'studentCode',
      'name',
      'email',
      'gpa'
    ]) {
      if (!json.containsKey(key) || json[key] == null) {
        throw ValidationException('Thiếu trường $key trong JSON.');
      }
    }
    if (json['id'] is! int ||
        json['studentCode'] is! String ||
        json['name'] is! String ||
        json['email'] is! String ||
        json['gpa'] is! num) {
      throw ValidationException('Kiểu dữ liệu JSON không hợp lệ.');
    }
    final StudentModel model = StudentModel(
      id: json['id'] as int,
      studentCode: json['studentCode'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      gpa: (json['gpa'] as num).toDouble(),
    );
    final List<String> errors = model.validate();
    if (errors.isNotEmpty) {
      throw ValidationException(errors.join('\n'));
    }
    return model;
  }

  // FACTORY CONSTRUCTOR thứ hai: đọc một "user" của API dummyjson thành sinh viên.
  // API không có MSSV và GPA nên MSSV sinh từ ID (tiền tố DJ = DummyJson),
  // GPA lấy trường 'gpa' nếu có (khi chính app gửi lên), không có thì để 0.
  factory StudentModel.fromApiUser(Map<String, dynamic> json) {
    final Object? rawId = json['id'];
    if (rawId is! int) {
      throw const FormatException('API trả về user không có id kiểu số.');
    }
    final Object? fullName = json['name'];
    final String name = fullName is String
        ? fullName
        : '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    final Object? code = json['studentCode'];
    final Object? gpa = json['gpa'];
    final Object? email = json['email'];
    return StudentModel(
      id: rawId,
      studentCode:
          code is String ? code : 'DJ${rawId.toString().padLeft(6, '0')}',
      name: name,
      email: email is String ? email : '',
      gpa: gpa is num ? gpa.toDouble() : 0,
    );
  }

  // Named constructor sao chép Entity sang Model khi ghi vào bộ nhớ.
  StudentModel.fromStudent(Student student)
      : super(
          id: student.id,
          studentCode: student.studentCode,
          name: student.name,
          email: student.email,
          gpa: student.gpa,
        );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'studentCode': studentCode,
      'name': name,
      'email': email,
      'gpa': gpa,
    };
  }
}
