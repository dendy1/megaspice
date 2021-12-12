import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationRepository authenticationRepository, required bool onboardingFinished})
      : _authenticationRepository = authenticationRepository,
        super(authenticationRepository.currentUser.isNotEmpty
            ? AppState.authenticated(authenticationRepository.currentUser)
            : (onboardingFinished ? const AppState.unauthenticated() : const AppState.onboarding())) {
    on<AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authenticationRepository.user.listen((user) => add(AppUserChanged(user)));
    _onboardingFinished = onboardingFinished;
  }

  final AuthenticationRepository _authenticationRepository;
  late final StreamSubscription<User> _userSubscription;
  late final bool _onboardingFinished;

  void _onUserChanged(AppUserChanged event, Emitter<AppState> emit) {
    print("Onboarding Finished: " + _onboardingFinished.toString());
    emit(event.user.isNotEmpty
        ? AppState.authenticated(event.user)
        : _onboardingFinished ? const AppState.unauthenticated() : const AppState.onboarding());
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authenticationRepository.logOut());
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
