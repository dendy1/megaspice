import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo _authRepo;
  late final StreamSubscription<User> _userSubscription;

  AuthBloc({
    required AuthRepo authRepo,
    required bool onboardingFinished,
  })  : _authRepo = authRepo,
        super(authRepo.currentUser.isNotEmpty
            ? AuthState.authenticated(authRepo.currentUser)
            : (onboardingFinished
                ? const AuthState.unauthenticated()
                : const AuthState.unknown())) {
    on<AuthUserChangedEvent>(_onUserChanged);
    on<AuthLogoutRequestedEvent>(_onLogoutRequested);
    on<AuthDeleteRequestedEvent>(_onDeleteRequested);
    _userSubscription = _authRepo.user.listen((user) => add(AuthUserChangedEvent(user)));
    _onboardingFinished = onboardingFinished;
  }

  late final bool _onboardingFinished;

  void _onUserChanged(AuthUserChangedEvent event, Emitter<AuthState> emit) {
    emit(event.user.isNotEmpty
        ? AuthState.authenticated(event.user)
        : _onboardingFinished
            ? const AuthState.unauthenticated()
            : const AuthState.unknown());
  }

  void _onLogoutRequested(
      AuthLogoutRequestedEvent event, Emitter<AuthState> emit) {
    unawaited(_authRepo.logOut());
  }

  void _onDeleteRequested(
      AuthDeleteRequestedEvent event, Emitter<AuthState> emit) {
    unawaited(_authRepo.disableUser());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
