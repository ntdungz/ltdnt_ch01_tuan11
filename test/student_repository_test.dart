// Kiểm thử Repository bằng kho mới cho từng test, cùng Mixin, JSON và luồng UI.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oop_error_demo/core/errors/app_exception.dart';
import 'package:oop_error_demo/data/models/student_model.dart';
import 'package:oop_error_demo/data/repositories/student_repository_impl.dart';
import 'package:oop_error_demo/domain/entities/student.dart';
import 'package:oop_error_demo/main.dart';

// Named parameters giúp tạo dữ liệu khác nhau mà từng test vẫn ngắn.
Student makeStudent({String code = 'SV0099', double gpa = 3.4, int id = 0}) {
  return Student(
      id: id,
      studentCode: code,
      name: 'Nguyễn Minh',
      email: 'minh@dut.vn',
      gpa: gpa);
}

void main() {
  late StudentRepositoryImpl repository;

  // Mỗi test có kho mới để việc thêm/xóa không ảnh hưởng test kế tiếp.
  setUp(() {
    repository = StudentRepositoryImpl();
  });

  test('getAll trả đúng 5 mẫu và bản sao danh sách', () async {
    final List<Student> students = await repository.getAll();
    expect(students.length, 5);
    students.clear();
    expect((await repository.getAll()).length, 5);
  });

  test('getById tìm thấy và không tìm thấy', () async {
    expect((await repository.getById(1)).studentCode, 'SV0001');
    await expectLater(
        repository.getById(-1), throwsA(isA<NotFoundException>()));
  });

  test('add hợp lệ được cấp ID mới và lưu đúng dữ liệu', () async {
    await repository.add(makeStudent());
    final Student added = await repository.getById(6);
    expect(added.studentCode, 'SV0099');
    expect(added.gpa, 3.4);
    expect((await repository.getAll()).length, 6);
  });

  test('add sai dữ liệu hoặc trùng MSSV không thay đổi danh sách', () async {
    await expectLater(repository.add(makeStudent(gpa: 5)),
        throwsA(isA<ValidationException>()));
    await expectLater(repository.add(makeStudent(code: 'sv0001')),
        throwsA(isA<DuplicateException>()));
    expect((await repository.getAll()).length, 5);
  });

  test('update giữ ID, cho phép giữ mã cũ, chặn mã trùng và GPA sai', () async {
    await repository.update(makeStudent(id: 1, code: 'SV0001'));
    expect((await repository.getById(1)).name, 'Nguyễn Minh');
    await expectLater(repository.update(makeStudent(id: 1, code: 'SV0002')),
        throwsA(isA<DuplicateException>()));
    await expectLater(repository.update(makeStudent(id: 1, gpa: double.nan)),
        throwsA(isA<ValidationException>()));
    await expectLater(repository.update(makeStudent(id: -1)),
        throwsA(isA<NotFoundException>()));
  });

  test('delete xóa đúng, báo thiếu ID và không tái dùng ID đã xóa', () async {
    await repository.add(makeStudent());
    await repository.delete(6);
    await expectLater(repository.getById(6), throwsA(isA<NotFoundException>()));
    await expectLater(repository.delete(6), throwsA(isA<NotFoundException>()));
    await repository.add(makeStudent());
    expect((await repository.getById(7)).studentCode, 'SV0099');
  });

  test('giả lập mạng ảnh hưởng đủ 5 thao tác và có thể phục hồi', () async {
    repository.setSimulateNetworkError(true);
    await expectLater(repository.getAll(), throwsA(isA<NetworkException>()));
    await expectLater(repository.getById(1), throwsA(isA<NetworkException>()));
    await expectLater(
        repository.add(makeStudent()), throwsA(isA<NetworkException>()));
    await expectLater(repository.update(makeStudent(id: 1)),
        throwsA(isA<NetworkException>()));
    await expectLater(repository.delete(1), throwsA(isA<NetworkException>()));
    repository.setSimulateNetworkError(false);
    expect((await repository.getAll()).length, 5);
  });

  test('Mixin kiểm tra độ dài, ký tự MSSV, tên, email và GPA hữu hạn', () {
    expect(makeStudent().isValid(), isTrue);
    expect(makeStudent(code: 'A1234').isValid(), isFalse);
    expect(makeStudent(code: 'A123456789012').isValid(), isFalse);
    expect(makeStudent(code: 'SV_001').isValid(), isFalse);
    expect(makeStudent(code: 'SV0000', gpa: 0).isValid(), isTrue);
    expect(makeStudent(gpa: 4).isValid(), isTrue);
    expect(makeStudent(gpa: double.infinity).isValid(), isFalse);
    final Student invalid =
        Student(id: 0, studentCode: 'SV0001', name: ' ', email: 'abc', gpa: -1);
    expect(invalid.validate().length, 3);
  });

  test('factory JSON, named constructor và toJson bảo toàn dữ liệu', () {
    final StudentModel model = StudentModel.fromStudent(makeStudent());
    final Map<String, dynamic> json = model.toJson();
    final StudentModel restored = StudentModel.fromJson(json);
    expect(restored.toJson(), json);
    json['gpa'] = 4;
    expect(StudentModel.fromJson(json).gpa, 4.0);
    json['gpa'] = 'sai';
    expect(() {
      StudentModel.fromJson(json);
    }, throwsA(isA<ValidationException>()));
    json.remove('name');
    expect(() {
      StudentModel.fromJson(json);
    }, throwsA(isA<ValidationException>()));
  });

  // Bài test UI đi qua Future 500ms thật bằng đồng hồ giả của flutter_test.
  testWidgets('UI tải mẫu, kiểm tra form và hiển thị nhật ký demo lỗi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('5 sinh viên'), findsOneWidget);
    await tester.tap(find.text('Thêm sinh viên'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'SV0010');
    await tester.enterText(find.byType(TextField).at(1), 'Sinh viên kiểm thử');
    await tester.enterText(find.byType(TextField).at(2), 'test@dut.vn');
    await tester.enterText(find.byType(TextField).at(3), '5');
    await tester.ensureVisible(find.text('Lưu sinh viên'));
    await tester.tap(find.text('Lưu sinh viên'));
    await tester.pumpAndSettle();
    expect(find.text('GPA phải là số từ 0 đến 4.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(3), '3.5');
    await tester.tap(find.text('Lưu sinh viên'));
    await tester.pumpAndSettle();
    expect(find.text('6 sinh viên'), findsOneWidget);
    await tester.tap(find.byTooltip('Demo ngoại lệ'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('1. Không tìm thấy sinh viên'));
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy sinh viên. Vui lòng tải lại danh sách.'),
        findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Xem nhật ký'), 200);
    await tester.ensureVisible(find.text('Xem nhật ký'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem nhật ký'));
    await tester.pumpAndSettle();
    expect(find.textContaining('NOT_FOUND'), findsWidgets);
    await tester.tap(find.byTooltip('Xóa log'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có nhật ký. Hãy thử một tình huống demo lỗi.'),
        findsOneWidget);

    // Bật rồi tắt giả lập mất mạng trước khi quay về danh sách.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.textContaining('4. Bật / tắt mất mạng'), -150);
    await tester.ensureVisible(find.textContaining('4. Bật / tắt mất mạng'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('4. Bật / tắt mất mạng'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Không thể kết nối. Kiểm tra mạng hoặc tắt giả lập mất mạng rồi thử lại.'),
        findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('4. Bật / tắt mất mạng'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('6 sinh viên'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(
        find.text(
            'Không thể kết nối. Kiểm tra mạng hoặc tắt giả lập mất mạng rồi thử lại.'),
        findsNothing);
  });
}
