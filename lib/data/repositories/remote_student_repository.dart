// Repository thứ hai cho Factory Pattern: lấy dữ liệu từ REST API thật
// (mặc định https://dummyjson.com/users) bằng HttpClient có sẵn của dart:io,
// không cần thêm package.
//
// Lưu ý: dummyjson chỉ GIẢ LẬP thêm/sửa/xóa, dữ liệu không được lưu lại.
import 'dart:convert';
import 'dart:io';

import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_factory.dart';
import '../../core/logger/loggable.dart';
import '../../core/network/network_simulator.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';
import 'repository_error_mapper.dart';

class RemoteStudentRepository
    with Loggable, RepositoryErrorMapper
    implements StudentRepository {
  RemoteStudentRepository({
    required String baseUrl,
    required NetworkSimulator networkSimulator,
    this.timeout = const Duration(seconds: 10),
  })  : _baseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
        _network = networkSimulator;

  final String _baseUrl;
  final NetworkSimulator _network;
  final Duration timeout;

  static const String _fields = 'firstName,lastName,email';

  @override
  String get sourceName => 'Remote API ($_baseUrl)';

  // Gửi request HTTP. Minh họa try - FINALLY: luôn đóng kết nối và ghi thời gian.
  // SocketException / TimeoutException / FormatException được để nguyên,
  // mapErrors() sẽ chuẩn hoá chúng qua ExceptionFactory.
  Future<Object?> _send(String method, String path,
      [Map<String, dynamic>? body]) async {
    await _network.ensureOnline(delay: Duration.zero);
    final Uri uri = Uri.parse('$_baseUrl$path');
    final HttpClient client = HttpClient()..connectionTimeout = timeout;
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      final HttpClientRequest request =
          await client.openUrl(method, uri).timeout(timeout);
      request.headers.contentType = ContentType.json;
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final HttpClientResponse response = await request.close().timeout(timeout);
      final String text =
          await response.transform(utf8.decoder).join().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ExceptionFactory.fromHttpStatus(
            response.statusCode, uri.toString());
      }
      return text.isEmpty ? null : jsonDecode(text);
    } finally {
      client.close(force: true);
      stopwatch.stop();
      logInfo('$method $path (${stopwatch.elapsedMilliseconds} ms)');
    }
  }

  List<Student> _parseUsers(Object? json) {
    if (json is! Map<String, dynamic> || json['users'] is! List<dynamic>) {
      throw const FormatException('Thiếu danh sách "users" trong phản hồi.');
    }
    final List<Student> students = <Student>[];
    for (final Object? item in json['users'] as List<dynamic>) {
      students.add(StudentModel.fromApiUser(item as Map<String, dynamic>));
    }
    return students;
  }

  Student _parseUser(Object? json) {
    return StudentModel.fromApiUser(json as Map<String, dynamic>);
  }

  Map<String, dynamic> _toBody(Student student) {
    return <String, dynamic>{
      'firstName': student.name,
      'lastName': '',
      'name': student.name,
      'email': student.email,
      'studentCode': student.studentCode,
      'gpa': student.gpa,
    };
  }

  void _validate(Student student) {
    final List<String> errors = student.validate();
    if (errors.isNotEmpty) {
      throw ValidationException.fromErrors(errors);
    }
  }

  @override
  Future<List<Student>> getAll() {
    return mapErrors('getAll', () async {
      return _parseUsers(await _send('GET', '/users?limit=30&select=$_fields'));
    });
  }

  @override
  Future<Student> getById(int id) {
    return mapErrors('getById', () async {
      return _parseUser(await _send('GET', '/users/$id?select=$_fields'));
    });
  }

  @override
  Future<List<Student>> search(String keyword) {
    final String query = Uri.encodeQueryComponent(keyword.trim());
    return mapErrors('search', () async {
      return _parseUsers(
          await _send('GET', '/users/search?q=$query&select=$_fields'));
    });
  }

  @override
  Future<void> add(Student student) {
    return mapErrors('add', () async {
      _validate(student);
      await _send('POST', '/users/add', _toBody(student));
      logInfo('API đã nhận yêu cầu thêm ${student.studentCode} (giả lập).');
    });
  }

  @override
  Future<void> update(Student student) {
    return mapErrors('update', () async {
      _validate(student);
      await _send('PUT', '/users/${student.id}', _toBody(student));
      logInfo('API đã nhận yêu cầu sửa ID ${student.id} (giả lập).');
    });
  }

  @override
  Future<void> delete(int id) {
    return mapErrors('delete', () async {
      await _send('DELETE', '/users/$id');
      logInfo('API đã nhận yêu cầu xóa ID $id (giả lập).');
    });
  }
}
