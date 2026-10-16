import 'dart:async';

import '../../domain/entities/student.dart';
import '../../domain/repositories/student_repository.dart';

/// Decorator: boc mot StudentRepository that, them do tre cua mang
/// va cong tac gia lap mat ket noi. Khong can sua code cua repository ben trong.
class SimulatedNetworkRepository extends StudentRepository {
  SimulatedNetworkRepository(
    this._inner, {
    this.latency = const Duration(milliseconds: 300),
  });

  final StudentRepository _inner;

  /// Thoi gian cho moi lan "goi mang".
  final Duration latency;

  /// Bat len de gia lap mat mang.
  bool isOffline = false;

  /// Gia lap mot lan goi mang: cho mot chut, neu offline thi bao loi.
  Future<void> _callNetwork() async {
    await Future<void>.delayed(latency);
    if (isOffline) {
      throw TimeoutException('Mat ket noi mang (gia lap).', latency);
    }
  }

  @override
  Future<List<Student>> getAll() async {
    await _callNetwork();
    return _inner.getAll();
  }

  @override
  Future<Student> getById(String id) async {
    await _callNetwork();
    return _inner.getById(id);
  }

  @override
  Future<void> add(Student entity) async {
    await _callNetwork();
    return _inner.add(entity);
  }

  @override
  Future<void> update(Student entity) async {
    await _callNetwork();
    return _inner.update(entity);
  }

  @override
  Future<void> delete(String id) async {
    await _callNetwork();
    return _inner.delete(id);
  }

  @override
  Future<List<Student>> findByName(String keyword) async {
    await _callNetwork();
    return _inner.findByName(keyword);
  }
}