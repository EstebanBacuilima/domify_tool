/// The envelope every `tool_core_backend` endpoint answers with.
///
/// Errors reuse it with a null `data` and a machine-readable `message`, so the
/// caller reads [message] as a code and never as text for the user.
class ApiResponse<T> {
  const ApiResponse({required this.status, required this.message, this.data});

  /// [readData] parses `data`, because a generic cannot call `T.fromJson`.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> data) readData,
  ) {
    final data = json['data'];
    return ApiResponse<T>(
      status: json['status'] as int,
      message: json['message'] as String,
      data: data == null ? null : readData(data as Map<String, dynamic>),
    );
  }

  final int status;
  final String message;
  final T? data;
}
