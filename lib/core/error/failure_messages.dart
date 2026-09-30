import 'package:domify_tool/core/error/failure.dart';

const String _fallback = 'Algo salió mal. Inténtalo de nuevo.';

/// Backend slugs messages
const Map<String, String> _slugMessages = {
  'invalid-credentials': 'Correo o contraseña incorrectos.',
  'username-required': 'Escribe tu correo.',
  'password-required': 'Escribe tu contraseña.',
  'invalid-refresh-token': 'Tu sesión caducó. Vuelve a entrar.',
  'user-not-found': 'No encontramos esa cuenta.',
  'validation-error': 'Revisa los datos e inténtalo de nuevo.',
  'unauthorized': 'Tu sesión caducó. Vuelve a entrar.',
  'invalid-route-or-path': 'Esa función no está disponible en esta versión.',
};

/// Turns a [Failure] into text for the user.
///
/// Lives here and not in the widgets so the same wording is not rewritten on
/// every screen. It moves into the l10n files the day the app is translated.
extension FailureMessage on Failure {
  String get message => switch (this) {
    NetworkFailure() =>
      'Sin conexión. Revisa tu internet e inténtalo de nuevo.',
    TimeoutFailure() => 'El servidor tardó demasiado en responder.',
    UnauthorizedFailure() => 'Tu sesión caducó. Vuelve a entrar.',
    ServerFailure() => 'Hubo un problema en el servidor. Inténtalo más tarde.',
    ApiFailure(:final code) => _slugMessages[code] ?? _fallback,
    UnknownFailure() => _fallback,
  };
}
