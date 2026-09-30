import 'package:dio/dio.dart';
import 'package:domify_tool/core/error/failure.dart';

/// Turns what Dio throws into the [Failure] the UI knows how to paint.
Failure mapDioException(DioException exception) => switch (exception.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout => const TimeoutFailure(),
  DioExceptionType.connectionError => const NetworkFailure(),
  DioExceptionType.badResponse => _fromResponse(exception.response),
  _ => const UnknownFailure(),
};

Failure _fromResponse(Response<dynamic>? response) {
  final status = response?.statusCode ?? 0;

  // Both 401 slugs mean the same thing here: this session is over. Telling
  // `unauthorized` from `invalid-refresh-token` only matters to the
  // interceptor, which decides whether retrying is worth it.
  if (status == 401) return const UnauthorizedFailure();
  if (status >= 500) return const ServerFailure();

  final slug = slugOf(response?.data);
  return slug == null ? const UnknownFailure() : ApiFailure(slug);
}

/// Reads the envelope's `message`, which the API uses as an error code.
///
/// Returns null when the body is not the envelope at all, which happens with
/// a proxy error page or a plain-text response.
String? slugOf(dynamic data) =>
    data is Map<String, dynamic> ? data['message'] as String? : null;
