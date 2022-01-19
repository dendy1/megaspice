part of '../../blocs/auth_bloc/auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthUserChangedEvent extends AuthEvent {
  final User user;

  const AuthUserChangedEvent(this.user);

  @override
  List<Object> get props => [user];
}

class AuthLogoutRequestedEvent extends AuthEvent {}

class AuthDeleteRequestedEvent extends AuthEvent {}