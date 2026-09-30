import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:domify_tool/core/network/auth_interceptor.dart';
import 'package:domify_tool/core/session/in_memory_token_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers whatever the test tells it to, without touching the network.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.onFetch);

  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => onFetch(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody _unauthorized(String slug) =>
    _json(401, {'status': 401, 'message': slug, 'data': null});

ResponseBody _ok() =>
    _json(200, {'status': 200, 'message': 'successful', 'data': <String, dynamic>{}});

void main() {
  late InMemoryTokenStore store;
  late Dio dio;
  late int refreshCalls;

  /// Builds a Dio whose `/me` only accepts [goodToken].
  void buildDio({
    required String goodToken,
    required Future<({String accessToken, String refreshToken})> Function(String)
    refresher,
  }) {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1/'));
    dio.httpClientAdapter = _FakeAdapter((options) async {
      final sent = options.headers['Authorization'];
      if (sent == 'Bearer $goodToken') return _ok();
      return _unauthorized('unauthorized');
    });
    dio.interceptors.add(AuthInterceptor(dio, store, refresher));
  }

  setUp(() {
    store = InMemoryTokenStore();
    refreshCalls = 0;
  });

  test('three requests failing at once renew the session only once', () async {
    buildDio(
      goodToken: 'new-access',
      refresher: (refreshToken) async {
        refreshCalls++;
        // Wide enough that the other two arrive while this one is in flight.
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return (accessToken: 'new-access', refreshToken: 'new-refresh');
      },
    );
    await store.save(accessToken: 'expired', refreshToken: 'old-refresh');

    final responses = await Future.wait([
      dio.get<dynamic>('users/me'),
      dio.get<dynamic>('users/me'),
      dio.get<dynamic>('users/me'),
    ]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    // The whole point: a second renewal would replay a rotated token and the
    // API would revoke every session the user has.
    expect(refreshCalls, 1);
    expect(await store.readAccessToken(), 'new-access');
    expect(await store.readRefreshToken(), 'new-refresh');
  });

  test('a dead refresh token is not retried, and the session is dropped',
      () async {
    dio = Dio(BaseOptions(baseUrl: 'http://x/api/v1/'));
    dio.httpClientAdapter = _FakeAdapter(
      (options) async => _unauthorized('invalid-refresh-token'),
    );
    dio.interceptors.add(
      AuthInterceptor(dio, store, (_) async {
        refreshCalls++;
        return (accessToken: 'a', refreshToken: 'b');
      }),
    );
    await store.save(accessToken: 'expired', refreshToken: 'dead-refresh');

    await expectLater(dio.get<dynamic>('users/me'), throwsA(isA<DioException>()));
    // Retrying here would burn the token again for nothing.
    expect(refreshCalls, 0);
  });

  test('a failed renewal clears the store', () async {
    buildDio(
      goodToken: 'never',
      refresher: (_) async {
        refreshCalls++;
        throw Exception('refresh rejected');
      },
    );
    await store.save(accessToken: 'expired', refreshToken: 'old-refresh');

    await expectLater(dio.get<dynamic>('users/me'), throwsA(isA<DioException>()));
    expect(refreshCalls, 1);
    expect(await store.readRefreshToken(), isNull);
  });

  test('the renewal endpoint itself never triggers a renewal', () async {
    buildDio(
      goodToken: 'never',
      refresher: (_) async {
        refreshCalls++;
        return (accessToken: 'a', refreshToken: 'b');
      },
    );
    await store.save(accessToken: 'expired', refreshToken: 'old-refresh');

    await expectLater(
      dio.post<dynamic>('auth/refresh-token'),
      throwsA(isA<DioException>()),
    );
    expect(refreshCalls, 0);
  });
}
