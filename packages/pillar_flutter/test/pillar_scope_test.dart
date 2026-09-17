import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillar_core/pillar_core.dart';
import 'package:pillar_flutter/pillar_flutter.dart';

class Greeting {
  const Greeting(this.text);
  final String text;
}

void main() {
  late PillarContainer container;

  setUp(() {
    container = PillarContainer()..registerSingleton<Greeting>(const Greeting('hello'));
  });
  tearDown(() => container.dispose());

  Widget scoped(Widget child) => Directionality(
    textDirection: TextDirection.ltr,
    child: PillarScope(container: container, child: child),
  );

  testWidgets('of() returns the container of the enclosing scope', (tester) async {
    late PillarContainer resolved;
    await tester.pumpWidget(
      scoped(
        Builder(
          builder: (context) {
            resolved = PillarScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(identical(resolved, container), isTrue);
  });

  testWidgets('context.get resolves through the scope', (tester) async {
    late String text;
    await tester.pumpWidget(
      scoped(
        Builder(
          builder: (context) {
            text = context.get<Greeting>().text;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(text, 'hello');
  });

  testWidgets('reading works from initState', (tester) async {
    // The reason maybeOf uses getElementForInheritedWidgetOfExactType: taking a
    // dependency instead would assert here, which is where a state holder is
    // normally resolved.
    await tester.pumpWidget(scoped(const _ResolvesInInitState()));

    expect(tester.takeException(), isNull);
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('a nested scope shadows the one above it', (tester) async {
    final inner = container.openScope()..registerSingleton<Greeting>(const Greeting('shadowed'));
    late String text;

    await tester.pumpWidget(
      scoped(
        PillarScope(
          container: inner,
          child: Builder(
            builder: (context) {
              text = context.get<Greeting>().text;
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(text, 'shadowed');
  });

  testWidgets('maybeOf returns null with no scope above', (tester) async {
    late PillarContainer? resolved;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          resolved = PillarScope.maybeOf(context);
          return const SizedBox();
        },
      ),
    );

    expect(resolved, isNull);
  });

  testWidgets('of() fails with a message naming the widget that asked', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          PillarScope.of(context);
          return const SizedBox();
        },
      ),
    );

    final error = tester.takeException();
    expect(error, isFlutterError);
    expect('$error', contains('No PillarScope found'));
  });
}

class _ResolvesInInitState extends StatefulWidget {
  const _ResolvesInInitState();

  @override
  State<_ResolvesInInitState> createState() => _ResolvesInInitStateState();
}

class _ResolvesInInitStateState extends State<_ResolvesInInitState> {
  late final Greeting _greeting;

  @override
  void initState() {
    super.initState();
    _greeting = context.get<Greeting>();
  }

  @override
  Widget build(BuildContext context) => Text(_greeting.text);
}
