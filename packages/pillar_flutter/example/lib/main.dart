// Run with: flutter run -t example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_flutter/pillar_flutter.dart';
import 'package:pillar_flutter_example/example_feature.dart';

Future<void> main() async {
  // The graph is built before the first frame, so widgets resolve
  // synchronously and no screen has to render a "still wiring up" state.
  final container = PillarContainer();
  await installModules(container, [const ExampleModule()]);

  runApp(PillarScope(container: container, child: const ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pillar_flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  // Resolved in initState, which works because PillarScope hands out the
  // container without registering an inherited-widget dependency.
  late final ExamplePresenter _presenter = context.get<ExamplePresenter>();

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('pillar_flutter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(onPressed: _presenter.load, child: const Text('Load')),
            const SizedBox(height: 24),
            // BaseProvider is a ChangeNotifier, so Flutter's own builder is
            // enough — the framework ships no state-management opinion.
            ListenableBuilder(
              listenable: _presenter,
              builder: (context, _) {
                if (_presenter.isLoading) return const CircularProgressIndicator();
                if (_presenter.hasError) {
                  return Text(
                    _presenter.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  );
                }
                return Text(_presenter.data ?? 'Nothing loaded yet');
              },
            ),
          ],
        ),
      ),
    );
  }
}
