import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:megaspice/repositories/repositories.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  LoginCubit(this._authRepo, this._userRepo) : super(const LoginState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password]),
    ));
  }

  Future<void> logInWithCredentials() async {
    if (!state.status.isValidated) return;
    emit(state.copyWith(
      status: FormzStatus.submissionInProgress,
    ));
    try {
      await _authRepo.logInWithEmailAndPassword(
        email: state.email.value,
        password: state.password.value,
      );
      emit(state.copyWith(
        status: FormzStatus.submissionSuccess,
      ));
    } on LogInWithEmailAndPasswordFailure catch (ex) {
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        errorMessage: ex.message,
      ));
    } catch (ex) {
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        errorMessage: ex.toString(),
      ));
    }
  }

  Future<void> logInWithGoogle() async {
    emit(state.copyWith(
      status: FormzStatus.submissionInProgress,
    ));
    try {
      var user = await _authRepo.logInWithGoogle();
      _userRepo.setupUser(user: user);
      emit(state.copyWith(
        status: FormzStatus.submissionSuccess,
      ));
    } on LogInWithGoogleFailure catch (ex) {
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        errorMessage: ex.message,
      ));
    } catch (ex) {
      emit(state.copyWith(
        status: FormzStatus.submissionFailure,
        errorMessage: ex.toString(),
      ));
    }
  }
}
