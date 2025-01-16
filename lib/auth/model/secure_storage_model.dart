import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageModel {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// userId 존재 여부 확인 메서드
  Future<bool> isUserLoggedIn() async {
    final userId = await _storage.read(key: 'userId');
    return userId != null;
  }
}
