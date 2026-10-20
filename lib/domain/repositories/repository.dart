// GENERICS có ràng buộc: hợp đồng CRUD tổng quát cho MỌI thực thể.
// T phải là một Entity<ID>; ID là kiểu khoá chính (int, String...).
// Thêm thực thể mới (Course, Teacher...) chỉ cần `extends Repository<Course, int>`.
import '../entities/entity.dart';

abstract class Repository<T extends Entity<ID>, ID> {
  Future<List<T>> getAll();
  Future<T> getById(ID id);
  Future<void> add(T entity);
  Future<void> update(T entity);
  Future<void> delete(ID id);
}
