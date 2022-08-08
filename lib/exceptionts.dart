class AuthException implements Exception {
  String cause;
  AuthException(this.cause);
}

class NotFoundException implements Exception {
  String cause;
  NotFoundException(this.cause);
}

class UnknownRequestException implements Exception {
  String cause;
  UnknownRequestException(this.cause);
}
