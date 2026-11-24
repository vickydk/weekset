import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_store.dart';

/// Tokens stay in the platform keystore.
class SecureTokenStore implements TokenStore {
  const SecureTokenStore();

  static const _access = 'access_token';
  static const _refresh = 'refresh_token';
  static const _storage = FlutterSecureStorage();

  @override
  Future<void> clear() => _storage.deleteAll();

  @override
  Future<StoredTokens?> read() async {
    final access = await _storage.read(key: _access);
    final refresh = await _storage.read(key: _refresh);
    if (access == null || refresh == null) return null;
    return StoredTokens(access: access, refresh: refresh);
  }

  @override
  Future<void> write(StoredTokens tokens) async {
    await _storage.write(key: _access, value: tokens.access);
    await _storage.write(key: _refresh, value: tokens.refresh);
  }
}
