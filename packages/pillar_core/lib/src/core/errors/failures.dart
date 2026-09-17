import 'package:meta/meta.dart';

/// Base class for all failures in the application
/// Failures represent expected errors that can occur during business operations
@immutable
abstract class Failure {
  /// Constructs a [Failure] with a message, optional code, and optional details.
  const Failure({
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.runtimeType == runtimeType && other.message == message && other.code == code;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Server-related failures
class ServerFailure extends Failure {
  /// Constructs a [ServerFailure] with a message, optional code, and optional details.
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  /// Constructs a [CacheFailure] with a message, optional code, and optional details.
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  /// Constructs a [NetworkFailure] with a message, optional code, and optional details.
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Validation-related failures
class ValidationFailure extends Failure {
  /// Constructs a [ValidationFailure] with a message, optional code, and optional details.
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authentication-related failures
class AuthenticationFailure extends Failure {
  /// Constructs an [AuthenticationFailure] with a message, optional code, and optional details.
  const AuthenticationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Authorization-related failures
class AuthorizationFailure extends Failure {
  /// Constructs an [AuthorizationFailure] with a message, optional code, and optional details.
  const AuthorizationFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// Generic failure for unexpected errors
class UnexpectedFailure extends Failure {
  /// Constructs an [UnexpectedFailure] with a message, optional code, and optional details.
  const UnexpectedFailure({
    required super.message,
    super.code,
    super.details,
  });
}
