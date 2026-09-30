import 'package:domify_tool/core/error/failure.dart';
import 'package:domify_tool/features/auth/domain/repositories/auth_repository.dart';
import 'package:domify_tool/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginInitial());

  final AuthRepository _repository;

  Future<void> signIn({required String email, required String password}) async {
    if (state is LoginSubmitting) return;
    emit(const LoginSubmitting());
    try {
      emit(
        LoginSuccess(await _repository.login(email: email, password: password)),
      );
    } on Failure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(LoginError(failure));
      return;
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(const LoginError(UnknownFailure()));
      return;
    }
  }

  /// Called when the user edits a field, so the previous error stops showing.
  void clearError() {
    if (state is LoginError) emit(const LoginInitial());
  }
}
