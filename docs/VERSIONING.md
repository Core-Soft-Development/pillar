# Versioning

Pillar uses **independent versions plus a Bill of Materials** — the model
Firebase uses. Each package moves at its own pace, and the `pillar` BoM pins a
set that was released together.

## Why not one version for everything

Lockstep versioning (every package bumped to the same number) is simpler to
explain, but it lies to consumers: `pillar_webview 2.0.0` would suggest a
breaking change in a package that never changed. Independent versions keep each
changelog honest.

The cost is that a consumer wiring up six packages has six constraints to
reconcile. The BoM absorbs that — see [the BoM README](../packages/pillar/README.md).

## How a version is decided

`melos version` reads the [Conventional Commits](https://www.conventionalcommits.org/)
since a package's last tag and bumps only the packages whose files changed.

| Commit | Bump |
|---|---|
| `fix(core): handle null container` | patch — `1.0.0` → `1.0.1` |
| `feat(core): add scoped containers` | minor — `1.0.0` → `1.1.0` |
| `feat(core)!: remove ServiceLocator` | major — `1.0.0` → `2.0.0` |
| `docs:`, `chore:`, `test:`, `ci:` | none |

A trailing `!` (or a `BREAKING CHANGE:` footer) is what makes a major.

Packages that depend on a bumped package have their constraints updated
automatically, and get a patch bump of their own — `updateDependentsConstraints`
and `updateDependentsVersionConstraints`, under `melos:` in the root pubspec.

## Commands

```bash
melos run release:preview   # what would be released, without committing
melos run release:version           # bump, write changelogs, tag locally
```

`melos run release:version` does **not** push. It leaves a commit and one
`<package>-v<version>` tag per bumped package on the current branch. In CI,
those tags only leave the runner once pub.dev has accepted every package —
see [PUBLISHING.md](./PUBLISHING.md).

To bump one package by hand, call melos directly. There is no wrapper script,
because `melos run` appends its arguments to the command instead of exposing
them as `$1`, so a wrapper could not tell "no arguments" from "version
everything":

```bash
melos version pillar_core minor --yes
```

### Prereleases

```bash
melos run release:prerelease   # 1.2.0 -> 1.2.1-beta.0
melos run release:graduate     # 1.2.1-beta.3 -> 1.2.1
```

`--preid` names the prerelease identifier (`beta`, `rc`). It is **not** a bump
level: `--prerelease --preid minor` produces `1.0.1-minor.0`, which is almost
certainly not what anyone wanted.

### A note on `--all`

In melos, `--all` means *include private packages*, not *every package*. Passing
it to a release versions and tags the example apps. None of the scripts here use
it.

## Tags

One tag per package, `<package>-v<version>`:

```
pillar_core-v1.2.0
pillar_remote_config-v1.1.3
pillar-v2026.09.0          # the BoM
```

melos creates these itself. Each gets a GitHub release whose body is that
package's changelog section, so a consumer of one package never has to read a
monorepo-wide changelog.

## Changelogs

`melos version` writes them — per package, plus the workspace `CHANGELOG.md`.
Nothing in CI appends to a changelog by hand; the previous pipeline did, with a
single `>` that truncated the root changelog on every release.

## The BoM's own version

Calendar-based, `YYYY.MM.N`. The BoM exposes no API, so a semver bump would
imply a compatibility promise it cannot make. It is regenerated from the
versions actually published:

```bash
melos run bom:sync     # regenerate
melos run bom:verify   # fail if it has drifted
```
