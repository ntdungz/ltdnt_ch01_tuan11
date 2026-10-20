// UI xem nhật ký của Exception pipeline (thời gian, mức log, nguồn, stack trace).
import 'package:flutter/material.dart';

import '../core/logger/app_logger.dart';

// setState cập nhật ảnh chụp nhật ký khi tải lại hoặc xóa, không cần Stream.
class ErrorLogPage extends StatefulWidget {
  const ErrorLogPage({super.key});

  @override
  State<ErrorLogPage> createState() => _ErrorLogPageState();
}

// State lưu bản sao nhật ký để thao tác xem không làm thay đổi logger.
class _ErrorLogPageState extends State<ErrorLogPage> {
  List<AppLog> _logs = AppLogger.getLogs();

  void _refresh() {
    setState(() {
      _logs = AppLogger.getLogs();
    });
  }

  void _clear() {
    AppLogger.clear();
    _refresh();
  }

  // switch trên enum LogLevel: đủ mọi mức log, không so sánh chuỗi.
  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.fatal:
        return Colors.red.shade900;
      case LogLevel.error:
        return Colors.red.shade700;
      case LogLevel.warning:
        return Colors.orange.shade900;
      case LogLevel.info:
        return Colors.teal.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký lỗi'),
        actions: <Widget>[
          IconButton(
              tooltip: 'Tải lại nhật ký',
              onPressed: _refresh,
              icon: const Icon(Icons.refresh)),
          IconButton(
              tooltip: 'Xóa log',
              onPressed: _clear,
              icon: const Icon(Icons.delete_sweep_outlined)),
        ],
      ),
      body: _buildLogs(),
    );
  }

  // ExpansionTile cho phép đọc stack trace khi cần, giữ danh sách dễ đọc.
  Widget _buildLogs() {
    if (_logs.isEmpty) {
      return const Center(
          child: Text('Chưa có nhật ký. Hãy thử một tình huống demo lỗi.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      itemBuilder: (BuildContext context, int index) {
        final AppLog log = _logs[_logs.length - 1 - index];
        return Card(
          child: ExpansionTile(
            title: Text('[${log.level.label}] ${log.message}',
                style: TextStyle(color: _levelColor(log.level))),
            subtitle: Text(log.time.toLocal().toString()),
            children: <Widget>[
              if (log.stackTrace.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(log.stackTrace)),
            ],
          ),
        );
      },
    );
  }
}
