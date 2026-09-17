# pillar

The Bill of Materials for the Pillar framework.

This package contains **no code**. It pins one exact version of every published
`pillar_*` package — a set that was released and tested together by CI.

## Why

Pillar packages are versioned independently: `pillar_core` and
`pillar_webview` move at their own pace, driven by their own commits. That is
good for changelogs and bad for consumers, who would otherwise juggle six
constraints and hope the combination resolves.

Depending on the BoM replaces that with one decision.

## Usage

```yaml
dependencies:
  pillar: ^2026.09.0
```

Then depend on the packages you actually use, without a version:

```yaml
dependencies:
  pillar: ^2026.09.0
  pillar_core:
  pillar_remote_config:
```

Resolution takes the versions the BoM pins.

## Versioning

Calendar, `YYYY.MM.N` — not semver. The BoM exposes no API of its own, so a
semver bump would imply a compatibility promise it is not in a position to
make. `N` resets each month.

The file is regenerated at the end of every release from the versions actually
published, and is never edited by hand:

```bash
melos run bom:sync     # regenerate
melos run bom:verify   # fail if it has drifted
```
