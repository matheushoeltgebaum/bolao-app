import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class StorageRepository {
  Future<String?> read();

  Future<void> save(String jwt);

  Future<void> clear();
}

class FakeStorageRepository implements StorageRepository {
  FakeStorageRepository({required this.storage});

  final FlutterSecureStorage storage;
  static const _key = "jwt";

  String? _cachedJwt;

  @override
  Future<String?> read() async {
    if (_cachedJwt != null) return _cachedJwt;
    final json = await storage.read(key: _key);
    if (json == null) {
      return null;
    }

    try {
      return _cachedJwt = json;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(String jwt) {
    _cachedJwt = jwt;
    return storage.write(key: _key, value: jwt);
  }

  @override
  Future<void> clear() {
    _cachedJwt = null;
    return storage.delete(key: _key);
  }
}
