import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/utils/result.dart';
import '../../auth/data/datasources/auth_local_datasource.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/domain/entities/user.dart';
import '../domain/profile_repository.dart';
import 'profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final ProfileRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Result<User>> getProfile() => _userCall(_remote.getProfile);

  @override
  Future<Result<User>> updateProfile({String? name, String? phone}) =>
      _userCall(() => _remote.updateProfile(name: name, phone: phone));

  @override
  Future<Result<User>> uploadAvatar(String filePath) =>
      _userCall(() => _remote.uploadAvatar(filePath));

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Success(null);
    } on Exception catch (e) {
      return Err(_map(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String password) async {
    try {
      await _remote.deleteAccount(password);
      await _local.clear();
      return const Success(null);
    } on Exception catch (e) {
      return Err(_map(e));
    }
  }

  Future<Result<User>> _userCall(Future<UserModel> Function() call) async {
    try {
      final user = await call();
      // Keep the cached user in sync so auto-login reflects edits.
      await _local.cacheUser(user);
      return Success(user);
    } on Exception catch (e) {
      return Err(_map(e));
    }
  }

  Failure _map(Exception e) => switch (e) {
        NetworkException() => const NetworkFailure(),
        ServerException(:final message, :final statusCode) =>
          ServerFailure(message, statusCode: statusCode),
        _ => ServerFailure(e.toString()),
      };
}
