# pub.dev Credentials Management Guide

This guide explains how to set up and maintain pub.dev authentication credentials for GitHub Actions with **automatic token refresh**.

## 🔄 Auto-Refresh Setup (Recommended)

The GitHub Actions workflows are configured to use the **complete credentials file** which includes a refresh token. This means:

- ✅ **Access tokens auto-refresh** - No manual rotation needed for short-lived tokens
- ✅ **Long-lived refresh tokens** - Typically valid for months/years  
- ✅ **Reliable CI/CD** - No more 1-hour token expiration issues
- ✅ **Less maintenance** - Only rotate when refresh token expires or security needs

## 📋 When to Update Credentials

- **Refresh token expired** - GitHub Actions fails with authentication errors after auto-refresh attempts
- **Security breach** - Suspected credentials compromise  
- **Team changes** - When team members with access leave
- **Account changes** - When switching pub.dev accounts

## 🔄 Token Rotation Process

### Step 1: Generate New Token

```bash
# Re-authenticate with pub.dev (this will generate a new token)
dart pub login
```

**Follow the interactive process:**
1. Browser will open to pub.dev
2. Sign in with your Google account
3. Grant permissions to pub client
4. Return to terminal when prompted

### Step 2: Copy Complete Credentials File

```bash
# View the complete credentials file
cat ~/.pub-cache/credentials.json
```

**Example output:**
```json
{
  "accessToken": "ya29.a0AfH6SMC_ACCESS_TOKEN_HERE...",
  "refreshToken": "1//04_REFRESH_TOKEN_HERE_IMPORTANT...",
  "tokenEndpoint": "https://oauth2.googleapis.com/token",
  "scopes": ["https://www.googleapis.com/auth/userinfo.email", "openid"],
  "expiration": 1234567890123
}
```

**Copy the COMPLETE JSON** (including the `refreshToken` which enables auto-refresh)

### Step 3: Update GitHub Secret

1. **Navigate to GitHub repository**
   - Go to `https://github.com/Core-Soft-Development/pillar`
   - Click **Settings** → **Secrets and variables** → **Actions**

2. **Update/Create the secret**
   - Find `PUB_CREDENTIALS` in the list (or create new if first time)
   - Click **Update** (or **New repository secret**)
   - **Name**: `PUB_CREDENTIALS`
   - **Value**: Paste the complete JSON from step 2
   - Click **Update secret** (or **Add secret**)

### Step 4: Verify Token Works

```bash
# Test authentication locally
dart pub token list

# Test publishing (dry-run)
melos publish --dry-run
```

**Expected output:**
```
✓ Publishing pillar_core 1.0.0 to https://pub.dartlang.org:
✓ Publishing pillar_remote_config 1.0.0 to https://pub.dartlang.org:
```

### Step 5: Test GitHub Actions

**Option A: Manual trigger**
- Go to **Actions** tab in GitHub
- Select **Manual Release** workflow
- Click **Run workflow**
- Choose `dry_run: true`
- Monitor for authentication success

**Option B: Push test commit**
```bash
# Make a small change to trigger CI
echo "# Token rotated $(date)" >> docs/TOKEN-ROTATION-LOG.md
git add docs/TOKEN-ROTATION-LOG.md
git commit -m "docs: rotate pub.dev token"
git push origin main
```

## 🚨 Troubleshooting

### Token Still Invalid
```
Error: 401 Unauthorized when accessing https://pub.dartlang.org
```

**Solutions:**
1. **Wait 5-10 minutes** - Token propagation can take time
2. **Re-authenticate again** - Run `dart pub login` once more
3. **Check token format** - Ensure no extra spaces/characters
4. **Verify account** - Ensure you're logged in to the correct pub.dev account

### GitHub Actions Still Failing
```
⚠️ PUB_TOKEN not configured, skipping publish
```

**Solutions:**
1. **Check secret name** - Must be exactly `PUB_TOKEN`
2. **Verify repository** - Secret must be in the correct repository
3. **Check permissions** - Ensure you have admin access to repository
4. **Re-add secret** - Delete and recreate the secret

### Publishing Permissions Error
```
Error: Insufficient permissions to publish package 'pillar_core'
```

**Solutions:**
1. **Check pub.dev account** - Visit package page on pub.dev
2. **Verify publisher status** - Ensure you're listed as a publisher
3. **Contact existing publishers** - Request publisher access if needed

## 📝 Token Rotation Log

Keep a record of token rotations for security auditing:

```markdown
## Token Rotation History

- **2024-01-15** - Initial token setup (User: john.doe@company.com)
- **2024-04-15** - Scheduled rotation (User: john.doe@company.com)
- **2024-07-15** - Security rotation after team change (User: jane.smith@company.com)
```

## 🔐 Security Best Practices

### Token Management
- ✅ **Rotate regularly** - Every 3-6 months minimum
- ✅ **Use dedicated account** - Consider a service account for CI/CD
- ✅ **Monitor usage** - Check pub.dev dashboard for unexpected activity
- ✅ **Document changes** - Keep rotation log updated

### Access Control
- ✅ **Limit GitHub access** - Only repository admins should manage secrets
- ✅ **Audit team changes** - Rotate tokens when team members leave
- ✅ **Use branch protection** - Prevent unauthorized workflow changes
- ✅ **Review logs** - Monitor GitHub Actions logs for anomalies

### Emergency Response
- 🚨 **Immediate rotation** - If token compromise suspected
- 🚨 **Revoke access** - Remove compromised users from pub.dev packages
- 🚨 **Audit packages** - Check for unauthorized package versions
- 🚨 **Update team** - Notify team of security incident

## 🔍 Verification Checklist

After token rotation, verify:

- [ ] Local authentication works (`dart pub login` successful)
- [ ] Dry-run publishing works (`melos publish --dry-run`)
- [ ] GitHub secret updated (`PUB_TOKEN` contains new value)
- [ ] GitHub Actions authentication works (manual trigger test)
- [ ] All packages can be published (no permission errors)
- [ ] Token expiration documented (for next rotation)

## 📞 Support

If you encounter issues:

1. **Check pub.dev status** - [https://status.pub.dev](https://status.pub.dev)
2. **Review GitHub Actions logs** - Look for specific error messages
3. **Consult pub.dev documentation** - [https://dart.dev/tools/pub/publishing](https://dart.dev/tools/pub/publishing)
4. **Create repository issue** - For team-specific problems

## 🔗 Related Documentation

- [Publishing Guide](PUBLISHING.md) - Complete publishing documentation
- [CI/CD Guide](CI-CD.md) - GitHub Actions workflow details
- [GitHub Secrets](../.github/SECRETS.md) - All required secrets configuration

---

**Last updated:** $(date +"%Y-%m-%d")  
**Next rotation due:** $(date -d "+3 months" +"%Y-%m-%d")
