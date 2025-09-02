# Versioning Guide - Pillar Monorepo

This guide explains how to manage package versions in the Pillar monorepo using Melos.

## 📋 Table of Contents

- [Overview](#overview)
- [Versioning Scripts](#versioning-scripts)
- [Workflows](#workflows)
- [Breaking Changes Management](#breaking-changes-management)
- [CI/CD Integration](#cicd-integration)

## 🎯 Overview

The Pillar monorepo uses Melos to manage package versions in a coordinated manner. It supports:

- **Individual versioning**: Upgrade a specific package
- **Global versioning**: Upgrade all packages in the monorepo
- **Automatic detection**: Based on Conventional Commits
- **Dependency management**: Automatic update of inter-package dependencies

## 🛠️ Versioning Scripts

### Version Checking

```bash
# Display current versions of all packages
melos run version:check
```

### Automatic Versioning

```bash
# Patch version (1.0.0 -> 1.0.1)
melos run version:patch

# Minor version (1.0.0 -> 1.1.0) 
melos run version:minor

# Major version (1.0.0 -> 2.0.0)
melos run version:major

# Prerelease (1.0.0 -> 1.0.1-dev.0)
melos run version:prerelease

# Graduate prerelease to stable (1.0.1-dev.0 -> 1.0.1)
melos run version:graduate
```

### Specific Package Versioning

```bash
# Patch version for a specific package
melos version pillar_core patch --all

# Minor version for a specific package
melos version pillar_core minor --all

# Major version for a specific package
melos version pillar_core major --all
```

## 🔄 Workflows

### 1. Local Release (Development)

To test version changes locally:

```bash
# 1. Prepare the release (see current versions)
melos run release:prepare

# 2. Create a local release
melos run release:local

# 3. Check new versions
melos run version:check
```

### 2. Production Release

To publish an official release:

```bash
# 1. Prepare the release
melos run release:prepare

# 2. Publish (creates Git tags and publishes to pub.dev)
melos run release:publish
```

### 3. Breaking Changes Workflow

When `pillar_core` has breaking changes:

```bash
# 1. Identify dependent packages
melos run breaking:check

# 2. Make a commit with conventional commit
git add .
git commit -m "feat!: breaking changes in pillar_core"

# 3. Major version for pillar_core
melos version pillar_core major --all

# 4. Update dependent packages
melos run breaking:update

# 5. Check new versions
melos run version:check
```

## ⚠️ Breaking Changes Management

### Automatic Detection

The system automatically detects dependencies:

```bash
# See which packages depend on pillar_core
melos run breaking:check

# See the complete dependency graph
melos run deps:graph
```

### Practical Example: Upgrade pillar_core 1.0.0 → 2.0.0

1. **Make breaking changes** in `pillar_core`
2. **Commit with conventional commit**:
   ```bash
   git add .
   git commit -m "feat!: major API changes in DependencyContainer"
   ```
3. **Major version**:
   ```bash
   melos version pillar_core major --all
   ```
4. **Dependent packages** (`pillar_remote_config`, `pillar_core_example`) **will "break"** because they still use the old API
5. **Fix dependent packages** to use the new API
6. **Commit and version** the corrected packages:
   ```bash
   git add .
   git commit -m "fix: update to pillar_core 2.0.0 API"
   melos run breaking:update
   ```

### CI/CD Workflow

The system is designed to work with CI/CD:

```bash
# In your CI pipeline
melos run ci:version  # Check versions
melos run ci:publish  # Publish if CI_PUBLISH=true
```

## 📊 Dependency Management

### Check Dependencies

```bash
# Check for outdated dependencies
melos run deps:check

# Update all dependencies
melos run deps:upgrade

# Display dependency graph
melos run deps:graph
```

### Example Dependency Graph

```json
{
  "pillar_core": [],
  "pillar_core_example": ["pillar_core"],
  "pillar_remote_config": ["pillar_core"],
  "pillar_lint": ["pillar_core"]
}
```

## 🚀 Best Practices

### 1. Conventional Commits

Use conventional commits for automatic versioning:

```bash
# Feature (minor version)
git commit -m "feat: add new dependency injection feature"

# Fix (patch version)  
git commit -m "fix: resolve memory leak in provider"

# Breaking change (major version)
git commit -m "feat!: redesign dependency container API"
```

### 2. Release Workflow

1. **Development**: Use `melos run release:local`
2. **Testing**: Test packages with new versions
3. **Production**: Use `melos run release:publish`

### 3. Breaking Changes Management

1. **Planning**: Identify impacted packages with `melos run breaking:check`
2. **Communication**: Document breaking changes in CHANGELOG.md
3. **Migration**: Provide a migration guide
4. **Coordination**: Update all dependent packages together

### 4. CI/CD Integration

```yaml
# Example GitHub Actions
- name: Check versions
  run: melos run ci:version

- name: Publish packages
  if: github.ref == 'refs/heads/main'
  env:
    CI_PUBLISH: true
  run: melos run ci:publish
```

## 📝 Command Examples

```bash
# Complete workflow for a new feature
git checkout -b feature/new-feature
# ... development ...
git add .
git commit -m "feat: add new feature to pillar_core"
melos run release:local
# ... tests ...
git push origin feature/new-feature
# ... merge PR ...
melos run release:publish

# Workflow for breaking changes
git checkout -b breaking/api-redesign
# ... breaking changes in pillar_core ...
git add .
git commit -m "feat!: redesign API for better performance"
melos version pillar_core major --all
# ... fix dependent packages ...
git add .
git commit -m "fix: update to new pillar_core API"
melos run breaking:update
melos run release:publish
```

## 🔍 Troubleshooting

### Issue: "No packages were found that required versioning"

**Solution**: Add `--all` to include private packages:
```bash
melos version --all
```

### Issue: Path dependencies not updated

**Cause**: Melos doesn't automatically update `path:` dependencies.
**Solution**: Path dependencies are managed by the workspace and update automatically.

### Issue: Version conflicts

**Solution**: Use `melos bootstrap` to resolve conflicts:
```bash
melos bootstrap
```

## 🎯 Package Release Strategy

### Individual Package Releases

Each package can be released independently:

```bash
# Release only pillar_core
melos version pillar_core patch --all

# Release only pillar_remote_config  
melos version pillar_remote_config minor --all
```

### Coordinated Releases

For major updates affecting multiple packages:

```bash
# 1. Check what will be updated
melos run version:check

# 2. Update all packages with changes
melos run version:minor

# 3. Publish everything
melos run release:publish
```

### Hotfix Releases

For urgent fixes:

```bash
# 1. Create hotfix branch
git checkout -b hotfix/critical-fix

# 2. Make the fix and commit
git commit -m "fix: critical security issue"

# 3. Patch version for affected package
melos version pillar_core patch --all

# 4. Immediate release
melos run release:publish
```

---

This versioning system ensures your monorepo stays consistent and breaking changes are managed in a controlled and predictable manner.