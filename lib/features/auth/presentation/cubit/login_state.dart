import 'package:domify_tool/core/error/failure.dart';
import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';
import 'package:equatable/equatable.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final UserProfile user;

  @override
  List<Object?> get props => [user];
}

final class LoginError extends LoginState {
  const LoginError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
