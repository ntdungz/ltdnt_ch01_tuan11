import '../../domain/entities/student.dart';

/// Model cua tang Data chiu trach nhiem chuyen doi JSON <-> Entity.
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.gpa,
  });

  /// Factory constructor kiem tra du lieu truoc khi tao doi tuong.
  factory StudentModel.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final fullName = json['fullName'];
    final email = json['email'];
    final gpa = json['gpa'];

    if (id is! String ||
        fullName is! String ||
        email is! String ||
        gpa is! num) {
      throw const FormatException(
        'JSON can id, fullName, email kieu String va gpa kieu so.',
      );
    }

    return StudentModel(
      id: id,
      fullName: fullName,
      email: email,
      gpa: gpa.toDouble(),
    );
  }

  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      fullName: student.fullName,
      email: student.email,
      gpa: student.gpa,
    );
  }

  Map<String, Object?> toJson() {
    return {'id': id, 'fullName': fullName, 'email': email, 'gpa': gpa};
  }
}
