import 'package:domify_tool/core/error/failure.dart';
import 'package:domify_tool/core/session/token_store.dart';
import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';
import 'package:domify_tool/features/auth/domain/repositories/auth_repository.dart';

/// An [AuthRepository] with no backend behind it.
///
/// Lets the login screen be finished before the API is reachable, and stays on
/// afterwards as the double the cubit tests run against. It does not simulate
/// token rotation: nothing here rotates, so the replay rules the real backend
/// enforces cannot be exercised from this one.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._tokenStore, {this.latency = _defaultLatency});

  static const Duration _defaultLatency = Duration(milliseconds: 700);

  /// The account that works. Anything else is rejected.
  static const String validEmail = 'admin@domify.com';
  static const String validPassword = '123456';

  /// Signing in with this one throws [NetworkFailure], so the "no signal"
  /// branch of the UI can be seen without turning off the wifi.
  static const String offlineEmail = 'offline@domify.com';

  static const UserProfile _user = UserProfile(
    id: 1,
    code: 'USR-1',
    email: validEmail,
    displayName: 'David Bacuilima',
  );

  final TokenStore _tokenStore;

  /// Long enough that the spinner is visible instead of a flicker.
  final Duration latency;

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);

    if (email == offlineEmail) throw const NetworkFailure();

    if (email != validEmail || password != validPassword) {
      throw const ApiFailure('invalid-credentials');
    }

    await _tokenStore.save(
      accessToken: 'fake-access-token',
      refreshToken: 'fake-refresh-token',
    );
    return _user;
  }

  @override
  Future<UserProfile?> restoreSession() async {
    await Future<void>.delayed(latency);
    if (await _tokenStore.readRefreshToken() == null) return null;
    return _user;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(latency);
    await _tokenStore.clear();
  }
}
