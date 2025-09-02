# Scripts

This directory contains utility scripts for development, building, and deployment of the Pillar monorepo.

## Available Scripts

### Development Scripts

- `setup.sh` - Initial development environment setup
- `bootstrap.sh` - Bootstrap the monorepo with all dependencies
- `clean.sh` - Clean all packages and reset the workspace

### Build Scripts

- `build_all.sh` - Build all packages and examples
- `build_runner.sh` - Run code generation for all packages
- `analyze.sh` - Run static analysis on all packages

### Testing Scripts

- `test_all.sh` - Run all tests across packages
- `test_integration.sh` - Run integration tests
- `coverage.sh` - Generate code coverage reports

### Release Scripts

- `version.sh` - Update versions across packages
- `publish.sh` - Publish packages to pub.dev
- `release.sh` - Complete release workflow

### Utility Scripts

- `format.sh` - Format code across all packages
- `deps_check.sh` - Check for dependency updates
- `docs_generate.sh` - Generate API documentation

## Usage

All scripts should be run from the root directory of the monorepo:

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run a script
./scripts/setup.sh
```

## Script Requirements

When creating new scripts:

1. **Make them executable**: `chmod +x script_name.sh`
2. **Add error handling**: Use `set -e` to exit on errors
3. **Include help text**: Add usage instructions
4. **Test thoroughly**: Ensure scripts work in different environments
5. **Document in this README**: Add description and usage

## Environment Variables

Scripts may use the following environment variables:

- `FLUTTER_ROOT` - Path to Flutter SDK
- `DART_ROOT` - Path to Dart SDK
- `PUB_CACHE` - Pub cache directory
- `CI` - Set to true in CI environments

## CI/CD Integration

These scripts are designed to work in both local development and CI/CD environments. They should:

- Handle both interactive and non-interactive modes
- Provide clear error messages
- Exit with appropriate status codes
- Be idempotent when possible

## Contributing

When adding new scripts:

1. Follow the naming convention: `action_target.sh`
2. Include proper error handling
3. Add documentation to this README
4. Test in multiple environments
5. Consider CI/CD requirements
