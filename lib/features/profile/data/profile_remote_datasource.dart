import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../auth/data/models/user_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._dio);
  final Dio _dio;

  Future<UserModel> getProfile() async {
    final response = await _guard(
      () => _dio.get<Map<String, dynamic>>(ApiConstants.profile),
    );
    return UserModel.fromJson(_dataMap(response));
  }

  Future<UserModel> updateProfile({String? name, String? phone}) async {
    final response = await _guard(
      () => _dio.put<Map<String, dynamic>>(
        ApiConstants.updateProfile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      ),
    );
    return UserModel.fromJson(_dataMap(response));
  }

  Future<UserModel> uploadAvatar(String filePath) async {
    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final response = await _guard(
      () => _dio.post<Map<String, dynamic>>(
        ApiConstants.uploadAvatar,
        data: form,
      ),
    );
    return UserModel.fromJson(_dataMap(response));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _guard(
      () => _dio.post<Map<String, dynamic>>(
        ApiConstants.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      ),
    );
  }

  Future<void> deleteAccount(String password) async {
    await _guard(
      () => _dio.delete<Map<String, dynamic>>(
        ApiConstants.deleteAccount,
        data: {'password': password},
      ),
    );
  }

  // --- helpers ------------------------------------------------------------

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
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw const NetworkException();
      }
      final message = _message(e.response?.data) ?? e.message ?? 'Server error';
      throw ServerException(message, statusCode: e.response?.statusCode);
    }
  }

  String? _message(Object? data) {
    if (data is Map<String, dynamic>) {
      final m = data['message'] ?? data['error'];
      if (m is String) return m;
    }
    return null;
  }
}
