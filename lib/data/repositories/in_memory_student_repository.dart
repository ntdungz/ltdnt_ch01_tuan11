import '../../domain/entities/student.dart';
import '../../domain/mixins/student_validation.dart';
import '../../domain/repositories/student_repository.dart';

/// Ban cai dat CRUD trong RAM. Du lieu mat khi dung chuong trinh.
/// Chua bat/chuyen doi/ghi log loi: phan pipeline danh cho SV2.
class InMemoryStudentRepository extends StudentRepository
    with StudentValidation {
  final Map<String, Student> _students = {};

  @override
  Future<List<Student>> getAll() async {
    return List<Student>.unmodifiable(_students.values);
  }

  @override
  Future<Student> getById(String id) async {
    final student = _students[id];
    if (student == null) {
      throw StateError('Khong tim thay sinh vien: $id.');
    }
    return student;
  }

  @override
  Future<void> add(Student entity) async {
    validateStudent(entity);
    if (_students.containsKey(entity.id)) {
      throw StateError('Ma sinh vien da ton tai: ${entity.id}.');
    }
    _students[entity.id] = entity;
  }

  @override
  Future<void> update(Student entity) async {
    validateStudent(entity);
    if (!_students.containsKey(entity.id)) {
      throw StateError('Khong tim thay sinh vien: ${entity.id}.');
    }
    _students[entity.id] = entity;
  }

  @override
  Future<void> delete(String id) async {
    if (!_students.containsKey(id)) {
      throw StateError('Khong tim thay sinh vien: $id.');
    }
    _students.remove(id);
  }

  @override
  Future<List<Student>> findByName(String keyword) async {
    final query = keyword.trim().toLowerCase();
    return List<Student>.unmodifiable(
      _students.values.where(
        (student) => student.fullName.toLowerCase().contains(query),
      ),
    );
  }
}
