/// The contracts every Pillar package builds on: dependency injection, error
/// types, and the base classes of the clean-architecture layers.
///
/// Pure Dart on purpose. Nothing here imports Flutter, so the same contracts
/// compile in a server, a CLI or a plain `dart test` run — and an interface
/// package never drags a UI toolkit into a consumer that has no use for one.
/// The Flutter bindings live in `pillar_flutter`.
library;

export 'src/core/errors/exceptions.dart';
export 'src/core/errors/failures.dart';
export 'src/di/di_errors.dart';
export 'src/di/pillar.dart';
export 'src/di/pillar_container.dart';
export 'src/di/pillar_module.dart';
export 'src/domain/entities/base_entity.dart';
export 'src/domain/repositories/base_repository.dart';
export 'src/domain/usecases/base_usecase.dart';
export 'src/infrastructure/services/base_service.dart';
