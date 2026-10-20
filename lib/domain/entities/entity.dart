// GENERICS: lớp cơ sở cho mọi thực thể nghiệp vụ, tổng quát hoá kiểu khoá chính.
// Ví dụ: Entity<int> cho Student, Entity<String> cho một thực thể dùng mã chuỗi.
abstract class Entity<ID> {
  const Entity();

  ID get id;
}
