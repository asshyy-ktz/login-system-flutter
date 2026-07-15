part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, saving, failure, deleted }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.message,
  });

  final ProfileStatus status;
  final User? user;
  final String? message;

  ProfileState copyWith({
    ProfileStatus? status,
    User? user,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
