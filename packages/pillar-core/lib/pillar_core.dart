/// Pillar Core - A foundational package for clean architecture and dependency injection
library pillar_core;

// Core exports
export 'src/core/dependency_injection/dependency_container.dart';
export 'src/core/dependency_injection/provider_dependency_container.dart';
export 'src/core/dependency_injection/dependency_injection_provider.dart';
export 'src/core/dependency_injection/service_locator.dart';
export 'src/core/errors/failures.dart';
export 'src/core/errors/exceptions.dart';

// Domain layer exports
export 'src/domain/entities/base_entity.dart';
export 'src/domain/usecases/base_usecase.dart';
export 'src/domain/repositories/base_repository.dart';

// Infrastructure layer exports
export 'src/infrastructure/services/base_service.dart';

// Presentation layer exports
export 'src/presentation/providers/base_provider.dart';
