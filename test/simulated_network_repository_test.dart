import 'dart:async';

import 'package:ltdnt_ch01_tuan11/data/repositories/in_memory_student_repository.dart';
import 'package:ltdnt_ch01_tuan11/data/repositories/simulated_network_repository.dart';
import 'package:ltdnt_ch01_tuan11/domain/entities/student.dart';
import 'package:test/test.dart';

void main() {
  const student = Student(
    id: 'SV001',
    fullName: 'Nguyen Tan Dung',
    email: 'dung@example.com',
    gpa: 3.2,
  );
  late SimulatedNetworkRepository repository;

  setUp(() {
    repository = SimulatedNetworkRepository(
      InMemoryStudentRepository(),
      latency: Duration.zero,
    );
  });

  test('co mang thi chuyen tiep binh thuong', () async {
    await repository.add(student);
    expect(await repository.getAll(), hasLength(1));
  });

  test('mat mang thi bao TimeoutException va khong doi du lieu', () async {
    await repository.add(student);
    repository.isOffline = true;

    await expectLater(repository.getAll(), throwsA(isA<TimeoutException>()));
    await expectLater(
      repository.delete('SV001'),
      throwsA(isA<TimeoutException>()),
    );

    repository.isOffline = false;
    expect(await repository.getAll(), hasLength(1));
  });
}