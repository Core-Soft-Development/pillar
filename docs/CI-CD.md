# CI/CD

Three workflows. Nothing runs twice over the same commit.

| Workflow | Trigger | Does |
|---|---|---|
| `pr-checks.yml` | pull request | title, verification, release rehearsal (PRs to `main`) |
| `release.yml` | push to `main`, manual | version, publish, tag, document |
| `extended-checks.yml` | manual | example app builds, coverage |

## Pull requests

```
title              conventional commit title
verify             analyze · format:check · deps:validate · test
release-rehearsal  pub.dev dry run + BoM check   (only for PRs into main)
```

`verify` runs `melos run ci:verify`, which is the same command you can run
locally — no separate CI-only definition to drift from.

Scopes in PR titles are **not** restricted to a fixed list. The previous one
predated half the packages, so a correctly scoped PR was rejected for naming a
package that exists.

Draft PRs are skipped.

## Release

See [PUBLISHING.md](./PUBLISHING.md) for the ordering and why it is what it is.

Two properties worth calling out:

- **Releases queue, they never cancel each other.** `cancel-in-progress: false`
  on a dedicated concurrency group. The old pipeline had `cancel-in-progress:
  true` covering the release job, so two merges in quick succession could kill a
  release between pushing tags and publishing.
- **Failures are loud.** No `|| echo`, no `continue-on-error` on anything that
  publishes. `set -euo pipefail` throughout.

## Toolchain versions

Read from the files that already hold them, not repeated in each workflow:

- Flutter ← `.fvmrc`
- melos ← `pubspec.lock`

The composite action at `.github/actions/setup-melos` resolves both, restores
the pub cache and bootstraps. Every job uses it, so no job can drift onto a
different toolchain than a developer's machine.

## Keeping CI minutes down

Roughly what was changed, and why:

- **Pull requests ran two workflows.** `ci-cd.yml` triggered on `pull_request`
  as well as `push`, so analyze, test and build each ran twice per PR.
- **APK builds ran on every push** with `continue-on-error: true` — minutes
  spent on a result that could not fail the build. Moved to
  `extended-checks.yml`, on demand.
- **No cache.** Every job re-resolved every dependency from scratch.
- **Two workflows validated the PR title**, with different rules.
- **Verification and release were separate jobs**, paying a second checkout and
  bootstrap. They are one job now.
- `paths-ignore` for `**.md`, `docs/**`, `.idea/**`.

## Secrets

| Secret | Used by | Purpose |
|---|---|---|
| `PUB_CREDENTIALS` | `release.yml` | publishing to pub.dev |
| `GITHUB_TOKEN` | provided | push tags, create releases |

Every workflow declares `permissions: contents: read` at the top and raises it
only on the job that needs it.

## Branch protection

The release job pushes the version commit to `main` with `GITHUB_TOKEN`. If
`main` is protected, that token needs a bypass — otherwise the push is rejected
after the packages are already on pub.dev, which is the one failure mode the
ordering cannot protect you from. Grant the bypass, or swap in a GitHub App
token.

## Running checks locally

```bash
melos run ci:verify         # exactly what a PR runs
melos run release:rehearse  # exactly what the rehearsal runs
```
