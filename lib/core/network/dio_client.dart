import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import 'interceptors.dart';

/// Builds the app's configured [Dio] instance with the auth/refresh interceptor.
class DioClient {
  DioClient({
    required SecureStorage storage,
    required Future<void> Function() onSessionExpired,
  }) {
    _dio = Dio(_baseOptions());
    // Bare Dio used only for the refresh call and queued replays.
    final tokenDio = Dio(_baseOptions());

    _dio.interceptors.addAll([
      AuthInterceptor(
        storage: storage,
        tokenDio: tokenDio,
        onSessionExpired: onSessionExpired,
      ),
      LoggingInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  BaseOptions _baseOptions() => BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      );
}
