import 'package:equatable/equatable.dart';

/// Everything that can go wrong on the way to the API.
///
/// Thrown by the repositories and caught in the cubits: a sealed exception
/// keeps `try`/`catch` idiomatic and avoids pulling in an `Either` package.
sealed class Failure extends Equatable implements Exception {
  const Failure();

  @override
  List<Object?> get props => [];
}

/// The request never reached the server.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure();
}

/// 401: the access token is missing, expired or rejected.
///
/// Separate from [ApiFailure] because this is the only one that means "send
/// the user back to login". Wrong credentials arrive as a 400 instead.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure();
}

/// The backend refused the request with one of its slugs.
final class ApiFailure extends Failure {
  const ApiFailure(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

final class ServerFailure extends Failure {
  const ServerFailure();
}

final class UnknownFailure extends Failure {
  const UnknownFailure();
}
