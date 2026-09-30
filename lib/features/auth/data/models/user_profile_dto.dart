import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';

class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.code,
    required this.email,
    required this.displayName,
  });

  final int id;
  final String code;
  final String email;
  final String displayName;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) => UserProfileDto(
    id: json['id'] as int,
    code: json['code'] as String,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
  );

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      code: code,
      email: email,
      displayName: displayName,
    );
  }
}
