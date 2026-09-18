# Secrets and environments

## Secrets

| Secret | Used by | Purpose |
|---|---|---|
| `PUB_CREDENTIALS` | `release.yml` | Publishing to pub.dev |
| `GITHUB_TOKEN` | provided by GitHub | Pushing tags, creating releases |

That is the whole list. No notification webhooks are configured, because no
workflow sends notifications.

### `PUB_CREDENTIALS`

The complete `credentials.json`, refresh token included, so that `dart pub` can
renew the access token on its own.

```bash
dart pub login                          # once, locally
cat ~/.config/dart/pub-credentials.json # or ~/.pub-cache/credentials.json on older SDKs
```

Copy the whole JSON into **Settings → Secrets and variables → Actions → New
repository secret**, named `PUB_CREDENTIALS`.

Rotation is covered in [docs/PUB-TOKEN-ROTATION.md](../docs/PUB-TOKEN-ROTATION.md).

## Environments

`release.yml` runs its publishing job in an environment named **`pub-dev`**.

Create it under **Settings → Environments** and add a required reviewer.
Without it, GitHub creates the environment implicitly with no protection, and
any push to `main` reaches pub.dev unattended.

## Branch protection

The release job pushes the version commit and its tags to `main` using
`GITHUB_TOKEN`. `main` is currently unprotected, so this works as is.

If you protect `main`, that token needs a bypass — otherwise the push is
rejected *after* the packages are already on pub.dev, which is the one failure
the release ordering cannot undo. Grant the bypass, or switch to a GitHub App
token.

## Verifying

```bash
melos run release:rehearse   # asks pub.dev to validate every package
```

## A note on the future

pub.dev supports automated publishing over OIDC, which replaces
`PUB_CREDENTIALS` with a short-lived token minted per run. Two constraints
apply: a package must already have been published manually once, and the
workflow must be triggered by pushing a git tag — which conflicts with the
current ordering, where tags are pushed only after pub.dev accepts everything.
Tracked as COR-715.
