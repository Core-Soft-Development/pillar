# Packages

Every package published by the Pillar framework lives here, grouped by domain.

## Layout

Packages are organised the way FlutterFire organises its own: an interface and
its implementations sit side by side, inside a folder named after the domain.

```
packages/
├── pillar_core/       # tier 0  — contracts, DI, errors. Pure Dart.
├── pillar_flutter/    # tier 0b — the seam between the container and widgets
└── pillar/            # tier 4  — the BoM, no code at all
```

That is the whole repository today. Domain packages get added around it, one
folder per domain, an interface next to its implementations:

```
packages/
├── notifications/
│   ├── pillar_notifications/                 # tier 1 — the app-facing interface
│   ├── pillar_notifications_platform_interface/
│   └── pillar_notifications_firebase/        # tier 2 — an implementation
│
├── webview/
│   └── pillar_webview/
│
└── testing/                                  # tier 3 — tooling
    ├── pillar_test/
    └── pillar_golden_test/
```

The folder name always matches the package name, in `snake_case`. Each package
is listed under `workspace:` in the root pubspec and declares
`resolution: workspace`.

## Tiers and the rules between them

| Tier | What it holds | May depend on |
|---|---|---|
| 0 — `pillar_core` | contracts, DI, error types | nothing else in this repo |
| 0b — `pillar_flutter` | bindings to one runtime | `pillar_core` |
| 1 — `pillar_<domain>` | the public API of one domain | `pillar_core`, `pillar_flutter` |
| 2 — `pillar_<domain>_<vendor>` | one concrete implementation | its own tier-1 interface |
| 3 — tooling | test harnesses, lints | tier 0 and 1 |
| 4 — `pillar` | the BoM, no code at all | every published package |

Three rules carry most of the weight:

- **`pillar_core` stays pure Dart.** It is the package everything else depends
  on. The moment it pulls in the Flutter SDK, every interface in the framework
  does too, and none of them can be used from a server, a CLI or a plain
  `dart test` run. Whatever needs widgets goes in `pillar_flutter`, which is why
  that package exists.
- **An implementation never depends on another implementation.** The moment
  `pillar_notifications_firebase` imports `pillar_snackbar_material`, the
  federated model is gone and consumers can no longer swap one out.
- **An app depends on interfaces, and names an implementation exactly once** —
  at composition root, where dependencies are registered.

`melos run deps:validate` enforces all three, plus cycle detection, in CI.

## Why implementations live in this repo

They could live in separate repositories. They don't, because:

- changing a contract and its implementations is a single PR, reviewed as a unit;
- the melos dependency graph gives publication its topological order for free;
- a breaking change surfaces at compile time, in the same CI run that caused it.

A separate repository is only worth it when a third party owns the
implementation and releases it on their own schedule.

## Adding a package

1. Create the folder under its domain (create the domain folder if new).
2. Copy the `pubspec.yaml` header from a sibling — `homepage`, `repository`,
   `issue_tracker` and a description of at least 60 characters are required by
   `deps:validate`.
3. Depend on siblings by **version constraint**, never by path:

   ```yaml
   dependencies:
     pillar_core: ^1.0.0
   ```

   The pub workspace resolves that to the local package automatically. A bare
   `path:` dependency makes the package unpublishable on pub.dev.
4. Start at `0.1.0` while the API is still moving.
   Keep it pure Dart unless it genuinely renders something: a tier-1 interface
   that depends on Flutter forces every consumer of that domain to.
5. Add `README.md`, `CHANGELOG.md` and `LICENSE`.
6. Run `melos bootstrap`, then `melos run deps:validate`.

## Versioning

Each package carries its own version, bumped from its own conventional commits
(`melos version`). Releases are tagged `<package>-v<version>`, and the `pillar`
BoM pins a set of versions known to work together.

See [`docs/VERSIONING.md`](../docs/VERSIONING.md) and
[`docs/PUBLISHING.md`](../docs/PUBLISHING.md).
