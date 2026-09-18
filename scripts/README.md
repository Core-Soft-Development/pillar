# Scripts

Everything here is either a one-off developer convenience (`.sh`) or a step the
CI calls through a melos script (`.dart`).

Prefer `melos run <script>` over calling these directly — the melos scripts are
what CI runs, so they are the definition that stays honest.

## Dart

Called from melos scripts; see the `melos:` section of the root `pubspec.yaml`.

| File | Ran by | Does |
|---|---|---|
| `validate_deps.dart` | `melos run deps:validate` | Enforces the package layering rules: core depends on nothing, an interface sees only core, an implementation never sees another implementation, no cycles, no bare `path:` dependency, and pub.dev-ready metadata. |
| `bom.dart` | `melos run bom:sync` / `bom:verify` | Regenerates the `pillar` BoM from published versions, or fails if it has drifted. |
| `github_releases.dart` | the release workflow | Creates one GitHub release per tagged package, with the body taken from that package's changelog. |
| `dart_files.dart` | `melos run format` / `format:check` | Lists hand-written Dart files, excluding generated sources. |
| `melos_json.dart` | (library) | Decodes melos JSON output. melos interleaves notices into stdout, so the JSON cannot be handed straight to `jsonDecode`. |

## Shell

| File | Does |
|---|---|
| `setup.sh` | First-time setup: checks Flutter and Dart, installs the pinned melos, bootstraps, installs the git hooks. |
| `bootstrap.sh` | Clean and re-bootstrap the workspace. |
| `install_hooks.sh` | Installs `.githooks/commit-msg`, which validates Conventional Commits locally. |

## Adding one

Ask first whether it should be a melos script instead. A shell script in this
directory is invisible to `melos run --help`, is not what CI executes, and
tends to drift from it — this README previously documented fifteen scripts,
none of which existed.
