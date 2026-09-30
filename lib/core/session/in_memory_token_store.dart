import 'package:domify_tool/core/session/token_store.dart';

/// A [TokenStore] that forgets everything when the process dies.
///
/// Pairs with the fake repository while there is no backend, and stands in for
/// secure storage in tests, where platform channels are not available.
class InMemoryTokenStore implements TokenStore {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> readAccessToken() async => _accessToken;

  @override
  Future<String?> readRefreshToken() async => _refreshToken;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
  }
}
