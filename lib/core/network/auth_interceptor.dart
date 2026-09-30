import 'package:dio/dio.dart';
import 'package:domify_tool/core/network/failure_mapper.dart';
import 'package:domify_tool/core/session/token_store.dart';

/// Exchanges a refresh token for a fresh pair.
///
/// A function and not the auth source itself, so `core` keeps knowing nothing
/// about features or about which endpoint does this.
typedef TokenRefresher =
    Future<({String accessToken, String refreshToken})> Function(
      String refreshToken,
    );

/// Attaches the access token, and renews it once when the API says it expired.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._tokenStore, this._refresher);

  /// Endpoints that go out bare and must never trigger a renewal. Refreshing
  /// because the refresh call itself failed is an infinite loop.
  static const Set<String> _anonymousPaths = {
    'auth/login',
    'auth/register',
    'auth/refresh-token',
  };

  /// Marks a request that already came back from a renewal, so a second 401
  /// gives up instead of renewing forever.
  static const String _retriedFlag = 'auth_retried';

  final Dio _dio;
  final TokenStore _tokenStore;
  final TokenRefresher _refresher;

  /// The renewal in flight, shared by everyone who needs it.
  ///
  /// Without this, three requests failing at once fire three renewals, and the
  /// second one replays a token the first already rotated. The API reads that
  /// as a leak and revokes every session the user has.
  Future<String>? _inFlight;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_anonymousPaths.contains(options.path)) return handler.next(options);

    final accessToken = await _tokenStore.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRenew(err)) return handler.next(err);

    try {
      final accessToken = await _renewOnce();
      final options = err.requestOptions
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..extra[_retriedFlag] = true;
      return handler.resolve(await _dio.fetch<dynamic>(options));
    } on Object {
      // The session could not be renewed. The original 401 travels on and the
      // repository turns it into the failure that sends the user to login.
      return handler.next(err);
    }
  }

  bool _shouldRenew(DioException err) {
    if (err.response?.statusCode != 401) return false;
    if (_anonymousPaths.contains(err.requestOptions.path)) return false;
    if (err.requestOptions.extra[_retriedFlag] == true) return false;

    // `unauthorized` means the access token expired and renewing fixes it.
    // `invalid-refresh-token` means the session is over: retrying only burns
    // the token again.
    return slugOf(err.response?.data) != 'invalid-refresh-token';
  }

  Future<String> _renewOnce() =>
      _inFlight ??= _renew().whenComplete(() => _inFlight = null);

  Future<String> _renew() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null) throw StateError('no refresh token stored');

    try {
      final tokens = await _refresher(refreshToken);
      // Saved before anyone retries: the server killed the old refresh token
      // the moment it answered, so until this line the app holds a dead one.
      await _tokenStore.save(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens.accessToken;
    } on Object {
      await _tokenStore.clear();
      rethrow;
    }
  }
}
