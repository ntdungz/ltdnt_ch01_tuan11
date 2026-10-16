import 'package:ltdnt_ch01_tuan11/data/models/student_model.dart';
import 'package:ltdnt_ch01_tuan11/domain/entities/student.dart';
import 'package:test/test.dart';

void main() {
  final validJson = <String, Object?>{
    'id': 'SV001',
    'fullName': 'Nguyen Tan Dung',
    'email': 'dung@example.com',
    'gpa': 3.5,
  };

  test('factory doc JSON va xuat lai khong mat du lieu', () {
    final model = StudentModel.fromJson(validJson);
    expect(model, isA<Student>());
    expect(model.toJson(), validJson);
  });

  test('GPA JSON kieu int duoc chuyen thanh double', () {
    final model = StudentModel.fromJson({...validJson, 'gpa': 4});
    expect(model.gpa, isA<double>());
    expect(model.gpa, 4.0);
  });

  for (final key in validJson.keys) {
    test('JSON thieu $key bao FormatException', () {
      final incomplete = {...validJson}..remove(key);
      expect(
        () => StudentModel.fromJson(incomplete),
        throwsFormatException,
      );
    });
    test('JSON sai kieu $key bao FormatException', () {
      final invalid = {...validJson, key: key == 'gpa' ? '3.5' : 123};
      expect(() => StudentModel.fromJson(invalid), throwsFormatException);
    });
  }

  test('chuyen entity thanh model va serialize duoc', () {
    const entity = Student(
      id: 'SV001',
      fullName: 'Nguyen Tan Dung',
      email: 'dung@example.com',
      gpa: 3.5,
    );
    expect(StudentModel.fromEntity(entity).toJson(), validJson);
  });

  test('named constructor dat GPA ban dau bang 0', () {
    const student = Student.freshman(
      id: 'SV002',
      fullName: 'Tran Minh Anh',
      email: 'anh@example.com',
    );
    expect(student.gpa, 0);
  });
}
