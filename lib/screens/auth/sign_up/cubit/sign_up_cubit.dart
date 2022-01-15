import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_inputs/form_inputs.dart';
import 'package:formz/formz.dart';
import 'package:megaspice/repositories/user/user_repository.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  SignUpCubit(this._authRepo, this._userRepo) : super(const SignUpState());

  void emailChanged(String value) {
    final email = Email.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password, state.confirmedPassword]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value);
    final confirmedPassword = ConfirmedPassword.dirty(
      password: value,
      value: state.confirmedPassword.value,
    );
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password, confirmedPassword]),
    ));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
        password: state.password.value, value: value);
    emit(state.copyWith(
      confirmedPassword: confirmedPassword,
      status: Formz.validate([state.email, state.password, confirmedPassword]),
    ));
  }

  Future<void> signUpFormSubmitted() async {
    if (!state.status.isValidated)
      return;
    emit(state.copyWith(
      status: FormzStatus.submissionInProgress,
    ));
    try {
      var user = await _authRepo.signUp(
        email: state.email.value,
        password: state.password.value,
      );
      _userRepo.setupUser(user: user);
      emit(state.copyWith(
        status: FormzStatus.submissionSuccess,
      ));
    } on SignUpWithEmailAndPasswordFailure catch (ex) {
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
