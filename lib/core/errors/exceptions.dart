/// Low-level exceptions thrown by data sources. Repositories translate these
/// into [Failure]s for the domain layer.
library;

class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);
  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Unauthorized']);
  final String message;
}

class AuthProviderException implements Exception {
  const AuthProviderException(this.message);
  final String message;
}

/// Raised when the user cancels a social / biometric flow.
class CancelledException implements Exception {
  const CancelledException([this.message = 'Operation cancelled']);
  final String message;
}
