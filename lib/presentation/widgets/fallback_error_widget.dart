// Giao diện dự phòng khi một widget bị lỗi lúc dựng (gắn qua ErrorWidget.builder).
// Chỉ phần giao diện bị lỗi được thay bằng khung này; phần còn lại vẫn dùng được.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FallbackErrorWidget extends StatelessWidget {
  const FallbackErrorWidget({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    // Tự bọc Directionality/Material vì widget này có thể được dựng ở bất kỳ đâu.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.report_gmailerrorred,
                  color: Color(0xFFC62828), size: 32),
              const SizedBox(height: 8),
              const Text('Một phần giao diện gặp lỗi',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Color(0xFF8E0000))),
              const SizedBox(height: 4),
              Text(
                kReleaseMode
                    ? 'Lỗi đã được ghi vào nhật ký.'
                    : details.exceptionAsString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
