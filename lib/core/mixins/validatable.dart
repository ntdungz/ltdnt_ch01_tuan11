// Mixin tái sử dụng kiểm tra hợp lệ; List<String> minh họa generics cơ bản.

// Lớp dùng mixin tự định nghĩa quy tắc, còn isValid được dùng lại.
mixin Validatable {
  List<String> validate();

  bool isValid() {
    return validate().isEmpty;
  }
}
