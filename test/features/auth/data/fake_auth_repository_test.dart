import 'package:domify_tool/core/error/failure.dart';
import 'package:domify_tool/core/session/in_memory_token_store.dart';
import 'package:domify_tool/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryTokenStore store;
  late FakeAuthRepository repository;

  setUp(() {
    store = InMemoryTokenStore();
    repository = FakeAuthRepository(store, latency: Duration.zero);
  });

  test('a successful login leaves both tokens stored', () async {
    final user = await repository.login(
      email: FakeAuthRepository.validEmail,
      password: FakeAuthRepository.validPassword,
    );

    expect(user.email, FakeAuthRepository.validEmail);
    expect(await store.readAccessToken(), isNotNull);
    expect(await store.readRefreshToken(), isNotNull);
  });

  test('a rejected login stores nothing', () async {
    await expectLater(
      repository.login(
        email: FakeAuthRepository.validEmail,
        password: 'wrong',
      ),
      throwsA(const ApiFailure('invalid-credentials')),
    );

    // The silent one: storing on the failing path would keep the app
    // "signed in" with credentials the server never accepted.
    expect(await store.readAccessToken(), isNull);
    expect(await store.readRefreshToken(), isNull);
  });

  test('restoreSession answers null when nothing was ever stored', () async {
    expect(await repository.restoreSession(), isNull);
  });

  test('restoreSession answers the user once a login stored a session',
      () async {
    await repository.login(
      email: FakeAuthRepository.validEmail,
      password: FakeAuthRepository.validPassword,
    );

    expect(await repository.restoreSession(), isNotNull);
  });

  test('logout empties the store', () async {
    await repository.login(
      email: FakeAuthRepository.validEmail,
      password: FakeAuthRepository.validPassword,
    );

    await repository.logout();

    expect(await store.readRefreshToken(), isNull);
    expect(await repository.restoreSession(), isNull);
  });
}
