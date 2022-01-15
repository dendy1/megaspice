part of 'auth_bloc.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthState extends Equatable {
  final AuthStatus status;
  final User user;

  const AuthState.initial({
    this.user = User.empty,
    this.status = AuthStatus.unknown,
  });

  const AuthState.authenticated(User user) : this.initial(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated() : this.initial(status: AuthStatus.unauthenticated);
  const AuthState.unknown() : this.initial();

  @override
  List<Object?> get props => [status, user];
}
