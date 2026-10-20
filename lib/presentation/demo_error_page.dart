// Bảy kịch bản minh họa Repository exceptions và centralized error pipeline.
// Kịch bản 1-5 đi qua ErrorHandler.guard; 6-7 minh họa lưới bắt lỗi toàn cục
// và error boundary trong main.dart.
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/errors/error_handler.dart';
import '../core/network/network_simulator.dart';
import '../core/result/result.dart';
import '../data/repositories/repository_factory.dart';
import '../domain/entities/student.dart';
import '../domain/repositories/student_repository.dart';
import 'error_log_page.dart';

// Trang demo dùng chung Repository với danh sách nên công tắc mạng có hiệu lực chung.
class DemoErrorPage extends StatefulWidget {
  const DemoErrorPage({super.key});

  @override
  State<DemoErrorPage> createState() => _DemoErrorPageState();
}

// State khóa các nút trong lúc chờ để mỗi lần chỉ minh họa một lỗi.
class _DemoErrorPageState extends State<DemoErrorPage> {
  bool isLoading = false;
  bool _showBrokenWidget = false;

  StudentRepository get _repository => RepositoryFactory.current;

  // Công tắc mạng lấy từ Factory, UI không cần biết lớp Repository cụ thể.
  NetworkSimulator get _network => RepositoryFactory.networkSimulator;

  // Chuẩn bị dữ liệu riêng để demo vẫn đúng sau khi người dùng sửa/xóa mẫu.
  Future<void> _runScenario(int scenario) async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      if (scenario != 4) {
        _network.setOffline(false);
      }
      final Result<void> result = await ErrorHandler.guard<void>(() async {
        switch (scenario) {
          case 1:
            await _repository.getById(99999);
          case 2:
            await _repository.add(Student.draft(
                studentCode: '!', name: 'A', email: 'sai', gpa: 5));
          case 3:
            List<Student> students = await _repository.getAll();
            if (students.isEmpty) {
              await _repository.add(Student.draft(
                  studentCode: 'DEMO01',
                  name: 'Sinh viên mẫu',
                  email: 'demo@dut.vn',
                  gpa: 3));
              students = await _repository.getAll();
            }
            final Student first = students.first;
            await _repository.add(Student.draft(
                studentCode: first.studentCode,
                name: 'Sinh viên trùng',
                email: 'trung@dut.vn',
                gpa: 3));
          case 4:
            _network.setOffline(!_network.isOffline);
            await _repository.getAll();
          case 5:
            _causeUnexpectedError();
        }
      }, source: 'DemoErrorPage.scenario$scenario');
      if (scenario == 4 && result.isSuccess) {
        _showMessage('Đã tắt giả lập mất mạng. Tải danh sách thành công.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Ép Object đang chứa String sang int tạo TypeError thật, không phải Exception tự tạo.
  void _causeUnexpectedError() {
    final Object value = 'không phải số';
    final int number = value as int;
    _showMessage(number.toString());
  }

  // Kịch bản 6: Future không ai await/catch -> PlatformDispatcher / runZonedGuarded bắt.
  void _throwUncaughtAsyncError() {
    unawaited(Future<void>.delayed(const Duration(milliseconds: 100), () {
      throw StateError('Demo: lỗi bất đồng bộ không được bắt');
    }));
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _demoButton(int scenario, String title, String description,
      [VoidCallback? onPressed]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton.tonal(
        onPressed: onPressed ?? _demoAction(scenario),
        style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(20), alignment: Alignment.centerLeft),
        child: Text('$scenario. $title\n$description'),
      ),
    );
  }

  // Trả null khi đang chạy để tránh nhấn đồng thời nhiều kịch bản.
  VoidCallback? _demoAction(int scenario) {
    if (isLoading) {
      return null;
    }
    return () {
      _runScenario(scenario);
    };
  }

  @override
  Widget build(BuildContext context) {
    String networkStatus = 'Đang tắt giả lập mất mạng';
    if (_network.isOffline) {
      networkStatus = 'Đang bật giả lập mất mạng';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Demo ngoại lệ')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          const Text('Một pipeline, bảy tình huống',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Lỗi → ExceptionFactory → ErrorHandler → Log + SnackBar (ErrorBoundary)'),
          const SizedBox(height: 12),
          Text('$networkStatus · Nguồn: ${_repository.sourceName}'),
          const Text(
              'Nút 1, 2, 3, 5 tự tắt giả lập mạng để demo đúng loại lỗi.'),
          const SizedBox(height: 20),
          if (isLoading) const LinearProgressIndicator(),
          if (_showBrokenWidget)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _BrokenWidget(),
            ),
          _demoButton(1, 'Không tìm thấy sinh viên',
              'Tra cứu ID 99999 → NotFoundException'),
          _demoButton(2, 'Dữ liệu không hợp lệ',
              'Thêm hồ sơ sai → ValidationException'),
          _demoButton(3, 'Trùng mã số sinh viên',
              'Dùng MSSV đang có → DuplicateException'),
          _demoButton(4, 'Bật / tắt mất mạng',
              'SocketException → ExceptionFactory → NetworkException'),
          _demoButton(5, 'Lỗi bất ngờ',
              'Ép kiểu sai → TypeError → UnknownException'),
          _demoButton(6, 'Lỗi bất đồng bộ không được bắt',
              'Không try/catch → PlatformDispatcher / runZonedGuarded',
              _throwUncaughtAsyncError),
          _demoButton(7, 'Bật / tắt widget lỗi khi dựng',
              'Lỗi trong build() → ErrorWidget.builder (error boundary)', () {
            setState(() {
              _showBrokenWidget = !_showBrokenWidget;
            });
          }),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(builder: (BuildContext context) {
                return const ErrorLogPage();
              }));
            },
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Xem nhật ký'),
          ),
        ],
      ),
    );
  }
}

// Widget cố tình lỗi khi dựng để minh họa giao diện dự phòng.
class _BrokenWidget extends StatelessWidget {
  const _BrokenWidget();

  @override
  Widget build(BuildContext context) {
    throw StateError('Demo: widget bị lỗi khi build()');
  }
}
