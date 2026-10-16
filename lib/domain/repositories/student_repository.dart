import '../entities/student.dart';
import 'repository.dart';

abstract class StudentRepository extends Repository<Student> {
  /// Tim theo mot phan ho ten, khong phan biet hoa/thuong.
  /// Tu khoa rong tra ve tat ca sinh vien.
  Future<List<Student>> findByName(String keyword);
}
