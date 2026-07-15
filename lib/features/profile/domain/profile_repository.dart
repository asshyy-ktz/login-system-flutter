import '../../../core/utils/result.dart';
import '../../auth/domain/entities/user.dart';

abstract interface class ProfileRepository {
  Future<Result<User>> getProfile();

  Future<Result<User>> updateProfile({String? name, String? phone});

  Future<Result<User>> uploadAvatar(String filePath);

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<void>> deleteAccount(String password);
}
