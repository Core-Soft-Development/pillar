import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_core_example/repositories/example_repository.dart';

abstract interface class ExampleService implements BaseService {
  Future<String> fetchData();
}

class ExampleServiceImpl implements ExampleService {
  const ExampleServiceImpl({
    required this.repository,
  });

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
