import 'package:domify_tool/features/auth/domain/entities/user_profile.dart';
import 'package:domify_tool/features/auth/domain/repositories/auth_repository.dart';
import 'package:domify_tool/features/auth/presentation/cubit/session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._repository) : super(const SessionChecking());

  final AuthRepository _repository;

  Future<void> start() async {
    try {
      final user = await _repository.restoreSession();
      emit(user == null ? const SessionClosed() : SessionActive(user));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const SessionClosed());
    }
  }

  void onSignedIn(UserProfile user) => emit(SessionActive(user));

  Future<void> signOut() async {
    await _repository.logout();
    emit(const SessionClosed());
  }
}
