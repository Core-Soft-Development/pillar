/// Flutter bindings for `pillar_core`.
///
/// `pillar_core` is pure Dart and knows nothing about widgets. This package is
/// the seam between the two: it hands a `PillarContainer` to a widget tree and
/// supplies the presentation-layer base class that needs `ChangeNotifier`.
///
/// Keeping it separate is what lets an interface package — `pillar_webview`,
/// `pillar_notifications` — be consumed from a server, a CLI or a plain
/// `dart test` run without pulling in a UI toolkit.
library;

export 'src/base_provider.dart';
export 'src/pillar_scope.dart';
