import 'dart:async';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

/// Attaches the access token to every request and transparently refreshes it on
/// a 401, queuing concurrent requests until the refresh completes.
///
/// A dedicated bare [Dio] (no interceptors) performs the refresh call to avoid
/// infinite recursion.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required SecureStorage storage,
    required Dio tokenDio,
    required this.onSessionExpired,
  })  : _storage = storage,
        _tokenDio = tokenDio;

  final SecureStorage _storage;
  final Dio _tokenDio;

  /// Called when the refresh token is invalid/expired — the app should clear
  /// state and route to login.
  final Future<void> Function() onSessionExpired;

  bool _isRefreshing = false;
  final List<_QueuedRequest> _queue = [];

  static const List<String> _skipAuthPaths = [
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.refresh,
    ApiConstants.googleOAuth,
    ApiConstants.appleOAuth,
    ApiConstants.otpSend,
    ApiConstants.otpVerify,
    ApiConstants.forgotPassword,
    ApiConstants.resetPassword,
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_skipAuthPaths.contains(options.path)) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthError = err.response?.statusCode == 401;
    final isRefreshCall = err.requestOptions.path == ApiConstants.refresh;

    if (!isAuthError || isRefreshCall) {
      return handler.next(err);
    }

    // Queue this request while a refresh is in flight (or being started).
    _queue.add(_QueuedRequest(err.requestOptions, handler));
    if (_isRefreshing) return;

    _isRefreshing = true;
    final refreshed = await _performRefresh();
    _isRefreshing = false;

    if (refreshed) {
      await _replayQueue();
    } else {
      _rejectQueue(err);
      await onSessionExpired();
    }
  }

  Future<bool> _performRefresh() async {
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _tokenDio.post<Map<String, dynamic>>(
        '${ApiConstants.baseUrl}${ApiConstants.refresh}',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data?['data'] as Map<String, dynamic>? ??
          response.data ??
          const {};
      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;
      if (access == null) return false;

      await _storage.writeAccessToken(access);
      if (refresh != null) await _storage.writeRefreshToken(refresh);
      return true;
    } on DioException {
      return false;
    }
  }

  Future<void> _replayQueue() async {
    final pending = List<_QueuedRequest>.from(_queue);
    _queue.clear();
    final token = await _storage.readAccessToken();

    for (final queued in pending) {
      final options = queued.options;
      options.headers['Authorization'] = 'Bearer $token';
      try {
        final response = await _tokenDio.fetch<dynamic>(options);
        queued.handler.resolve(response);
      } on DioException catch (e) {
        queued.handler.next(e);
      }
    }
  }

  void _rejectQueue(DioException err) {
    final pending = List<_QueuedRequest>.from(_queue);
    _queue.clear();
    for (final queued in pending) {
      queued.handler.next(err);
    }
  }
}

class _QueuedRequest {
  _QueuedRequest(this.options, this.handler);
  final RequestOptions options;
  final ErrorInterceptorHandler handler;
}

/// Lightweight logger; avoids `print` (lint) via `dart:developer` in real use.
class LoggingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Hook for crash reporting / analytics. Intentionally silent by default.
    handler.next(err);
  }
}
