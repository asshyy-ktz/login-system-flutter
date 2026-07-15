import 'dart:convert';

import '../../domain/entities/user.dart';

/// Data-layer representation of [User] with JSON (de)serialisation.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.phone,
    super.avatarUrl,
    super.isEmailVerified,
    super.provider,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      isEmailVerified:
          json['isEmailVerified'] as bool? ?? json['emailVerified'] as bool? ?? false,
      provider: _providerFromString(json['provider'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'isEmailVerified': isEmailVerified,
        'provider': provider.name,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);

  static AuthProvider _providerFromString(String? value) {
    return switch (value) {
      'google' => AuthProvider.google,
      'apple' => AuthProvider.apple,
      'phone' => AuthProvider.phone,
      _ => AuthProvider.password,
    };
  }
}
