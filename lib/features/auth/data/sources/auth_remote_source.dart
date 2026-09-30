import 'package:domify_tool/core/network/api_client.dart';
import 'package:domify_tool/features/auth/data/models/auth_tokens_dto.dart';
import 'package:domify_tool/features/auth/data/models/user_profile_dto.dart';

class AuthRemoteSource {
  const AuthRemoteSource(this._client);

  final ApiClient _client;

  Future<AuthTokensDto> login({
    required String email,
    required String password,
  }) {
    return _client.post(
      'auth/login',
      body: {'username': email, 'password': password},
      read: AuthTokensDto.fromJson,
    );
  }

  Future<UserProfileDto> profile() {
    return _client.get('users/me', read: UserProfileDto.fromJson);
  }

  Future<AuthTokensDto> refresh(String refreshToken) => _client.post(
    'auth/refresh-token',
    body: {'refreshToken': refreshToken},
    read: AuthTokensDto.fromJson,
  );

  Future<void> logout(String? refreshToken) => _client.postWithoutData(
    'auth/logout',
    body: {'refreshToken': refreshToken},
  );
}
