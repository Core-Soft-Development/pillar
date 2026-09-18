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

`main` is protected by the **"Protect main branch"** ruleset, which enforces
`deletion`, `non_fast_forward`, `pull_request` and `required_linear_history`.

Note that rulesets are a separate mechanism from classic branch protection:
`GET /repos/{owner}/{repo}/branches/main/protection` returns 404 here, which
does **not** mean the branch is open. Check `/rulesets`.

Two consequences:

**Merge pull requests with rebase.** `required_linear_history` rejects merge
commits, and a squash would collapse every conventional commit into one — melos
reads them individually to decide each package's bump, so a squashed release
versions the wrong things, or nothing.

**The release job needs a bypass.** Its last step pushes the version commit and
its tags with `GITHUB_TOKEN`, which the `pull_request` rule rejects. Without a
bypass entry the release publishes to pub.dev and *then* fails on the push —
the one failure the ordering cannot undo.

Adding the GitHub Actions integration to the ruleset's bypass list has to be
done at the organization level; a repository-scoped ruleset refuses it with
"Actor GitHub Actions integration must be part of the ruleset source or owner
organization". The alternative is a GitHub App token, or having the release
open a pull request instead of pushing.

## Running checks locally

```bash
melos run ci:verify         # exactly what a PR runs
melos run release:rehearse  # exactly what the rehearsal runs
```
