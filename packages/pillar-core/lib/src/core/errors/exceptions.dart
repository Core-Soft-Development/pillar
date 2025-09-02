/// Base class for all exceptions in the application
/// Exceptions represent unexpected errors that should be handled
abstract class BaseException implements Exception {
  const BaseException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Server-related exceptions
class ServerException extends BaseException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache-related exceptions
class CacheException extends BaseException {
  const CacheException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Network-related exceptions
class NetworkException extends BaseException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Validation-related exceptions
class ValidationException extends BaseException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication-related exceptions
class AuthenticationException extends BaseException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authorization-related exceptions
class AuthorizationException extends BaseException {
  const AuthorizationException({
    required super.message,
    super.code,
    super.details,
  });
}
