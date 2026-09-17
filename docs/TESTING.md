# Testing Guide

This guide explains the testing strategy and available test scripts for the Pillar monorepo.

## 📋 Available Test Scripts

### `melos run test`
**Default test script** - Runs tests for all packages except examples.
```bash
melos run test
```
- ✅ Excludes example applications (which may not have tests)
- ✅ Fast execution by ignoring non-essential packages
- ✅ Recommended for CI/CD pipelines

### `melos run test`
**Comprehensive testing** - Runs tests only for packages that have a `test/` directory.
```bash
melos run test
```
- ✅ Automatically detects packages with tests
- ✅ Skips packages without test directories
- ✅ Safe for all scenarios

### `melos run test:coverage`
**Inclusive testing** - Attempts to run tests for all packages with error tolerance.
```bash
melos run test:coverage
```
- ⚠️ May show errors for packages without tests
- ✅ Continues execution even if some packages fail
- 🔍 Useful for debugging test coverage

### `melos run test:integration`
**Integration tests** - Runs integration tests across packages.
```bash
melos run test:integration
```
- 🧪 Runs `flutter test integration_test`
- 🔗 Tests inter-package interactions
- 🚀 End-to-end testing scenarios

## 📦 Package Testing Strategy

### Core Packages (Required Tests)
These packages **must** have comprehensive tests:
- ✅ `pillar_core` - Foundation package with DI and architecture
- ✅ `pillar_remote_config` - Remote configuration management
- ✅ Future core packages

### Example Packages (Optional Tests)
These packages typically **don't need** tests:
- 📱 `pillar_core_example` - Demonstration app
- 📱 Other example applications
- 🎯 Focus is on showcasing functionality, not testing

### Utility Packages (Conditional Tests)
These packages **may or may not** have tests:
- 🛠️ `pillar_lint` - Linting rules (when created)
- 🔧 Build tools and utilities

## 🎯 Testing Best Practices

### Test Organization
```
package_name/
├── lib/
│   └── src/
│       ├── feature_a/
│       └── feature_b/
└── test/
    ├── feature_a/
    │   └── feature_a_test.dart
    ├── feature_b/
    │   └── feature_b_test.dart
    └── test_helpers/
        └── mocks.dart
```

### Test Naming Conventions
- Test files: `feature_name_test.dart`
- Test groups: `group('FeatureName', () { ... })`
- Test cases: `test('should do something when condition', () { ... })`

### Mock Management
```dart
// Use mocktail for mocking
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;
  
  setUp(() {
    mockRepository = MockUserRepository();
  });
  
  group('UserService', () {
    test('should return user when repository has data', () async {
      // Arrange
      when(() => mockRepository.getUser(any()))
          .thenAnswer((_) async => User(id: '1', name: 'John'));
      
      // Act
      final result = await userService.getUser('1');
      
      // Assert
      expect(result.name, equals('John'));
    });
  });
}
```

## 🚀 CI/CD Integration

### GitHub Actions
Tests run as part of `melos run ci:verify`, which is what a pull request
executes — the same command you can run locally:

```yaml
- name: Analyze, format, validate graph, test
  run: melos run ci:verify
```

Coverage runs separately, in `extended-checks.yml`, on demand.

### Local Development
For local development, use the appropriate script based on your needs:

```bash
# Fast loop
melos run test

# With lcov output under <package>/coverage/
melos run test:coverage

# Everything a PR must pass
melos run ci:verify
```

## 📊 Test Coverage

### Coverage Reports
Generate coverage reports for packages:

```bash
# Run tests with coverage
melos exec --dir-exists="test" -- "flutter test --coverage"

# Generate HTML coverage report
melos exec --dir-exists="test" -- "genhtml coverage/lcov.info -o coverage/html"
```

### Coverage Goals
- **Core packages**: Aim for >90% coverage
- **Feature packages**: Aim for >80% coverage
- **Example packages**: Coverage not required

## 🔍 Troubleshooting

### Common Issues

#### Package Without Tests
**Error**: `Test directory "test" does not appear to contain any test files.`
**Solutions**:
1. Use `melos run test` for the fast loop; `melos run test:coverage` when you need lcov output
2. Create a test directory with at least one test file
3. Exclude the package from test scripts

#### Test Dependencies Missing
**Error**: `Target of URI doesn't exist`
**Solutions**:
1. Run `melos bootstrap` to resolve dependencies
2. Check that test dependencies are properly declared
3. Ensure package imports use correct paths

#### Mock Setup Issues
**Error**: `Bad state: No implementation found`
**Solutions**:
1. Register fallback values for mock methods
2. Use `when()` to stub all required method calls
3. Check mock setup in `setUp()` method

### Debug Commands

```bash
# List packages with test directories
melos list --dir-exists="test"

# Run tests for specific package
melos exec --scope="pillar_core" -- "flutter test"

# Verbose test output
melos exec --dir-exists="test" -- "flutter test --reporter=expanded"
```

## 📈 Future Enhancements

### Planned Improvements
- [ ] Automated test generation for new packages
- [ ] Integration test framework setup
- [ ] Performance testing benchmarks
- [ ] Visual regression testing for UI components
- [ ] Automated coverage reporting in CI

### Test Utilities
Future packages may include:
- `pillar_test_utils` - Shared testing utilities
- `pillar_mocks` - Common mock implementations
- `pillar_fixtures` - Test data and fixtures

---

This testing strategy ensures high code quality while maintaining development velocity by focusing testing efforts where they matter most.
