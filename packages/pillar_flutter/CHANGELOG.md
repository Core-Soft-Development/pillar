## 1.0.0

- Initial release. Extracted from `pillar_core`, which is now pure Dart.
  - `PillarScope` exposes a `PillarContainer` to a widget tree, and
    `context.get<T>()` resolves from it — including in `initState`.
  - `BaseProvider` moves here unchanged, apart from no longer notifying
    listeners when the loading or error state has not actually changed.
  - The `provider` package is no longer a dependency. `DependencyConsumer` and
    `DependencySelector` are gone: both wrapped `Consumer<DependencyContainer>`,
    which never notifies, so neither ever rebuilt on anything. Use
    `ListenableBuilder` with a `BaseProvider`.
