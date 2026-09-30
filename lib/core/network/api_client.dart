import 'package:dio/dio.dart';
import 'package:domify_tool/core/config/env.dart';
import 'package:domify_tool/core/error/failure.dart';
import 'package:domify_tool/core/network/api_response.dart';
import 'package:domify_tool/core/network/failure_mapper.dart';

/// Builds the single [Dio] the whole app shares.
Dio createDio({List<Interceptor> interceptors = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.addAll(interceptors);
  return dio;
}

/// Speaks the API's envelope so no feature has to.
///
/// Every method answers the unwrapped `data` or throws a [Failure], which is
/// why the sources on top of it read like plain function calls.
///
/// Paths must be relative (`auth/login`, not `/auth/login`): a leading slash
/// makes Dio drop the `/api/v1/` of the base URL and the call silently goes
/// somewhere else.
class ApiClient {
  const ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic> data) read,
    Map<String, dynamic>? query,
  }) => _read(
    () => _dio.get<Map<String, dynamic>>(path, queryParameters: query),
    read,
  );

  Future<T> post<T>(
    String path, {
    required T Function(Map<String, dynamic> data) read,
    Map<String, dynamic>? body,
  }) => _read(() => _dio.post<Map<String, dynamic>>(path, data: body), read);

  /// For endpoints whose envelope carries a null `data`, such as logout.
  Future<void> postWithoutData(String path, {Map<String, dynamic>? body}) async {
    try {
      await _dio.post<Map<String, dynamic>>(path, data: body);
    } on DioException catch (exception) {
      throw mapDioException(exception);
    }
  }

  Future<T> _read<T>(
    Future<Response<Map<String, dynamic>>> Function() call,
    T Function(Map<String, dynamic> data) read,
  ) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await call();
    } on DioException catch (exception) {
      throw mapDioException(exception);
    }

    try {
      final body = response.data;
      if (body == null) throw const UnknownFailure();
      final data = ApiResponse.fromJson(body, read).data;
      if (data == null) throw const UnknownFailure();
      return data;
    } on Failure {
      rethrow;
    } on Object {
      // A 2xx whose shape is not what we parse: a bad deploy or a changed
      // contract. Typed, so the UI can still paint something.
      throw const UnknownFailure();
    }
  }
}
