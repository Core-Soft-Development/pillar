# Documentation

| Document | Covers |
|---|---|
| [DEVELOPMENT-WORKFLOW.md](DEVELOPMENT-WORKFLOW.md) | Branching model and the path a change takes from branch to release |
| [VERSIONING.md](VERSIONING.md) | How a version is decided, tag convention, prereleases, the BoM |
| [PUBLISHING.md](PUBLISHING.md) | The release ordering and why it is what it is; what a package needs to be publishable |
| [CI-CD.md](CI-CD.md) | The three workflows, toolchain pinning, keeping CI minutes down |
| [TESTING.md](TESTING.md) | Test scripts and the testing strategy |
| [DEPENDENCY-MANAGEMENT.md](DEPENDENCY-MANAGEMENT.md) | Pub workspace resolution and dependencies between packages |
| [PUB-TOKEN-ROTATION.md](PUB-TOKEN-ROTATION.md) | Rotating the pub.dev credentials |

Two more live outside this directory, next to what they describe:

- [`packages/README.md`](../packages/README.md) — the package layout, the tier
  rules between packages, and how to add one
- [`scripts/README.md`](../scripts/README.md) — what each script does and which
  melos script calls it

## Conventions

Documentation here describes **what the repository actually does**. If a
command appears in these files, it exists; if a workflow step is described, it
runs. When that stops being true, the document is the bug.

The shortest way to check the important half:

```bash
melos run ci:verify         # exactly what a pull request runs
melos run release:rehearse  # exactly what the release rehearsal runs
```
