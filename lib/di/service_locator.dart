import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/secure_storage.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/biometric_datasource.dart';
import '../features/auth/data/datasources/social_auth_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/login_cubit.dart';
import '../features/auth/presentation/bloc/otp_cubit.dart';
import '../features/auth/presentation/bloc/password_cubit.dart';
import '../features/auth/presentation/bloc/register_cubit.dart';
import '../features/profile/data/profile_remote_datasource.dart';
import '../features/profile/data/profile_repository_impl.dart';
import '../features/profile/domain/profile_repository.dart';
import '../features/profile/presentation/profile_bloc.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Wires up the object graph. Call once before `runApp`.
Future<void> configureDependencies() async {
  // --- external / platform singletons ---
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    )
    ..registerLazySingleton<SecureStorage>(() => SecureStorage(sl()))
    ..registerLazySingleton<LocalStorage>(() => LocalStorage(sl()));

  // --- networking ---
  sl
    ..registerLazySingleton<DioClient>(
      () => DioClient(
        storage: sl<SecureStorage>(),
        // On refresh failure, force a global logout. Resolved lazily to avoid
        // a construction-time cycle with AuthBloc.
        onSessionExpired: () async {
          if (sl.isRegistered<AuthBloc>()) {
            sl<AuthBloc>().add(const AuthLogoutRequested());
          }
        },
      ),
    )
    ..registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // --- data sources ---
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(sl()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSource(
        secureStorage: sl(),
        localStorage: sl(),
      ),
    )
    ..registerLazySingleton<SocialAuthDataSource>(() => SocialAuthDataSource())
    ..registerLazySingleton<BiometricDataSource>(() => BiometricDataSource())
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(sl()),
    );

  // --- repositories ---
  sl
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: sl(),
        local: sl(),
        social: sl(),
        biometric: sl(),
      ),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remote: sl(), local: sl()),
    );

  // --- use cases ---
  sl
    ..registerLazySingleton(() => RegisterUseCase(sl()))
    ..registerLazySingleton(() => LoginUseCase(sl()))
    ..registerLazySingleton(() => GoogleSignInUseCase(sl()))
    ..registerLazySingleton(() => AppleSignInUseCase(sl()))
    ..registerLazySingleton(() => SendOtpUseCase(sl()))
    ..registerLazySingleton(() => VerifyOtpUseCase(sl()))
    ..registerLazySingleton(() => RefreshTokenUseCase(sl()))
    ..registerLazySingleton(() => ForgotPasswordUseCase(sl()))
    ..registerLazySingleton(() => ResetPasswordUseCase(sl()))
    ..registerLazySingleton(() => LogoutUseCase(sl()))
    ..registerLazySingleton(() => CheckAuthStatusUseCase(sl()))
    ..registerLazySingleton(() => BiometricLoginUseCase(sl()));

  // --- blocs / cubits ---
  sl
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        checkAuthStatus: sl(),
        logout: sl(),
        biometricLogin: sl(),
      ),
    )
    ..registerFactory<LoginCubit>(
      () => LoginCubit(login: sl(), googleSignIn: sl(), appleSignIn: sl()),
    )
    ..registerFactory<RegisterCubit>(() => RegisterCubit(register: sl()))
    ..registerFactory<OtpCubit>(
      () => OtpCubit(sendOtp: sl(), verifyOtp: sl()),
    )
    ..registerFactory<PasswordCubit>(
      () => PasswordCubit(forgotPassword: sl(), resetPassword: sl()),
    )
    ..registerFactory<ProfileBloc>(() => ProfileBloc(repository: sl()));
}
