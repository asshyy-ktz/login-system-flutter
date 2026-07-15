import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../auth/domain/entities/user.dart';
import '../domain/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState()) {
    on<ProfileLoaded>(_onLoaded);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileAvatarChanged>(_onAvatarChanged);
    on<ProfilePasswordChanged>(_onPasswordChanged);
    on<ProfileDeleted>(_onDeleted);
  }

  final ProfileRepository _repository;

  Future<void> _onLoaded(ProfileLoaded event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _repository.getProfile();
    result.fold(
      (f) => emit(state.copyWith(status: ProfileStatus.failure, message: f.message)),
      (user) => emit(state.copyWith(status: ProfileStatus.loaded, user: user)),
    );
  }

  Future<void> _onUpdated(ProfileUpdated event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    final result =
        await _repository.updateProfile(name: event.name, phone: event.phone);
    result.fold(
      (f) => emit(state.copyWith(status: ProfileStatus.failure, message: f.message)),
      (user) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        user: user,
        message: 'Profile updated',
      )),
    );
  }

  Future<void> _onAvatarChanged(
    ProfileAvatarChanged event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    final result = await _repository.uploadAvatar(event.filePath);
    result.fold(
      (f) => emit(state.copyWith(status: ProfileStatus.failure, message: f.message)),
      (user) => emit(state.copyWith(status: ProfileStatus.loaded, user: user)),
    );
  }

  Future<void> _onPasswordChanged(
    ProfilePasswordChanged event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    final result = await _repository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    result.fold(
      (f) => emit(state.copyWith(status: ProfileStatus.failure, message: f.message)),
      (_) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        message: 'Password changed',
      )),
    );
  }

  Future<void> _onDeleted(ProfileDeleted event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving));
    final result = await _repository.deleteAccount(event.password);
    result.fold(
      (f) => emit(state.copyWith(status: ProfileStatus.failure, message: f.message)),
      (_) => emit(state.copyWith(status: ProfileStatus.deleted)),
    );
  }
}
