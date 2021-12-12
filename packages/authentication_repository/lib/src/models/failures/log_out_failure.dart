/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {
  const LogOutFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  final String message;
}