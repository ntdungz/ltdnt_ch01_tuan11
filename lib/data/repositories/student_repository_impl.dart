// Repository trong bộ nhớ: CRUD, tìm kiếm, custom exceptions, try/catch/finally, rethrow.
import '../../core/errors/app_exception.dart';
import '../../core/logger/loggable.dart';
import '../../core/network/network_simulator.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';
import 'repository_error_mapper.dart';

// implements bắt buộc lớp này thực hiện đủ hợp đồng của Domain Repository.
// Hai mixin: Loggable (ghi log) + RepositoryErrorMapper (chuẩn hoá lỗi thô).
class StudentRepositoryImpl
    with Loggable, RepositoryErrorMapper
    implements StudentRepository {
  final List<StudentModel> _students = <StudentModel>[];
  final NetworkSimulator _network;
  int _nextId = 6;

  // Dữ liệu đi qua factory để minh họa chuyển JSON, không gọi mạng thật.
  StudentRepositoryImpl({NetworkSimulator? networkSimulator})
      : _network = networkSimulator ?? NetworkSimulator() {
    final List<Map<String, dynamic>> samples = <Map<String, dynamic>>[
      {
        'id': 1,
        'studentCode': 'SV0001',
        'name': 'Nguyễn Văn An',
        'email': 'an@dut.vn',
        'gpa': 3.6
      },
      {
        'id': 2,
        'studentCode': 'SV0002',
        'name': 'Trần Thị Bình',
        'email': 'binh@dut.vn',
        'gpa': 3.8
      },
      {
        'id': 3,
        'studentCode': 'SV0003',
        'name': 'Lê Minh Châu',
        'email': 'chau@dut.vn',
        'gpa': 3.2
      },
      {
        'id': 4,
        'studentCode': 'SV0004',
        'name': 'Phạm Quốc Dũng',
        'email': 'dung@dut.vn',
        'gpa': 3.5
      },
      {
        'id': 5,
        'studentCode': 'SV0005',
        'name': 'Hoàng Ngọc Hà',
        'email': 'ha@dut.vn',
        'gpa': 3.9
      },
    ];
    for (final Map<String, dynamic> json in samples) {
      _students.add(StudentModel.fromJson(json));
    }
  }

  @override
  String get sourceName => 'Bộ nhớ (RAM)';

  // Giữ API cũ cho test; trạng thái thật nằm trong NetworkSimulator dùng chung.
  bool get simulateNetworkError => _network.isOffline;

  void setSimulateNetworkError(bool value) {
    _network.setOffline(value);
  }

  @override
  Future<List<Student>> getAll() {
    return mapErrors('getAll', () async {
      await _network.ensureOnline();
      return List<Student>.of(_students);
    });
  }

  @override
  Future<Student> getById(int id) {
    return mapErrors('getById', () async {
      await _network.ensureOnline();
      return _students[_findIndex(id)];
    });
  }

  @override
  Future<List<Student>> search(String keyword) {
    return mapErrors('search', () async {
      await _network.ensureOnline();
      final String query = keyword.trim().toLowerCase();
      final List<Student> result = <Student>[];
      for (final StudentModel student in _students) {
        if (student.name.toLowerCase().contains(query) ||
            student.studentCode.toLowerCase().contains(query)) {
          result.add(student);
        }
      }
      return result;
    });
  }

  // Repository cấp ID tăng dần; không tái sử dụng ID sau khi xóa.
  @override
  Future<void> add(Student student) {
    return mapErrors('add', () async {
      try {
        await _network.ensureOnline();
        _validate(student);
        _checkDuplicate(student.studentCode, -1);
        _students.add(StudentModel(
          id: _nextId,
          studentCode: student.studentCode,
          name: student.name,
          email: student.email,
          gpa: student.gpa,
        ));
        _nextId++;
        logInfo('Đã thêm sinh viên ${student.studentCode}.');
      } catch (error) {
        logInfo('Thao tác thêm thất bại, chuyển lỗi lên tầng gọi.');
        rethrow;
      } finally {
        logInfo('Kết thúc thao tác thêm sinh viên.');
      }
    });
  }

  @override
  Future<void> update(Student student) {
    return mapErrors('update', () async {
      await _network.ensureOnline();
      final int index = _findIndex(student.id);
      _validate(student);
      _checkDuplicate(student.studentCode, student.id);
      _students[index] = StudentModel.fromStudent(student);
      logInfo('Đã sửa sinh viên ${student.studentCode}.');
    });
  }

  @override
  Future<void> delete(int id) {
    return mapErrors('delete', () async {
      await _network.ensureOnline();
      final int index = _findIndex(id);
      _students.removeAt(index);
      logInfo('Đã xóa sinh viên ID $id.');
    });
  }

  // Dùng vòng lặp để thấy rõ trường hợp không tìm được sinh viên.
  int _findIndex(int id) {
    for (int index = 0; index < _students.length; index++) {
      if (_students[index].id == id) {
        return index;
      }
    }
    throw NotFoundException.student(id);
  }

  void _validate(Student student) {
    final List<String> errors = student.validate();
    if (errors.isNotEmpty) {
      throw ValidationException.fromErrors(errors);
    }
  }

  // Khi sửa, bỏ qua chính ID đang sửa; MSSV được so sánh không phân biệt hoa thường.
  void _checkDuplicate(String studentCode, int excludedId) {
    for (final StudentModel current in _students) {
      if (current.id != excludedId &&
          current.studentCode.toUpperCase() == studentCode.toUpperCase()) {
        throw DuplicateException('MSSV $studentCode đã được sử dụng.');
      }
    }
  }
}
