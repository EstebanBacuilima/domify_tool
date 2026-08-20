/// Build-time configuration, injected with `--dart-define-from-file`.
///
/// Values are compile-time constants, so a missing key is an empty string and
/// never an error. [ensureValid] turns that silence into a failure at startup,
/// where the cause is obvious, instead of a confusing network error once the
/// first request goes out.
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static void ensureValid() {
    if (apiBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is empty. Launch with '
        '--dart-define-from-file=config/dev.json '
        '(copy config/dev.example.json if you do not have that file yet).',
      );
    }
    if (!apiBaseUrl.endsWith('/')) {
      throw StateError('API_BASE_URL must end with a slash: $apiBaseUrl');
    }
  }
}
