import 'package:meta/meta.dart';

/// Base class for all domain entities
/// Entities are objects that have identity and are mutable
@immutable
abstract class BaseEntity<T> {
  /// Constructs a [BaseEntity] with a unique identifier.
  const BaseEntity();

  /// Unique identifier for the entity
  T get id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseEntity<T> && other.runtimeType == runtimeType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$runtimeType(id: $id)';
}
