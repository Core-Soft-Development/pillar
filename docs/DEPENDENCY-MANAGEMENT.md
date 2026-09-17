# Dependency Management Strategy

This guide explains how the Pillar monorepo handles dependencies between packages during development and publication.

## 🎯 The Challenge

In a monorepo with interdependent packages, we face a dilemma:

- **Local Development**: Need to use latest code changes (path dependencies)
- **CI/CD & Publication**: Need to use published versions (version constraints)
- **Breaking Changes**: Need to coordinate publication order

## 🔄 Our Solution: Melos Smart Dependency Management

Melos provides built-in solutions for this exact scenario through:

### 1. **Path Dependencies for Development**

```yaml
# packages/remote_config/pillar_remote_config/pubspec.yaml
dependencies:
  pillar_core:
    path: ../pillar_core  # ← Use during development
```

**Benefits:**
- ✅ **Instant feedback** - Changes in `pillar_core` immediately available in `pillar_remote_config`
- ✅ **No publishing required** - Work with unreleased features
- ✅ **Consistent development** - All packages use same codebase state

### 2. **Automatic Version Constraint Updates**

Melos configuration handles publication automatically:

```yaml
# pubspec.yaml (root)
melos:
  command:
    version:
      updateDependentsVersionConstraints: true
      updateDependentsConstraints: true
```

**How it works:**
1. **During versioning** - Melos finds every package depending on the bumped one
2. **Updates constraints** - Their version ranges are rewritten to match
3. **Updates dependents** - Downstream packages get correct version ranges
4. **Publishes in order** - Dependencies first, then dependents

## 🚀 Workflow Examples

### Scenario 1: Non-Breaking Change in pillar_core

```bash
# 1. Make changes to pillar_core
echo "// New feature" >> packages/pillar_core/lib/src/new_feature.dart

# 2. Test locally (uses path dependencies)
melos test

# 3. Version and publish (Melos handles everything)
melos version --minor
# Melos will:
# - Version pillar_core to 1.1.0
# - Update pillar_remote_config to depend on "pillar_core: ^1.1.0"
# - Publish pillar_core first
# - Then publish pillar_remote_config
```

### Scenario 2: Breaking Change in pillar_core

```bash
# 1. Make breaking changes
# Edit packages/pillar_core/lib/pillar_core.dart

# 2. Update dependent packages to handle breaking changes
# Edit packages/remote_config/pillar_remote_config/lib/src/service.dart

# 3. Version with major bump
melos version --major
# Melos will:
# - Version pillar_core to 2.0.0
# - Update pillar_remote_config dependency to "pillar_core: ^2.0.0"
# - Version pillar_remote_config (major bump due to breaking dep change)
# - Publish in correct order
```

### Scenario 3: Adding New Package with Dependencies

```bash
# 1. Create new package
mkdir -p packages/pillar-analytics
cd packages/pillar-analytics

# 2. Set up with path dependency
cat > pubspec.yaml << EOF
name: pillar_analytics
version: 0.1.0
dependencies:
  pillar_core:
    path: ../pillar_core  # ← Development dependency
EOF

# 3. Develop and test locally
melos bootstrap
melos test

# 4. When ready to publish
melos version pillar_core minor --yes
# Dependents are rewritten to: pillar_core: ^1.1.0
```

## 🔧 Technical Implementation

### Pub workspace resolution

