import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_core_example/providers/example_provider.dart';
import 'package:pillar_core_example/repositories/example_repository.dart';
import 'package:pillar_core_example/services/example_service.dart';

void main() {
  // Setup dependencies before running the app
  setupDependencies();
  runApp(const MyApp());
}

/// Function to setup dependencies using Service Locator
void setupDependencies() {
  final container = ServiceLocator.container;

  // Register repositories
  container.registerLazySingleton<ExampleRepository>(
    () => ExampleRepositoryImpl(),
  );

  // Register services
  container.registerLazySingleton<ExampleService>(
    () => ExampleServiceImpl(
      repository: ServiceLocator.get<ExampleRepository>(),
    ),
  );

  // Register providers
  container.registerFactory<ExampleProvider>(
    () => ExampleProvider(
      service: ServiceLocator.get<ExampleService>(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates the root widget of the application.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DependencyInjectionProvider(
      child: MaterialApp(
        title: 'Pillar Core Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Pillar Core Demo'),
      ),
    );
  }
}

/// The home page of the application.
class MyHomePage extends StatefulWidget {
  /// Creates the home page of the application.
  const MyHomePage({super.key, required this.title});

  /// The title of the home page.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class _MyHomePageState extends State<MyHomePage> with DependencyInjectionMixin {
  late final ExampleProvider _provider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = getDependency<ExampleProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Dependency Injection Examples:',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _provider.loadData();
              },
              child: const Text('Load Data (Service Locator)'),
            ),
            const SizedBox(height: 10),
            DependencyConsumer<ExampleProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const CircularProgressIndicator();
                }
                if (provider.hasError) {
                  return SelectableText.rich(
                    TextSpan(
                      text: 'Error: ${provider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Text(
                  'Data: ${provider.data ?? "No data"}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Example of using context extension
                final service = context.getDependency<ExampleService>();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service name: ${service.serviceName}'),
                  ),
                );
              },
              child: const Text('Get Service (Context Extension)'),
            ),
          ],
        ),
      ),
    );
  }
}
