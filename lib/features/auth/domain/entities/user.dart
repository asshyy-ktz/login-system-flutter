import 'package:equatable/equatable.dart';

/// Core user entity used across the domain and presentation layers.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.isEmailVerified = false,
    this.provider = AuthProvider.password,
  });

  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final bool isEmailVerified;
  final AuthProvider provider;

  User copyWith({
    String? name,
    String? phone,
    String? avatarUrl,
    bool? isEmailVerified,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      provider: provider,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, name, phone, avatarUrl, isEmailVerified, provider];
}

enum AuthProvider { password, google, apple, phone }
