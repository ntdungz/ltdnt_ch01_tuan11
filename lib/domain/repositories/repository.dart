import '../entities/entity.dart';

/// Hop dong CRUD dung chung; Domain khong biet du lieu duoc luu o dau.
abstract class Repository<T extends Entity> {
  Future<List<T>> getAll();

  /// Phat sinh StateError neu id khong ton tai.
  Future<T> getById(String id);

  /// Phat sinh StateError neu trung id; khong ghi de ban ghi cu.
  Future<void> add(T entity);

  /// Chi cap nhat doi tuong da ton tai.
  Future<void> update(T entity);

  /// Phat sinh StateError neu id khong ton tai.
  Future<void> delete(String id);
}
