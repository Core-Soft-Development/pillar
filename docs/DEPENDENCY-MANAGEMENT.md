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
# packages/pillar-remote-config/pubspec.yaml
dependencies:
  pillar_core:
    path: ../pillar-core  # ← Use during development
```

**Benefits:**
- ✅ **Instant feedback** - Changes in `pillar_core` immediately available in `pillar_remote_config`
- ✅ **No publishing required** - Work with unreleased features
- ✅ **Consistent development** - All packages use same codebase state

### 2. **Automatic Version Constraint Updates**

Melos configuration handles publication automatically:

```yaml
# melos.yaml
command:
  version:
    updateDependentsVersionConstraints: true
    updateDependentsConstraints: true
```

**How it works:**
1. **During versioning** - Melos detects path dependencies
2. **Converts automatically** - Path deps become version constraints
3. **Updates dependents** - Downstream packages get correct version ranges
4. **Publishes in order** - Dependencies first, then dependents

## 🚀 Workflow Examples

### Scenario 1: Non-Breaking Change in pillar_core

```bash
# 1. Make changes to pillar_core
echo "// New feature" >> packages/pillar-core/lib/src/new_feature.dart

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
# Edit packages/pillar-core/lib/pillar_core.dart

# 2. Update dependent packages to handle breaking changes
# Edit packages/pillar-remote-config/lib/src/service.dart

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
    path: ../pillar-core  # ← Development dependency
EOF

# 3. Develop and test locally
melos bootstrap
melos test

# 4. When ready to publish
melos version --minor
# Melos automatically converts to: pillar_core: ^1.0.0
```

## 🔧 Technical Implementation

### pubspec_overrides.yaml (Automatic)

Melos creates override files during bootstrap:

```yaml
# packages/pillar-remote-config/pubspec_overrides.yaml (auto-generated)
dependency_overrides:
  pillar_core:
    path: ../pillar-core
```

**Purpose:**
- Ensures local development uses path dependencies
- Doesn't interfere with publication
- Automatically managed by Melos

### Version Constraint Updates

During `melos version`, path dependencies are converted:

```yaml
# BEFORE versioning (development)
dependencies:
  pillar_core:
    path: ../pillar-core

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
# melos.yaml
command:
  bootstrap:
    usePubspecOverrides: true  # Enable override files
  
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
    path: ../pillar-core

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
