import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';
import 'package:equatable/equatable.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

final class SessionChecking extends SessionState {
  const SessionChecking();
}

final class SessionActive extends SessionState {
  const SessionActive(this.user);

  final UserProfile user;

  @override
  List<Object?> get props => [user];
}

final class SessionClosed extends SessionState {
  const SessionClosed();
}
