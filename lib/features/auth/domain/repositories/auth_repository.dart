import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';

abstract interface class AuthRepository {
  Future<UserProfile> login({required String email, required String password});
  Future<UserProfile?> restoreSession();
  Future<void> logout();
}
