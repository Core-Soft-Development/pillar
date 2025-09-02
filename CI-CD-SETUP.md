# CI/CD Setup Guide

This guide helps you set up the complete CI/CD pipeline for the Pillar monorepo.

## 🚀 Quick Setup

### 1. Configure GitHub Secrets

Go to your repository settings and add these secrets:

```
ARTIFACTORY_URL=https://your-company.jfrog.io/artifactory/api/pub/dart
ARTIFACTORY_USERNAME=your-username  
ARTIFACTORY_PASSWORD=your-api-key
```

### 2. Enable Workflows

The workflows are automatically enabled when you push the `.github/workflows/` files to your repository.

### 3. Set Branch Protection

Configure branch protection for `main`:

1. Go to `Settings > Branches`
2. Add rule for `main` branch
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging

## 📋 Available Workflows

### 1. PR Checks (`pr-checks.yml`)
- **Trigger**: Pull requests to main/develop
- **Purpose**: Validate code quality and preview version changes
- **Features**:
  - Validates PR title format
  - Runs lint, format, test, build
  - Shows version preview in PR comments
  - Detects breaking changes

### 2. CI/CD Pipeline (`ci-cd.yml`)
- **Trigger**: Push to main branch
- **Purpose**: Automated release pipeline
- **Features**:
  - Quality checks (analyze, test, build)
  - Automatic versioning based on conventional commits
  - Changelog generation
  - Publishing to artifactory
  - GitHub release creation

### 3. Manual Release (`manual-release.yml`)
- **Trigger**: Manual workflow dispatch
- **Purpose**: Manual control over releases
- **Options**:
  - Release type: patch, minor, major, prerelease, graduate
  - Dry run mode for testing
  - Package selection

## 🔄 Release Process

### Automatic (Recommended)

```mermaid
graph LR
    A[Feature Development] --> B[Conventional Commit]
    B --> C[Create PR]
    C --> D[PR Checks]
    D --> E[Code Review]
    E --> F[Merge to Main]
    F --> G[Auto Version & Publish]
```

### Manual (When Needed)

```mermaid
graph LR
    A[Go to Actions Tab] --> B[Select Manual Release]
    B --> C[Choose Options]
    C --> D[Run Workflow]
    D --> E[Review Results]
```

## 📝 Conventional Commits

Use these commit formats for automatic versioning:

| Type | Version Bump | Example |
|------|-------------|---------|
| `fix:` | Patch | `fix: resolve memory leak in provider` |
| `feat:` | Minor | `feat: add new authentication method` |
| `feat!:` | Major | `feat!: redesign dependency injection API` |
| `BREAKING CHANGE:` | Major | `refactor: simplify API` + body with `BREAKING CHANGE:` |

## 🏛️ Artifactory Configuration

### JFrog Cloud Setup

1. Create a Dart repository in JFrog
2. Get repository URL: `https://your-company.jfrog.io/artifactory/api/pub/dart`
3. Create API key for CI/CD user
4. Add secrets to GitHub

### Self-Hosted Setup

1. Configure Dart repository
2. URL format: `https://artifactory.your-company.com/artifactory/api/pub/dart`
3. Create service account for CI/CD
4. Add credentials to GitHub secrets

## 📊 Monitoring

### GitHub Actions

Monitor workflow runs in the `Actions` tab:

- ✅ **Green**: All checks passed, release successful
- ❌ **Red**: Issues detected, release blocked
- 🟡 **Yellow**: Warnings or partial failures

### Release Artifacts

Check these outputs after successful releases:

- **GitHub Releases**: Automatic release notes
- **Git Tags**: Individual package tags (`pillar_core@1.2.0`)
- **Artifactory**: Published packages
- **Changelogs**: Updated CHANGELOG.md files

## 🔍 Troubleshooting

### Common Issues

#### 1. Workflow Not Triggering
**Problem**: Workflow doesn't run on PR/push
**Solutions**:
- Check workflow file syntax
- Ensure files are in `.github/workflows/`
- Verify branch names match triggers

#### 2. Secrets Not Working
**Problem**: Artifactory authentication fails
**Solutions**:
- Verify secret names match exactly
- Check artifactory URL format
- Test credentials manually

#### 3. Version Not Updated
**Problem**: Package versions don't change
**Solutions**:
- Use conventional commit format
- Check if packages actually changed
- Verify Melos configuration

#### 4. Publishing Fails
**Problem**: Packages fail to publish
**Solutions**:
- Check artifactory permissions
- Verify package doesn't already exist
- Review network connectivity

### Debug Commands

```bash
# Test Melos configuration locally
melos bootstrap
melos list --long
melos run version:check

# Preview version changes
melos version --no-git-tag-version --no-git-commit-version --all --yes

# Check dependency graph
melos run deps:graph
```

## 🔐 Security

### Best Practices

1. **Secrets Management**
   - Use repository secrets, never hardcode
   - Rotate credentials regularly
   - Use least-privilege access

2. **Branch Protection**
   - Protect main branch from direct pushes
   - Require PR reviews
   - Only allow CI bot to create version commits

3. **Access Control**
   - Limit repository collaborators
   - Use teams for permission management
   - Monitor access logs

## 📈 Optimization

### Performance Tips

1. **Caching**
   - Flutter SDK is cached automatically
   - Dependencies are cached between runs
   - Use `cache: true` in setup actions

2. **Parallelization**
   - Jobs run in parallel when possible
   - Melos commands use parallel execution
   - Separate concerns into different jobs

3. **Resource Usage**
   - Set appropriate timeouts
   - Use `ubuntu-latest` for faster startup
   - Cancel redundant runs with concurrency groups

## 🎯 Next Steps

1. **Set up secrets** in GitHub repository settings
2. **Enable branch protection** for main branch
3. **Test the pipeline** with a small PR
4. **Configure notifications** (Slack/Discord) if needed
5. **Train your team** on conventional commits

## 📚 Documentation

- [VERSIONING.md](docs/VERSIONING.md) - Detailed versioning guide
- [CI-CD.md](docs/CI-CD.md) - Complete CI/CD documentation
- [SECRETS.md](.github/SECRETS.md) - Secrets configuration guide

---

Your CI/CD pipeline is now ready! 🚀

The system will automatically handle versioning, publishing, and changelog updates based on your conventional commits.
