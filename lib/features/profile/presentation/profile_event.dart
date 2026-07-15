part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

class ProfileUpdated extends ProfileEvent {
  const ProfileUpdated({this.name, this.phone});
  final String? name;
  final String? phone;

  @override
  List<Object?> get props => [name, phone];
}

class ProfileAvatarChanged extends ProfileEvent {
  const ProfileAvatarChanged(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

class ProfilePasswordChanged extends ProfileEvent {
  const ProfilePasswordChanged({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ProfileDeleted extends ProfileEvent {
  const ProfileDeleted(this.password);
  final String password;

  @override
  List<Object?> get props => [password];
}
