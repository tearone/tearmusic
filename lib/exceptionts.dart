class BaseRequestException {
  String cause;

  BaseRequestException(this.cause);
}

class AuthException extends BaseRequestException {
  AuthException(String cause) : super(cause);
}

class NotFoundException extends BaseRequestException {
  NotFoundException(String cause) : super(cause);
}

class UnknownRequestException extends BaseRequestException {
  UnknownRequestException(String cause) : super(cause);
}
