/// Base class for all exceptions in the application
/// Exceptions represent unexpected errors that should be handled
abstract class BaseException implements Exception {
  /// Constructs a [BaseException] with a message, optional code, and optional details.
  const BaseException({
    required this.message,
    this.code,
    this.details,
  });

  /// A human-readable message describing the error.
  final String message;

  /// An optional error code that can be used to identify the type of error.
  final String? code;

  /// Optional additional details about the error.
  final Map<String, dynamic>? details;

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Server-related exceptions
class ServerException extends BaseException {
  /// Constructs a [ServerException] with a message, optional code, and optional details.
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache-related exceptions
class CacheException extends BaseException {
  /// Constructs a [CacheException] with a message, optional code, and optional details.
  const CacheException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Network-related exceptions
class NetworkException extends BaseException {
  /// Constructs a [NetworkException] with a message, optional code, and optional details.
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Validation-related exceptions
class ValidationException extends BaseException {
  /// Constructs a [ValidationException] with a message, optional code, and optional details.
  const ValidationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication-related exceptions
class AuthenticationException extends BaseException {
  /// Constructs an [AuthenticationException] with a message, optional code, and optional details.
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authorization-related exceptions
class AuthorizationException extends BaseException {
  /// Constructs an [AuthorizationException] with a message, optional code, and optional details.
  const AuthorizationException({
    required super.message,
    super.code,
    super.details,
  });
}
