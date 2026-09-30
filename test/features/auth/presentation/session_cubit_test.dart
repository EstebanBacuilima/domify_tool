import 'package:bloc_test/bloc_test.dart';
import 'package:domify_tool/core/session/in_memory_token_store.dart';
import 'package:domify_tool/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:domify_tool/features/auth/presentation/cubit/session_cubit.dart';
import 'package:domify_tool/features/auth/presentation/cubit/session_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryTokenStore store;
  late FakeAuthRepository repository;

  setUp(() {
    store = InMemoryTokenStore();
    repository = FakeAuthRepository(store, latency: Duration.zero);
  });

  Future<void> signIn() => repository.login(
    email: FakeAuthRepository.validEmail,
    password: FakeAuthRepository.validPassword,
  );

  blocTest<SessionCubit, SessionState>(
    'a first launch with nothing stored ends closed',
    build: () => SessionCubit(repository),
    act: (cubit) => cubit.start(),
    expect: () => [isA<SessionClosed>()],
  );

  blocTest<SessionCubit, SessionState>(
    'a launch with a usable session ends active',
    setUp: signIn,
    build: () => SessionCubit(repository),
    act: (cubit) => cubit.start(),
    expect: () => [isA<SessionActive>()],
  );

  blocTest<SessionCubit, SessionState>(
    'signing out closes the session and empties the store',
    setUp: signIn,
    build: () => SessionCubit(repository),
    act: (cubit) async {
      await cubit.start();
      await cubit.signOut();
    },
    expect: () => [isA<SessionActive>(), isA<SessionClosed>()],
    verify: (_) async => expect(await store.readRefreshToken(), isNull),
  );
}
