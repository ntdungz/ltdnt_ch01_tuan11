import 'package:ltdnt_ch01_tuan11/core/logger/app_logger.dart';
import 'package:test/test.dart';

void main() {
  test('ghi log theo muc do va in ra output', () {
    final lines = <String>[];
    final logger = AppLogger(output: lines.add);

    logger.info('Khoi dong');
    logger.warning('Email sai');
    logger.error('Mat mang', error: 'TimeoutException');

    expect(
      logger.entries.map((entry) => entry.level),
      [LogLevel.info, LogLevel.warning, LogLevel.error],
    );
    expect(lines, hasLength(3));
    expect(lines.last, contains('[ERROR] Mat mang'));
  });

  test('bao cho listener moi khi co log moi', () {
    final logger = AppLogger(output: (_) {});
    final received = <String>[];
    void listener(LogEntry entry) => received.add(entry.message);

    logger.addListener(listener);
    logger.info('Lan 1');
    logger.removeListener(listener);
    logger.info('Lan 2');

    expect(received, ['Lan 1']);
  });

  test('chi giu toi da maxEntries dong log', () {
    final logger = AppLogger(output: (_) {}, maxEntries: 2);
    logger.info('1');
    logger.info('2');
    logger.info('3');
    expect(logger.entries.map((entry) => entry.message), ['2', '3']);
  });
}