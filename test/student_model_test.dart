// Kiểm thử factory/named constructor và chuyển JSON bằng flutter_test.
import 'package:flutter_test/flutter_test.dart';
import 'package:oop_error_demo/core/errors/app_exception.dart';
import 'package:oop_error_demo/data/models/student_model.dart';

// Tạo Map mới mỗi lần để thay đổi của một test không lan sang test khác.
Map<String, dynamic> makeStudentJson() {
  return <String, dynamic>{
    'id': 10,
    'studentCode': 'SV0010',
    'name': 'Nguyễn Minh',
    'email': 'minh@dut.vn',
    'gpa': 3.4,
  };
}

void main() {
  test('fromJson hợp lệ trả đúng tất cả trường', () {
    final StudentModel model = StudentModel.fromJson(makeStudentJson());
    expect(model.id, 10);
    expect(model.studentCode, 'SV0010');
    expect(model.name, 'Nguyễn Minh');
    expect(model.email, 'minh@dut.vn');
    expect(model.gpa, 3.4);
  });

  test('fromJson thiếu bất kỳ trường bắt buộc nào đều ném ValidationException',
      () {
    for (final String key in <String>[
      'id',
      'studentCode',
      'name',
      'email',
      'gpa'
    ]) {
      final Map<String, dynamic> json = makeStudentJson();
      json.remove(key);
      expect(() {
        StudentModel.fromJson(json);
      }, throwsA(isA<ValidationException>()));
    }
  });

  test('fromJson sai kiểu ở từng trường đều ném ValidationException', () {
    final Map<String, dynamic> invalidValues = <String, dynamic>{
      'id': '10',
      'studentCode': 10,
      'name': false,
      'email': <String>[],
      'gpa': '3.4',
    };
    for (final String key in invalidValues.keys) {
      final Map<String, dynamic> json = makeStudentJson();
      json[key] = invalidValues[key];
      expect(() {
        StudentModel.fromJson(json);
      }, throwsA(isA<ValidationException>()));
    }
  });

  test('toJson rồi fromJson giữ nguyên dữ liệu ban đầu', () {
    final Map<String, dynamic> json = makeStudentJson();
    final StudentModel original = StudentModel.fromJson(json);
    final StudentModel restored = StudentModel.fromJson(original.toJson());
    expect(original.toJson(), json);
    expect(restored.toJson(), original.toJson());
  });
}
