import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_flutter/pillar_flutter.dart';

// One feature, across the layers pillar_core names: a repository fetches, a
// service applies the rule, a provider holds what the screen renders.

abstract interface class ExampleRepository implements BaseRepository {
  Future<String> getData();
}

class NetworkExampleRepository implements ExampleRepository {
  @override
  String get repositoryName => 'ExampleRepository';

  @override
  Future<String> getData() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return 'a row from somewhere';
  }
}

abstract interface class ExampleService implements BaseService {
  Future<String> fetchData();
}

class DefaultExampleService implements ExampleService {
  const DefaultExampleService(this.repository);

  final ExampleRepository repository;

  @override
  String get serviceName => 'ExampleService';

  @override
  Future<String> fetchData() async => 'Processed: ${await repository.getData()}';
}

class ExamplePresenter extends BaseProvider {
  ExamplePresenter(this.service);

  final ExampleService service;
  String? _data;

  String? get data => _data;

  Future<void> load() async {
    final result = await executeAsync(service.fetchData);
    if (result != null) {
      _data = result;
      notifyListeners();
    }
  }
}

/// What a Pillar package ships: the bindings for its own layer, so an
/// application names the module rather than wiring the internals.
final class ExampleModule extends PillarModule {
  const ExampleModule();

  @override
  void register(PillarContainer container) {
    container
      ..registerLazySingleton<ExampleRepository>((_) => NetworkExampleRepository())
      ..registerLazySingleton<ExampleService>((c) => DefaultExampleService(c.get<ExampleRepository>()))
      // A factory, not a singleton: each screen gets its own state holder, and
      // the container disposes nothing it did not build.
      ..registerFactory<ExamplePresenter>((c) => ExamplePresenter(c.get<ExampleService>()));
  }
}