The repo is a [pub workspace](https://dart.dev/tools/pub/workspaces): the root
pubspec lists its members under `workspace:`, and each package declares
`resolution: workspace`.

```yaml
# pubspec.yaml (root)
workspace:
  - packages/pillar_core
  - packages/remote_config/pillar_remote_config
```

```yaml
# packages/remote_config/pillar_remote_config/pubspec.yaml
resolution: workspace

dependencies:
  pillar_core: ^1.0.0     # resolved to the local package
```

**What this gives you:**
- One `pubspec.lock` and one `.dart_tool/` for the whole repo, not one per package
- Sibling packages resolve locally from a plain version constraint
- No generated `pubspec_overrides.yaml` to commit, ignore, or conflict on

Before pub workspaces existed, melos emulated this by writing a
`pubspec_overrides.yaml` into each package (`usePubspecOverrides: true`). That
mechanism is gone; the SDK does it natively.

### Version Constraint Updates

During `melos version`, path dependencies are converted:

```yaml
# BEFORE versioning (development)
dependencies:
  pillar_core:
    path: ../pillar_core

# AFTER versioning (ready for publication)
dependencies:
  pillar_core: ^2.0.0  # ← Automatically updated
```

### Publication Order

Melos automatically determines publication order:

```
1. pillar_core (no dependencies)
2. pillar_remote_config (depends on pillar_core)
3. pillar_analytics (depends on pillar_core)
```

## 📋 Configuration Details

### Melos Configuration

```yaml
# pubspec.yaml (root) — melos reads its config from here in a workspace
melos:
  command:
    version:
      updateDependentsVersionConstraints: true  # Update version ranges
      updateDependentsConstraints: true         # Update all constraints
```

### Analysis Configuration

To avoid warnings during development:

```yaml
# analysis_options.yaml
analyzer:
  errors:
    invalid_dependency: ignore  # Allow path dependencies during development
```

## 🎯 Best Practices

### 1. Always Use Path Dependencies in Source

```yaml
# ✅ GOOD - Always use path in source
dependencies:
  pillar_core:
    path: ../pillar_core

# ❌ BAD - Don't use version constraints in source
dependencies:
  pillar_core: ^1.0.0
```

### 2. Let Melos Handle Version Updates

```bash
# ✅ GOOD - Let Melos update versions
melos version --major

# ❌ BAD - Don't manually update version constraints
# (editing pubspec.yaml to change pillar_core: ^1.0.0 to ^2.0.0)
```

### 3. Test Before Publishing

```bash
# Always test with current development state
melos test
melos analyze

# Then version and publish
melos version --minor
```

### 4. Use Conventional Commits

```bash
# Breaking change
git commit -m "feat!: redesign core API"

# New feature
git commit -m "feat: add analytics tracking"

# Bug fix
git commit -m "fix: resolve memory leak"
```

## 🔍 Troubleshooting

### Issue: Path Dependencies in Published Package

**Error:** `Published package contains path dependency`

**Cause:** Manual version command bypassed Melos conversion

**Solution:**
```bash
# Use Melos versioning (not manual)
melos version --patch  # Instead of: dart pub version patch
```

### Issue: Dependency Version Conflicts

**Error:** `Version solving failed`

**Solution:**
```bash
# Clean and re-bootstrap
melos clean
melos bootstrap

# Check dependency graph
melos list --graph
```

### Issue: Publication Order Problems

**Error:** `Package 'pillar_core' not found`

**Cause:** Dependent published before dependency

**Solution:** Melos handles this automatically, but if needed:
```bash
# Publish manually in order
melos publish --scope="pillar_core"
melos publish --scope="pillar_remote_config"
```

## 📊 Development Workflow

### Daily Development

```bash
# 1. Start development
melos bootstrap  # Sets up path dependencies

# 2. Make changes to any package
# Files are linked, changes are immediate

# 3. Test continuously
melos test

# 4. No need to publish during development
```

### Release Workflow

```bash
# 1. Finalize changes
git add .
git commit -m "feat: new feature complete"

# 2. Version (converts path deps to version constraints)
melos version --minor

# 3. Publish (handles order automatically)
melos publish --yes

# 4. Path dependencies restored for next development cycle
melos bootstrap
```

## 🎯 Summary

**The magic of Melos:**

1. **Development**: Use path dependencies for instant feedback
2. **Publication**: Automatically convert to version constraints
3. **Order**: Publish dependencies before dependents
4. **Restoration**: Path dependencies restored after publication

**You get the best of both worlds:**
- 🚀 **Fast development** with immediate changes
- 📦 **Proper publication** with correct version constraints
- 🔄 **Automatic orchestration** of complex dependency updates

This system handles your exact use case perfectly - breaking changes, version coordination, and development workflow all managed automatically by Melos! 🎉
