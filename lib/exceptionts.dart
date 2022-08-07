class AuthException implements Exception {
  String cause;
  AuthException(this.cause);
}
