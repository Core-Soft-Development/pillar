# GitHub Secrets Configuration

This document describes the required secrets for the CI/CD pipeline.

## Required Secrets

Configure these secrets in your GitHub repository settings (`Settings > Secrets and variables > Actions`):

### pub.dev Configuration
- **`PUB_CREDENTIALS`** - Complete credentials JSON file for pub.dev publishing (includes refresh token for auto-renewal)

### Optional Notification Secrets
- **`SLACK_WEBHOOK_URL`** - Webhook URL for Slack notifications (optional)
- **`DISCORD_WEBHOOK_URL`** - Webhook URL for Discord notifications (optional)

## Setting Up Secrets

### 1. pub.dev Setup

1. **Generate pub.dev token:**
   ```bash
   # Login to pub.dev locally first
   dart pub login
   
   # Get your credentials file
   cat ~/.pub-cache/credentials.json
   ```

2. **Copy complete credentials:**
   - Copy the ENTIRE JSON content from the credentials.json file
   - Include the `refreshToken` for automatic token renewal
   - This is your `PUB_CREDENTIALS` value

3. **Add to GitHub:**
   - Go to repository Settings > Secrets and variables > Actions
   - Click "New repository secret"
   - Name: `PUB_CREDENTIALS`
   - Value: The complete JSON from step 2

### 2. Notification Setup (Optional)

#### Slack
```bash
# Create a Slack webhook in your workspace
# Add the webhook URL as SLACK_WEBHOOK_URL secret
```

#### Discord
```bash
# Create a Discord webhook in your server
# Add the webhook URL as DISCORD_WEBHOOK_URL secret
```

## Security Best Practices

- Use tokens with minimal required permissions
- Rotate tokens regularly
- Never log secret values in workflows
- Use environment-specific secrets when possible

## Verification

Test your setup:
```bash
# Dry run to test authentication
melos publish --dry-run
```

## Troubleshooting

### Common Issues

#### pub.dev Authentication Failed
```
Error: 401 Unauthorized when accessing https://pub.dartlang.org
```
**Solution:** Check that `PUB_CREDENTIALS` contains valid JSON with both accessToken and refreshToken.

#### Token Expired
```
Error: Token has expired
```
**Solution:** Generate a new token using `dart pub login` and update the secret.

#### Missing Permissions
```
Error: Insufficient permissions to publish package
```
**Solution:** Ensure you have publisher permissions for the package on pub.dev.

## Token Management

### Rotating Tokens
1. Generate new token: `dart pub login`
2. Update GitHub secret with new token
3. Test with dry-run: `melos publish --dry-run`

### Monitoring
- Monitor pub.dev package dashboard
- Set up alerts for failed releases
- Review workflow logs regularly

## Package Publishing Process

1. **Authentication**: GitHub Actions uses `PUB_TOKEN` to authenticate
2. **Validation**: Packages are validated before publishing
3. **Publishing**: Only changed packages are published
4. **Verification**: Success/failure is reported in workflow logs

For more details, see the main [CI/CD documentation](../docs/CI-CD.md).
