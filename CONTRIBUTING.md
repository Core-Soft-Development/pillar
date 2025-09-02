# Contributing to Pillar

Thank you for your interest in contributing to Pillar! This document provides guidelines and instructions for contributing to this Flutter monorepo.

## Code of Conduct

By participating in this project, you agree to abide by our Code of Conduct. Please treat all contributors and users with respect.

## Getting Started

### Prerequisites

- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.2.0)
- Git
- [Melos](https://melos.invertase.dev/) for monorepo management

### Development Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/pillar.git
   cd pillar
   ```
3. Install Melos globally:
   ```bash
   dart pub global activate melos
   ```
4. Bootstrap the workspace:
   ```bash
   melos bootstrap
   ```

## Development Workflow

### Branch Naming

Use descriptive branch names with the following prefixes:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements

Example: `feature/user-authentication` or `fix/login-validation`

### Coding Standards

This project follows strict coding standards based on Flutter and Dart best practices:

#### General Principles
- Use English for all code and documentation
- Write concise, technical Dart code with accurate examples
- Use functional and declarative programming patterns where appropriate
- Prefer composition over inheritance
- Use descriptive variable names with auxiliary verbs (e.g., `isLoading`, `hasError`)

#### File Structure
- Structure files: exported widget, subwidgets, helpers, static content, types
- Don't leave blank lines within a function

#### Naming Conventions
- Use PascalCase for classes
- Use camelCase for variables, functions, and methods
- Use underscores_case for file and directory names
- Use UPPERCASE for environment variables
- Avoid magic numbers and define constants
- Start each function with a verb
- Use verbs for boolean variables (e.g., `isLoading`, `hasError`, `canDelete`)

#### Functions
- Write short functions with a single purpose (less than 20 instructions)
- Name functions with a verb and something else
- Use early returns to avoid nesting
- Use arrow functions for simple functions (less than 3 instructions)
- Declare necessary types for input arguments and output

#### Imports
- Always use package imports even for project files
- Comply with the `always_use_package_imports` rule
- Avoid relative imports for files in `lib/`

#### Flutter/Dart Specific
- Use const constructors for immutable widgets
- Prefer super constructor
- Leverage Freezed for immutable state classes and unions
- Use arrow syntax for simple functions and methods
- Use trailing commas for better formatting and diffs

### Code Quality

Before submitting a pull request, ensure your code passes all quality checks:

```bash
# Run static analysis
melos analyze

# Format code
melos format

# Run tests
melos test

# Generate code if needed
melos build_runner
```

### Testing

- Write unit tests for all public functions
- Write widget tests for all widgets
- Write integration tests for complex features
- Follow the Arrange-Act-Assert convention for tests
- Use descriptive test names
- Use mocktails for mocking

### Documentation

- Document complex logic and non-obvious code decisions
- Update README.md if adding new packages or features
- Update CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/) format
- Add inline documentation for public APIs

## Pull Request Process

1. **Create a feature branch** from `develop`
2. **Make your changes** following the coding standards
3. **Add or update tests** for your changes
4. **Update documentation** as needed
5. **Run quality checks** and ensure all pass
6. **Commit your changes** with descriptive commit messages
7. **Push to your fork** and create a pull request
8. **Fill out the PR template** completely
9. **Request review** from maintainers

### Commit Messages

**MANDATORY**: This project enforces [Conventional Commits](https://www.conventionalcommits.org/) specification.

#### Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types (Required)
- `feat:` - A new feature
- `fix:` - A bug fix
- `docs:` - Documentation only changes
- `style:` - Changes that do not affect the meaning of the code
- `refactor:` - A code change that neither fixes a bug nor adds a feature
- `perf:` - A code change that improves performance
- `test:` - Adding missing tests or correcting existing tests
- `build:` - Changes that affect the build system or external dependencies
- `ci:` - Changes to CI configuration files and scripts
- `chore:` - Other changes that don't modify src or test files
- `revert:` - Reverts a previous commit

#### Scopes (Optional)
- `core` - Core utilities and base classes
- `ui` - UI components and widgets
- `auth` - Authentication and user management
- `network` - HTTP client and API utilities
- `di` - Dependency injection
- `firebase` - Firebase integration
- `docs` - Documentation
- `config` - Configuration files

#### Examples
```bash
feat: add user authentication
fix(auth): resolve login validation issue
docs: update README with installation steps
refactor(api): simplify user service logic
perf(ui): optimize widget rendering
test(core): add unit tests for utility functions
```

#### Validation
- Git hooks automatically validate commit messages
- CI/CD pipeline validates all commits in PRs
- Invalid commits will be rejected

#### Setup Git Hooks
Run this command after cloning to enable commit validation:
```bash
./scripts/install_hooks.sh
```

### Pull Request Guidelines

- Keep PRs focused and atomic
- Include a clear description of changes
- Reference related issues with `Fixes #issue-number`
- Ensure CI passes before requesting review
- Be responsive to feedback and suggestions

## Package Development

When creating new packages:

1. Create package in `packages/` directory
2. Follow the established package structure
3. Include comprehensive README.md
4. Add appropriate dependencies
5. Write thorough tests
6. Update root README.md to include the new package

## Issue Reporting

When reporting issues:

- Use the issue templates provided
- Include reproduction steps
- Provide relevant code snippets
- Specify Flutter/Dart versions
- Include stack traces for crashes

## Questions and Support

- Check existing issues and discussions first
- Use GitHub Discussions for questions
- Join our community channels (if available)
- Contact maintainers for urgent matters

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for significant contributions
- README.md contributors section
- Release notes for major contributions

Thank you for contributing to Pillar!
