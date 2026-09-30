import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domify_tool/core/error/failure.dart';
import 'package:domify_tool/core/session/in_memory_token_store.dart';
import 'package:domify_tool/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';
import 'package:domify_tool/features/auth/domain/repositories/auth_repository.dart';
import 'package:domify_tool/features/auth/presentation/cubit/login_cubit.dart';
import 'package:domify_tool/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthRepository repository;
  late _CountingAuthRepository counting;

  setUp(() {
    counting = _CountingAuthRepository();
    repository = FakeAuthRepository(
      InMemoryTokenStore(),
      latency: Duration.zero,
    );
  });

  blocTest<LoginCubit, LoginState>(
    'good credentials go submitting then success',
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn(
      email: FakeAuthRepository.validEmail,
      password: FakeAuthRepository.validPassword,
    ),
    expect: () => [isA<LoginSubmitting>(), isA<LoginSuccess>()],
  );

  blocTest<LoginCubit, LoginState>(
    'bad credentials end on an error that carries the slug',
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn(
      email: FakeAuthRepository.validEmail,
      password: 'wrong',
    ),
    expect: () => [
      isA<LoginSubmitting>(),
      const LoginError(ApiFailure('invalid-credentials')),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'the error survives instead of being overwritten by a later emit',
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn(
      email: FakeAuthRepository.validEmail,
      password: 'wrong',
    ),
    verify: (cubit) => expect(cubit.state, isA<LoginError>()),
  );

  blocTest<LoginCubit, LoginState>(
    'no connection surfaces as its own failure, not as bad credentials',
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.signIn(
      email: FakeAuthRepository.offlineEmail,
      password: 'whatever',
    ),
    expect: () => [isA<LoginSubmitting>(), const LoginError(NetworkFailure())],
  );

  blocTest<LoginCubit, LoginState>(
    'a second tap while submitting sends only one login',
    build: () => LoginCubit(counting),
    act: (cubit) async {
      unawaited(cubit.signIn(email: 'a@b.c', password: 'x'));
      await cubit.signIn(email: 'a@b.c', password: 'x');
    },
    // Not asserted through the state sequence: Bloc drops an emit equal to the
    // current state, so a duplicate LoginSubmitting is invisible there. What
    // the guard actually prevents is the second request.
    verify: (_) => expect(counting.logins, 1),
  );
  test('two different failures are two different states', () {
    // Pins `props` on LoginError. Without it every error compares equal, Bloc
    // drops the second emit as a repeat, and the screen keeps showing "wrong
    // password" while the real problem is that there is no connection.
    expect(
      const LoginError(ApiFailure('invalid-credentials')),
      isNot(const LoginError(NetworkFailure())),
    );
  });
}

/// Counts how many times a login actually reaches the repository.
class _CountingAuthRepository implements AuthRepository {
  int logins = 0;

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    logins++;
    await Future<void>.delayed(Duration.zero);
    return const UserProfile(
      id: 1,
      code: 'USR-1',
      email: 'a@b.c',
      displayName: 'Test',
    );
  }

  @override
  Future<UserProfile?> restoreSession() async => null;

  @override
  Future<void> logout() async {}
}
