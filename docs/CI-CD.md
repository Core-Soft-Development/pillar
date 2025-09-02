# CI/CD Pipeline Documentation

This document explains the CI/CD pipeline setup for the Pillar monorepo, including automated versioning, testing, and publishing.

## 📋 Table of Contents

- [Overview](#overview)
- [Workflows](#workflows)
- [Automated Versioning](#automated-versioning)
- [Release Process](#release-process)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

The Pillar monorepo uses GitHub Actions for CI/CD with the following key features:

- **Automated Quality Checks**: Linting, formatting, and testing on every PR
- **Conventional Commits**: Automatic versioning based on commit messages
- **Automated Publishing**: Packages are published to artifactory after successful builds
- **Changelog Generation**: Automatic changelog updates for packages and workspace
- **Branch Protection**: Only CI can update versions and create releases

## 🔄 Workflows

### 1. PR Checks (`pr-checks.yml`)

**Triggers**: Pull requests to `main` or `develop`

**Features**:
- Validates PR title follows conventional commits
- Analyzes which packages have changes
- Runs quality checks (lint, format, test, build)
- Previews version changes that would occur after merge
- Comments on PR with version preview

**Example PR Comment**:
```
🔮 Version Preview

This PR will affect the following packages:
- pillar_core: 1.1.0 → 1.2.0 (minor)
- pillar_remote_config: 1.1.0 → 1.1.1 (patch)

⚠️ Breaking Changes Detected
This PR contains breaking changes and will trigger a MAJOR version bump.
```

### 2. CI/CD Pipeline (`ci-cd.yml`)

**Triggers**: Push to `main` or `develop`

**Jobs**:
1. **Analyze** - Code quality checks
2. **Test** - Run all tests with coverage
3. **Build** - Build packages and examples
4. **Version & Publish** - Automated versioning and publishing (main only)

**Flow**:
```
Push to main → Quality Checks → Version Packages → Update Changelogs → Publish to Artifactory → Create GitHub Release
```

### 3. Manual Release (`manual-release.yml`)

**Triggers**: Manual workflow dispatch

**Options**:
- Release type: patch, minor, major, prerelease, graduate
- Target packages: specific packages or all changed
- Dry run: preview changes without applying

**Use Cases**:
- Hotfix releases
- Major version releases requiring coordination
- Testing release process

## 🏷️ Automated Versioning

### Conventional Commits

The system uses conventional commits to determine version bumps:

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `fix:` | Patch (1.0.0 → 1.0.1) | `fix: resolve memory leak` |
| `feat:` | Minor (1.0.0 → 1.1.0) | `feat: add new API endpoint` |
| `feat!:` or `BREAKING CHANGE:` | Major (1.0.0 → 2.0.0) | `feat!: redesign API` |
| `chore:`, `docs:`, etc. | No version change | `docs: update README` |

### Version Strategy

- **Individual Packages**: Each package is versioned independently
- **Dependency Updates**: Dependent packages are automatically updated when dependencies change
- **Breaking Changes**: Trigger major version bumps and update all dependents
- **Changelog Generation**: Automatic changelog entries from commit messages

### Example Versioning Flow

1. Developer makes changes to `pillar_core`
2. Commits with `feat!: redesign dependency injection API`
3. Creates PR → CI shows version preview
4. PR merged → CI detects breaking change
5. `pillar_core` bumped to 2.0.0
6. `pillar_remote_config` (depends on pillar_core) bumped to 2.0.0
7. Changelogs updated with breaking change details
8. Packages published to artifactory
9. GitHub release created

## 🚀 Release Process

### Automatic Releases (Recommended)

1. **Development**: Work on feature branches
2. **PR Creation**: Create PR with conventional commit title
3. **Review**: CI shows version preview in PR comments
4. **Merge**: PR merged to main
5. **Release**: CI automatically versions, publishes, and creates release

### Manual Releases

For special cases (hotfixes, coordinated releases):

1. Go to `Actions` tab in GitHub
2. Select `Manual Release` workflow
3. Click `Run workflow`
4. Choose release type and options
5. Review changes (use dry run first)
6. Execute release

### Hotfix Process

```bash
# 1. Create hotfix branch
git checkout -b hotfix/critical-security-fix

# 2. Make fix with conventional commit
git commit -m "fix: resolve critical security vulnerability"

# 3. Create PR
# 4. After merge, CI automatically creates patch release
```

## ⚙️ Configuration

### Required Secrets

Set these in GitHub repository settings:

```
ARTIFACTORY_URL=https://your-company.jfrog.io/artifactory/api/pub/dart
ARTIFACTORY_USERNAME=your-username
ARTIFACTORY_PASSWORD=your-password
```

### Melos Configuration

Key settings in `melos.yaml`:

```yaml
command:
  version:
    updateChangelogs: true
    linkToCommits: true
    workspaceChangelog: true
    updateDependentsVersionConstraints: true
    generateChangelog: true
```

### Branch Protection

Recommended GitHub branch protection rules for `main`:

- ✅ Require a pull request before merging
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging
- ✅ Include administrators
- ✅ Allow force pushes (for CI bot only)

## 📊 Monitoring and Observability

### Release Tracking

- **GitHub Releases**: Automatic release notes with package versions
- **Git Tags**: Individual package tags (e.g., `pillar_core@1.2.0`)
- **Changelog Files**: Updated automatically with conventional commit messages

### Metrics

Monitor these key metrics:

- **Release Frequency**: How often packages are released
- **Build Success Rate**: Percentage of successful CI runs
- **Test Coverage**: Code coverage from automated tests
- **Time to Release**: Time from commit to published package

### Notifications

Set up notifications for:

- ✅ Successful releases
- ❌ Failed releases
- ⚠️ Breaking changes
- 🔒 Security updates

## 🔍 Troubleshooting

### Common Issues

#### Version Not Updated
**Problem**: Package version didn't change after merge
**Solution**: Check if commit follows conventional commit format

#### Artifactory Publish Failed
**Problem**: Package failed to publish
**Solution**: 
1. Check artifactory credentials
2. Verify package doesn't already exist
3. Check network connectivity

#### Dependency Conflicts
**Problem**: Packages have conflicting dependency versions
**Solution**: Run `melos bootstrap` to resolve conflicts

#### Breaking Changes Not Detected
**Problem**: Breaking changes didn't trigger major version
**Solution**: Ensure commit message includes `!` or `BREAKING CHANGE:`

### Debug Commands

```bash
# Check what would be versioned
melos run ci:check-changes

# Preview version changes
melos version --no-git-tag-version --no-git-commit-version --all --yes

# Check dependency graph
melos run deps:graph

# Validate before release
melos run ci:validate-before-release
```

### CI Logs

Check these logs when debugging:

1. **Analyze Job**: Code quality issues
2. **Test Job**: Test failures
3. **Version & Publish Job**: Versioning and publishing issues
4. **GitHub Actions Summary**: High-level overview

## 🔐 Security Considerations

### Secrets Management
- Use repository secrets, never hardcode credentials
- Rotate secrets regularly
- Use least-privilege access for artifactory

### Branch Protection
- Protect main branch from direct pushes
- Require PR reviews for sensitive changes
- Only allow CI bot to create version commits

### Dependency Security
- Automated dependency updates with Dependabot
- Security scanning in CI pipeline
- Regular security audits

## 📈 Best Practices

### Commit Messages
```bash
# Good
feat: add user authentication
fix: resolve memory leak in provider
feat!: redesign API for better performance

# Bad
update code
fix bug
changes
```

### PR Management
- Use descriptive PR titles with conventional commit format
- Review version preview comments before merging
- Test breaking changes thoroughly

### Release Planning
- Use semantic versioning consistently
- Document breaking changes in PR descriptions
- Coordinate major releases across teams

---

This CI/CD pipeline ensures consistent, reliable releases while maintaining high code quality and proper version management across the entire monorepo.
