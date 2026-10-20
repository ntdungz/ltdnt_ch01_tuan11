// UI danh sách gọi abstract Repository; mọi lỗi đi qua ErrorHandler.guard,
// SnackBar báo lỗi do ErrorBoundary hiện tập trung.
import 'package:flutter/material.dart';

import '../core/errors/error_handler.dart';
import '../core/result/result.dart';
import '../data/repositories/repository_factory.dart';
import '../domain/entities/student.dart';
import '../domain/repositories/student_repository.dart';
import 'demo_error_page.dart';
import 'error_log_page.dart';
import 'student_form_page.dart';

// StatefulWidget dùng setState để thể hiện loading và dữ liệu đơn giản.
class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

// State giữ danh sách và loading tại trang, không cần thư viện quản lý state.
class _StudentListPageState extends State<StudentListPage> {
  final TextEditingController _search = TextEditingController();
  List<Student> _students = <Student>[];
  bool isLoading = false;

  // Luôn hỏi Factory, vì người dùng có thể đổi nguồn dữ liệu lúc đang chạy.
  StudentRepository get _repository => RepositoryFactory.current;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // try/finally: tắt loading dù thành công hay lỗi.
  // Lỗi đã được guard ghi log và ErrorBoundary hiện SnackBar, ở đây không catch nữa.
  Future<void> _loadStudents() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final String keyword = _search.text.trim();
      final Result<List<Student>> result = await ErrorHandler.guard(
        () => keyword.isEmpty
            ? _repository.getAll()
            : _repository.search(keyword),
        source: 'StudentListPage.load',
      );
      if (!mounted) {
        return;
      }
      if (result case Success<List<Student>>(:final List<Student> data)) {
        setState(() {
          _students = data;
        });
      } else if (keyword.isNotEmpty) {
        // Tìm kiếm lỗi: không giữ kết quả cũ để tránh hiểu nhầm là tìm sai.
        setState(() {
          _students = <Student>[];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // Factory Pattern trên giao diện: đổi Repository mà UI không cần biết lớp cụ thể.
  Future<void> _switchSource(RepositoryType type) async {
    if (type == RepositoryFactory.currentType) {
      return;
    }
    RepositoryFactory.use(type);
    _search.clear();
    setState(() {
      _students = <Student>[];
    });
    await _loadStudents();
  }

  // Form trả true sau khi lưu để danh sách chỉ tải lại khi có thay đổi.
  Future<void> _openForm(Student? student) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (BuildContext context) {
        return StudentFormPage(student: student);
      }),
    );
    if (saved == true && mounted) {
      await _loadStudents();
    }
  }

  Future<void> _openDemo() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext context) {
        return const DemoErrorPage();
      }),
    );
    if (mounted) {
      await _loadStudents();
    }
  }

  // Đọc lại theo ID để minh họa getById và xử lý bản ghi không còn tồn tại.
  Future<void> _showDetails(Student student) async {
    setState(() {
      isLoading = true;
    });
    try {
      final Result<Student> result = await ErrorHandler.guard(
        () => _repository.getById(student.id),
        source: 'StudentListPage.details',
      );
      if (!mounted) {
        return;
      }
      if (result case Success<Student>(:final Student data)) {
        await showDialog<void>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(data.name),
              content: Text(
                'ID: ${data.id}\nMSSV: ${data.studentCode}\n'
                'Email: ${data.email}\nGPA: ${data.gpa.toStringAsFixed(2)} / 4.00',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Xác nhận tránh xóa nhầm; lỗi chỉ được phân loại trong ErrorHandler.
  Future<void> _deleteStudent(Student student) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xóa sinh viên?'),
          content: Text(
              'Xóa ${student.name} (${student.studentCode}) khỏi danh sách?'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Hủy')),
            FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Xóa')),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final Result<void> result = await ErrorHandler.guard(
      () => _repository.delete(student.id),
      source: 'StudentListPage.delete',
    );
    if (result.isSuccess) {
      _showMessage('Đã xóa sinh viên.');
      await _loadStudents();
    }
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () {
                _showDetails(student);
              },
              leading: CircleAvatar(child: Text(student.id.toString())),
              title: Text(student.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${student.studentCode}\n${student.email}'),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child:
                          Text('GPA ${student.gpa.toStringAsFixed(2)} / 4.00')),
                  IconButton(
                      tooltip: 'Sửa sinh viên',
                      onPressed: () {
                        _openForm(student);
                      },
                      icon: const Icon(Icons.edit_outlined)),
                  IconButton(
                      tooltip: 'Xóa sinh viên',
                      onPressed: () {
                        _deleteStudent(student);
                      },
                      icon: const Icon(Icons.delete_outline)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _search,
      textInputAction: TextInputAction.search,
      onSubmitted: (String _) {
        _loadStudents();
      },
      decoration: InputDecoration(
        hintText: 'Tìm theo họ tên hoặc MSSV',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: IconButton(
          tooltip: 'Xóa tìm kiếm',
          icon: const Icon(Icons.clear),
          onPressed: () {
            _search.clear();
            _loadStudents();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý sinh viên'),
        actions: <Widget>[
          PopupMenuButton<RepositoryType>(
            tooltip: 'Đổi nguồn dữ liệu',
            icon: const Icon(Icons.swap_horiz),
            onSelected: _switchSource,
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<RepositoryType>>[
                for (final RepositoryType type in RepositoryType.values)
                  CheckedPopupMenuItem<RepositoryType>(
                    value: type,
                    checked: type == RepositoryFactory.currentType,
                    child: Text(type.label),
                  ),
              ];
            },
          ),
          IconButton(
            tooltip: 'Nhật ký lỗi',
            onPressed: () {
              Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return const ErrorLogPage();
              }));
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          IconButton(
              tooltip: 'Demo ngoại lệ',
              onPressed: _openDemo,
              icon: const Icon(Icons.science_outlined)),
        ],
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Column(
          children: <Widget>[
            if (isLoading) const LinearProgressIndicator(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStudents,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
                  children: <Widget>[
                    const Text('HỒ SƠ HỌC TẬP',
                        style: TextStyle(
                            letterSpacing: 2,
                            color: Color(0xFF087F8C),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${_students.length} sinh viên',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    Text('Nguồn: ${_repository.sourceName}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const Text('Chạm để xem chi tiết · Kéo xuống để tải lại'),
                    const SizedBox(height: 16),
                    _buildSearchField(),
                    const SizedBox(height: 16),
                    if (_students.isEmpty && !isLoading)
                      const Card(
                          child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                  'Chưa có dữ liệu. Kéo xuống để thử tải lại hoặc thêm sinh viên.'))),
                    for (final Student student in _students)
                      _buildStudentCard(student),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  Widget _buildAddButton() {
    if (isLoading) {
      return const SizedBox.shrink();
    }
    return FloatingActionButton.extended(
      onPressed: () {
        _openForm(null);
      },
      icon: const Icon(Icons.add),
      label: const Text('Thêm sinh viên'),
    );
  }
}
