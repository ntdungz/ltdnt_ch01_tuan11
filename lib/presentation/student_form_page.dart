// Form thêm/sửa: Student.fromForm (factory ở Domain) kiểm tra dữ liệu,
// ErrorHandler.guard bắt lỗi tập trung, lỗi validation hiện ngay dưới form.
import 'package:flutter/material.dart';

import '../core/errors/app_exception.dart';
import '../core/errors/error_handler.dart';
import '../core/result/result.dart';
import '../data/repositories/repository_factory.dart';
import '../domain/entities/student.dart';
import '../domain/repositories/student_repository.dart';

// Truyền Entity cần sửa; null nghĩa là thêm, không cần framework quản lý state.
class StudentFormPage extends StatefulWidget {
  final Student? student;

  const StudentFormPage({super.key, this.student});

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

// State giữ nội dung nhập và lỗi của form cho tới khi lưu hoặc đóng trang.
class _StudentFormPageState extends State<StudentFormPage> {
  StudentRepository get _repository => RepositoryFactory.current;
  final TextEditingController _code = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _gpa = TextEditingController();
  bool isLoading = false;
  String _validationMessage = '';

  @override
  void initState() {
    super.initState();
    final Student? student = widget.student;
    if (student != null) {
      _code.text = student.studentCode;
      _name.text = student.name;
      _email.text = student.email;
      _gpa.text = student.gpa.toString();
    }
  }

  // Giải phóng controller khi đóng trang để không giữ bộ nhớ không cần thiết.
  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _email.dispose();
    _gpa.dispose();
    super.dispose();
  }

  // Domain tự chuẩn hoá và kiểm tra dữ liệu qua FACTORY CONSTRUCTOR Student.fromForm.
  Student _readStudent() {
    final Student? current = widget.student;
    return Student.fromForm(
      id: current?.id ?? Student.newId,
      studentCode: _code.text,
      name: _name.text,
      email: _email.text,
      gpaText: _gpa.text,
    );
  }

  // Lỗi đi qua ErrorHandler.guard (ghi log + SnackBar tập trung);
  // riêng lỗi validation còn được hiện chi tiết dưới form.
  Future<void> _save() async {
    if (isLoading) {
      return;
    }
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() {
      isLoading = true;
      _validationMessage = '';
    });
    try {
      final Result<void> result = await ErrorHandler.guard<void>(() async {
        final Student student = _readStudent();
        if (widget.student == null) {
          await _repository.add(student);
        } else {
          await _repository.update(student);
        }
      }, source: 'StudentFormPage.save');
      if (!mounted) {
        return;
      }
      switch (result) {
        case Success<void>():
          Navigator.of(context).pop(true);
        case Failure<void>(error: final ValidationException error):
          setState(() {
            _validationMessage = error.message;
          });
        case Failure<void>():
          break; // Lỗi khác: ErrorBoundary đã hiện SnackBar.
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Thêm sinh viên';
    if (widget.student != null) {
      title = 'Sửa sinh viên';
    }
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              const Text('Thông tin sinh viên',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('MSSV 6-12 chữ/số · GPA theo thang 4'),
              const SizedBox(height: 24),
              TextField(
                  controller: _code,
                  enabled: !isLoading,
                  decoration:
                      const InputDecoration(labelText: 'Mã số sinh viên')),
              const SizedBox(height: 16),
              TextField(
                  controller: _name,
                  enabled: !isLoading,
                  decoration: const InputDecoration(labelText: 'Họ tên')),
              const SizedBox(height: 16),
              TextField(
                  controller: _email,
                  enabled: !isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 16),
              TextField(
                  controller: _gpa,
                  enabled: !isLoading,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'GPA (0-4)')),
              if (_validationMessage.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(_validationMessage,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return FilledButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.save_outlined),
        label: const Text('Lưu sinh viên'));
  }
}
