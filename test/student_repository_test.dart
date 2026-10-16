import 'package:ltdnt_ch01_tuan11/data/repositories/in_memory_student_repository.dart';
import 'package:ltdnt_ch01_tuan11/domain/entities/student.dart';
import 'package:ltdnt_ch01_tuan11/domain/repositories/repository.dart';
import 'package:ltdnt_ch01_tuan11/domain/repositories/student_repository.dart';
import 'package:test/test.dart';

void main() {
  late StudentRepository repository;
  const student = Student(
    id: 'SV001',
    fullName: 'Nguyen Tan Dung',
    email: 'dung@example.com',
    gpa: 3.2,
  );

  setUp(() {
    repository = InMemoryStudentRepository();
  });

  test('CRUD hoat dong qua hop dong generic cua Domain', () async {
    final Repository<Student> genericRepository = repository;
    expect(await genericRepository.getAll(), isEmpty);
    await genericRepository.add(student);
    expect((await genericRepository.getById('SV001')).gpa, 3.2);

    await genericRepository.update(student.copyWith(gpa: 3.8));
    expect((await genericRepository.getById('SV001')).gpa, 3.8);
    expect(student.gpa, 3.2);

    await genericRepository.delete('SV001');
    expect(await genericRepository.getAll(), isEmpty);
  });

  test('trung id khong ghi de du lieu cu', () async {
    await repository.add(student);
    await expectLater(
      repository.add(student.copyWith(fullName: 'Ten khac')),
      throwsStateError,
    );
    expect((await repository.getById('SV001')).fullName, student.fullName);
  });

  test('doc, sua, xoa id khong ton tai deu bao loi', () async {
    await expectLater(repository.getById('missing'), throwsStateError);
    await expectLater(repository.update(student), throwsStateError);
    await expectLater(repository.delete('missing'), throwsStateError);
    expect(await repository.getAll(), isEmpty);
  });

  test('tim ten khong phan biet hoa thuong va cat khoang trang', () async {
    await repository.add(student);
    await repository.add(const Student.freshman(
      id: 'SV002',
      fullName: 'Tran Minh Anh',
      email: 'anh@example.com',
    ));
    expect((await repository.findByName('  DUNG ')).single.id, 'SV001');
    expect(await repository.findByName('khong ton tai'), isEmpty);
    expect(await repository.findByName('   '), hasLength(2));
  });

  test('danh sach tra ve khong sua duoc va la snapshot', () async {
    await repository.add(student);
    final snapshot = await repository.getAll();
    expect(() => snapshot.clear(), throwsUnsupportedError);
    await repository.delete('SV001');
    expect(snapshot, hasLength(1));
    expect(await repository.getAll(), isEmpty);
  });

  test('ket qua tim kiem khong cho phep sua du lieu repository', () async {
    await repository.add(student);
    final found = await repository.findByName('Dung');
    expect(() => found.clear(), throwsUnsupportedError);
    expect(await repository.getAll(), hasLength(1));
  });

  final invalidStudents = <String, Student>{
    'id rong': const Student.freshman(
      id: ' ',
      fullName: 'Nguyen Van A',
      email: 'a@example.com',
    ),
    'id co khoang trang hai dau': const Student.freshman(
      id: ' SV001 ',
      fullName: 'Nguyen Van A',
      email: 'a@example.com',
    ),
    'ten rong': student.copyWith(fullName: ' '),
    'email sai': student.copyWith(email: 'khong-phai-email'),
    'GPA am': student.copyWith(gpa: -0.1),
    'GPA lon hon 4': student.copyWith(gpa: 4.1),
    'GPA NaN': student.copyWith(gpa: double.nan),
    'GPA vo cuc': student.copyWith(gpa: double.infinity),
  };

  for (final entry in invalidStudents.entries) {
    test('tu choi ${entry.key} truoc khi them du lieu', () async {
      await expectLater(repository.add(entry.value), throwsArgumentError);
      expect(await repository.getAll(), isEmpty);
    });
  }

  test('cap nhat sai khong lam mat du lieu hop le', () async {
    await repository.add(student);
    await expectLater(
      repository.update(student.copyWith(gpa: double.nan)),
      throwsArgumentError,
    );
    expect((await repository.getById('SV001')).gpa, 3.2);
  });

  test('chap nhan hai bien GPA 0 va 4', () async {
    await repository.add(student.copyWith(gpa: 0));
    await repository.update(student.copyWith(gpa: 4));
    expect((await repository.getById('SV001')).gpa, 4);
  });
}
