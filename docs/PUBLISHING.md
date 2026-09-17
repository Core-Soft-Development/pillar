# Publishing

Packages are published to pub.dev by the `Release` workflow when a commit
lands on `main`.

## The order matters

pub.dev does not allow unpublishing. A version that ships is spent — if a tag
is pushed and the publish then fails, that version number can never be
reused. The pipeline is therefore ordered so that **nothing is written to git
until pub.dev has accepted everything**:

```
1. verify          analyze · format · dependency graph · tests
2. version         melos bumps, writes changelogs, commits and tags — all local
3. rehearse        melos publish (dry run) against pub.dev
                     ✗ → abort. No commit, no tag, no version burned.
4. publish         melos publish --no-dry-run, topological order
5. sync the BoM    pin what actually landed, publish it last
6. push            git push --follow-tags
7. document        one GitHub release per package
```

Step 3 is the one that earns its keep. pub.dev rejects packages for a dozen
reasons — a description under 60 characters, a missing LICENSE, a dependency
constraint that will not resolve, a version already published. Finding out at
step 3 costs nothing. Finding out at step 6 costs a version number.

### What is still not atomic

If the runner dies between publishing package 3 of 8 and package 4, the first
three are live and the rest are not. pub.dev has no transaction to roll back,
so this cannot be fully closed — but the window is seconds wide, and the
rehearsal removes nearly every cause of a mid-sequence failure.

Recovery: re-run the workflow. `melos publish` skips versions already on
pub.dev, and `gh release create` is guarded, so a second run finishes the job
rather than duplicating it.

## Running a release

Automatic on every push to `main`. To rehearse by hand:

**Actions → Release → Run workflow**, with `dry_run` left at its default. The
job versions, asks pub.dev to validate everything, and stops — publishing
nothing and pushing nothing.

`mode` selects the versioning: `stable` (from conventional commits),
`prerelease` (beta), or `graduate` (promote betas to stable).

## Requirements for a package to publish

`melos run deps:validate` checks these, so a violation fails the PR rather
than the release:

- no `publish_to: none` (that was why `pillar_remote_config` could never ship)
- **no `path:` dependency** — pub.dev rejects them. Depend on siblings by
  version constraint; the pub workspace resolves it to the local package:

  ```yaml
  dependencies:
    pillar_core: ^1.0.0     # in pubspec.yaml, published
  ```

- `homepage`, `repository`, `issue_tracker`
- a description of at least 60 characters (pana scores on it)
- `LICENSE` and `CHANGELOG.md` in the package folder

## Credentials

`PUB_CREDENTIALS` — the full `credentials.json`, refresh token included — set
as a repository secret, consumed by the `pub-dev` environment. See
[SECRETS.md](../.github/SECRETS.md) and
[PUB-TOKEN-ROTATION.md](./PUB-TOKEN-ROTATION.md).

pub.dev also supports OIDC automated publishing, which removes the stored
secret in favour of a short-lived token minted per run. It needs "Automated
publishing" enabled per package on pub.dev first, so it is tracked separately
rather than assumed here (COR-715).

The `pub-dev` environment should carry a required reviewer in repository
settings, so that reaching pub.dev takes a human approval.

## Publishing by hand

Rarely necessary, and it bypasses the ordering above.

```bash
melos run release:rehearse   # always first
melos run release:publish
melos run bom:sync
melos run release:publish-bom       # last: its pins must already resolve
```

`melos publish` defaults to a dry run — the `publish` script passes
`--no-dry-run` explicitly. A script that omits it reports success while
publishing nothing.
