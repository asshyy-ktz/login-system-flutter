/// Envelope matching the backend's `{ data, message, success }` shape.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.data,
    this.message,
  });

  final bool success;
  final T? data;
  final String? message;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data) parse,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      data: json.containsKey('data') ? parse(json['data']) : null,
      message: json['message'] as String?,
    );
  }
}
