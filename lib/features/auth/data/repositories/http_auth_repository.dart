import 'package:domify_tool/core/error/failure.dart';
import 'package:domify_tool/core/session/token_store.dart';
import 'package:domify_tool/features/auth/data/sources/auth_remote_source.dart';
import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';
import 'package:domify_tool/features/auth/domain/repositories/auth_repository.dart';

class HttpAuthRepository implements AuthRepository {
  const HttpAuthRepository(this._source, this._tokenStore);

  final AuthRemoteSource _source;
  final TokenStore _tokenStore;

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _source.login(email: email, password: password);
    await _tokenStore.save(
      accessToken: tokens.token,
      refreshToken: tokens.refreshToken,
    );
    try {
      return (await _source.profile()).toEntity();
    } on Object {
      await _tokenStore.clear();
      rethrow;
    }
  }

  @override
  Future<UserProfile?> restoreSession() async {
    if (await _tokenStore.readRefreshToken() == null) return null;
    try {
      return (await _source.profile()).toEntity();
    } on UnauthorizedFailure {
      await _tokenStore.clear();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _source.logout(await _tokenStore.readRefreshToken());
    } on Failure {
      // Deliberately swallowed: the promise is that this device ends up signed
      // out, and it does. The token dies on the server on its own.
    } finally {
      await _tokenStore.clear();
    }
  }
}
