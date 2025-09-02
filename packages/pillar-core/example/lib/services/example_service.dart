import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_core_example/repositories/example_repository.dart';

/// ExampleService demonstrating a simple service pattern
abstract interface class ExampleService implements BaseService {
  /// Service name
  Future<String> fetchData();
}

/// Implementation of ExampleService
class ExampleServiceImpl implements ExampleService {
  /// Constructs an [ExampleServiceImpl].
  const ExampleServiceImpl({
    required this.repository,
  });

  /// Repository for data operations
  final ExampleRepository repository;

  @override
  String get serviceName => 'ExampleService';

  @override
  Future<String> fetchData() async {
    // Simulate some business logic
    await Future<void>.delayed(const Duration(seconds: 1));

    final data = await repository.getData();
    return 'Processed: $data';
  }
}
