import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Bundles a user + tokens as returned by auth endpoints.
class RemoteAuthResult {
  const RemoteAuthResult(this.user, this.tokens);
  final UserModel user;
  final AuthTokensModel tokens;
}

/// Talks to the backend auth API over Dio. Throws typed [Exception]s that the
/// repository maps to [Failure]s.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);
  final Dio _dio;

  Future<RemoteAuthResult> register({
    required String email,
    required String password,
    String? name,
  }) =>
      _authCall(ApiConstants.register, {
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      });

  Future<RemoteAuthResult> login({
    required String email,
    required String password,
  }) =>
      _authCall(ApiConstants.login, {'email': email, 'password': password});

  Future<RemoteAuthResult> oauthGoogle(String idToken) =>
      _authCall(ApiConstants.googleOAuth, {'idToken': idToken});

  Future<RemoteAuthResult> oauthApple({
    required String identityToken,
    String? authorizationCode,
    String? name,
  }) =>
      _authCall(ApiConstants.appleOAuth, {
        'identityToken': identityToken,
        if (authorizationCode != null) 'authorizationCode': authorizationCode,
        if (name != null) 'name': name,
      });

  Future<void> sendOtp(String phoneNumber) async {
    await _guard(() => _dio.post<Map<String, dynamic>>(
          ApiConstants.otpSend,
          data: {'phone': phoneNumber},
        ));
  }

  Future<RemoteAuthResult> verifyOtp({
    required String phoneNumber,
    required String code,
  }) =>
      _authCall(ApiConstants.otpVerify, {'phone': phoneNumber, 'code': code});

  Future<AuthTokensModel> refresh(String refreshToken) async {
    final response = await _guard(() => _dio.post<Map<String, dynamic>>(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        ));
    return AuthTokensModel.fromJson(_dataMap(response));
  }

  Future<void> forgotPassword(String email) async {
    await _guard(() => _dio.post<Map<String, dynamic>>(
          ApiConstants.forgotPassword,
          data: {'email': email},
        ));
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _guard(() => _dio.post<Map<String, dynamic>>(
          ApiConstants.resetPassword,
          data: {'token': token, 'password': newPassword},
        ));
  }

  Future<void> logout() async {
    // Best-effort server-side revocation; ignore failures.
    try {
      await _dio.post<Map<String, dynamic>>(ApiConstants.logout);
    } on DioException {
      // Local logout still proceeds in the repository.
    }
  }

  // --- helpers ------------------------------------------------------------

  Future<RemoteAuthResult> _authCall(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _guard(
      () => _dio.post<Map<String, dynamic>>(path, data: body),
    );
    final data = _dataMap(response);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final tokens = AuthTokensModel.fromJson(
      (data['tokens'] as Map<String, dynamic>?) ?? data,
    );
    return RemoteAuthResult(user, tokens);
  }

  Map<String, dynamic> _dataMap(Response<Map<String, dynamic>> response) {
    final body = response.data ?? const {};
    final data = body['data'];
    return (data is Map<String, dynamic>) ? data : body;
  }

  Future<Response<Map<String, dynamic>>> _guard(
    Future<Response<Map<String, dynamic>>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException();
    }
    final status = e.response?.statusCode;
    final message = _extractMessage(e.response?.data) ??
        e.message ??
        'Unexpected server error';
    if (status == 401) return UnauthorizedException(message);
    return ServerException(message, statusCode: status);
  }

  String? _extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String) return message;
    }
    return null;
  }
}
