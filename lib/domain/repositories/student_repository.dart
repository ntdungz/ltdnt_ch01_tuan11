// Abstract Repository tách hợp đồng nghiệp vụ khỏi cách lưu dữ liệu.
// Kế thừa CRUD tổng quát từ Repository<Student, int> và thêm nghiệp vụ riêng.
import '../entities/student.dart';
import 'repository.dart';

abstract class StudentRepository extends Repository<Student, int> {
  // Tên nguồn dữ liệu đang dùng, để UI cho thấy Factory đã chọn cài đặt nào.
  String get sourceName;

  // Tìm theo họ tên hoặc MSSV, không phân biệt hoa thường.
  Future<List<Student>> search(String keyword);
}
