import '../entities/student.dart';
import '../repositories/student_repository.dart';

/// `on` gioi han mixin cho lop ke thua StudentRepository.
/// `with` tai su dung quy tac nay ma khong tao them mot lop cha.
mixin StudentValidation on StudentRepository {
  void validateStudent(Student student) {
    if (student.id.trim().isEmpty || student.id != student.id.trim()) {
      throw ArgumentError.value(
        student.id,
        'id',
        'Ma sinh vien phai co noi dung va khong co khoang trang hai dau.',
      );
    }
    if (student.fullName.trim().isEmpty) {
      throw ArgumentError.value(
          student.fullName, 'fullName', 'Ho ten bi trong.');
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(student.email)) {
      throw ArgumentError.value(student.email, 'email', 'Email khong hop le.');
    }
    if (!student.gpa.isFinite || student.gpa < 0 || student.gpa > 4) {
      throw ArgumentError.value(
          student.gpa, 'gpa', 'GPA phai nam trong [0, 4].');
    }
  }
}
