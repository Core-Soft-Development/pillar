# GitHub Secrets Configuration

This document lists all the secrets and environment variables required for the CI/CD pipelines.

## Required Secrets

### Repository Secrets

Configure these secrets in your GitHub repository settings (`Settings > Secrets and variables > Actions`):

#### Artifactory Configuration
- **`ARTIFACTORY_URL`** - URL of your artifactory instance (e.g., `https://your-company.jfrog.io/artifactory/api/pub/dart`)
- **`ARTIFACTORY_USERNAME`** - Username for artifactory authentication
- **`ARTIFACTORY_PASSWORD`** - Password or API key for artifactory authentication

#### Optional Notification Secrets
- **`SLACK_WEBHOOK_URL`** - Slack webhook for release notifications (optional)
- **`DISCORD_WEBHOOK_URL`** - Discord webhook for release notifications (optional)

### Environment Variables

These are automatically available in GitHub Actions:

- **`GITHUB_TOKEN`** - Automatically provided by GitHub Actions
- **`GITHUB_ACTOR`** - Username of the person who triggered the workflow
- **`GITHUB_REF`** - Branch or tag ref that triggered the workflow

## Setting Up Secrets

### 1. Artifactory Setup

```bash
# Example artifactory URL formats:
# JFrog Cloud: https://your-company.jfrog.io/artifactory/api/pub/dart
# Self-hosted: https://artifactory.your-company.com/artifactory/api/pub/dart
```

### 2. GitHub Repository Settings

1. Go to your repository on GitHub
2. Click on `Settings` tab
3. Navigate to `Secrets and variables > Actions`
4. Click `New repository secret`
5. Add each secret with the exact name listed above

### 3. Testing Secrets

You can test if secrets are properly configured by running the manual release workflow with dry-run enabled.

## Security Best Practices

### Secret Management
- Use API keys instead of passwords when possible
- Rotate secrets regularly
- Use least-privilege access for artifactory users
- Never log secret values in workflows

### Access Control
- Limit repository access to trusted contributors
- Use branch protection rules for main/develop branches
- Require PR reviews for sensitive changes

### Monitoring
- Monitor artifactory access logs
- Set up alerts for failed releases
- Review workflow logs regularly

## Troubleshooting

### Common Issues

#### Artifactory Authentication Failed
```
Error: 401 Unauthorized
```
**Solution:** Check `ARTIFACTORY_USERNAME` and `ARTIFACTORY_PASSWORD` are correct.

#### Artifactory URL Not Found
```
Error: Could not resolve host
```
**Solution:** Verify `ARTIFACTORY_URL` is correct and accessible.

#### Missing Permissions
```
Error: Resource not accessible by integration
```
**Solution:** Ensure the repository has proper permissions and the `GITHUB_TOKEN` has write access.

### Debug Mode

To enable debug logging in workflows, add this secret:
- **`ACTIONS_RUNNER_DEBUG`** = `true`

## Workflow Permissions

The workflows require these permissions:

```yaml
permissions:
  contents: write      # For creating commits and tags
  packages: write      # For publishing packages
  pull-requests: write # For commenting on PRs
```

These are automatically configured in the workflow files.
