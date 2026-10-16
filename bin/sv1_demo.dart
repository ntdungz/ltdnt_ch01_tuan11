import 'package:ltdnt_ch01_tuan11/data/models/student_model.dart';
import 'package:ltdnt_ch01_tuan11/data/repositories/in_memory_student_repository.dart';
import 'package:ltdnt_ch01_tuan11/domain/entities/student.dart';
import 'package:ltdnt_ch01_tuan11/domain/repositories/student_repository.dart';

/// Diem ghep phu thuoc: chi main biet implementation cu the.
Future<void> main() async {
  await runDemo(InMemoryStudentRepository());
}

/// Logic demo chi dung interface cua Domain.
Future<void> runDemo(StudentRepository repository) async {
  print('=== SV1: OOP nang cao va Repository Pattern ===');

  final fromJson = StudentModel.fromJson({
    'id': 'SV001',
    'fullName': 'Nguyen Tan Dung',
    'email': 'dung@example.com',
    'gpa': 3.2,
  });
  const freshman = Student.freshman(
    id: 'SV002',
    fullName: 'Tran Minh Anh',
    email: 'anh@example.com',
  );

  await repository.add(fromJson);
  await repository.add(freshman);
  await printStudents('1. Them va xem danh sach', repository);

  final student = await repository.getById('SV001');
  await repository.update(student.copyWith(gpa: 3.8));
  await printStudents('2. Cap nhat GPA SV001 thanh 3.8', repository);

  final found = await repository.findByName('minh');
  print('3. Tim "minh": ${found.map((item) => item.fullName).join(', ')}');

  final updated = await repository.getById('SV001');
  print('4. Xuat JSON: ${StudentModel.fromEntity(updated).toJson()}');

  await repository.delete('SV002');
  await printStudents('5. Xoa SV002', repository);
  print('Hoan tat demo SV1. Phan xu ly loi tap trung de trong cho SV2.');
}

Future<void> printStudents(String label, StudentRepository repository) async {
  print('\n$label:');
  for (final student in await repository.getAll()) {
    print('${student.id} | ${student.fullName} | ${student.email} | '
        'GPA: ${student.gpa.toStringAsFixed(1)}');
  }
}
