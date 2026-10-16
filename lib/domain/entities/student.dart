import 'entity.dart';

/// Thuc the nghiep vu, khong phu thuoc Flutter, JSON hay tang Data.
class Student extends Entity {
  const Student({
    required super.id,
    required this.fullName,
    required this.email,
    required this.gpa,
  });

  /// Named constructor: sinh vien moi chua co diem tich luy.
  const Student.freshman({
    required super.id,
    required this.fullName,
    required this.email,
  }) : gpa = 0;

  final String fullName;
  final String email;
  final double gpa;

  /// Tao ban sao thay vi thay doi doi tuong da luu trong Repository.
  Student copyWith({String? fullName, String? email, double? gpa}) {
    return Student(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      gpa: gpa ?? this.gpa,
    );
  }
}
