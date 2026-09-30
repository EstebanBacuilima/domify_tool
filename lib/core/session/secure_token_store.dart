import 'package:domify_tool/core/session/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A [TokenStore] backed by the Keychain on iOS and EncryptedSharedPreferences
/// on Android, so the session survives the app being closed.
class SecureTokenStore implements TokenStore {
  const SecureTokenStore(this._storage);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    // Refresh token last: it is the one that can rebuild a session, so if the
    // process dies mid-write the leftover is the useless half.
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
