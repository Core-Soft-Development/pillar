# Documentation

This directory contains comprehensive documentation for the Pillar monorepo.

## 📚 Available Documentation

- **[VERSIONING.md](VERSIONING.md)** - Complete guide for package versioning and release management

## Structure

```
docs/
├── VERSIONING.md      # Package versioning and release management guide
├── architecture/      # Architecture guides and patterns
├── getting-started/   # Setup and initial development guides
├── packages/         # Package-specific documentation
├── examples/         # Code examples and tutorials
├── api/              # Generated API documentation
└── contributing/     # Contribution guidelines and workflows
```

## Documentation Types

### Versioning & Release Management
- Package versioning strategies
- Breaking changes management
- Release workflows (local vs production)
- CI/CD integration
- Dependency graph management

### Architecture Documentation
- Clean architecture principles
- Design patterns and best practices
- State management patterns
- Dependency injection setup

### Getting Started Guides
- Development environment setup
- First app creation
- Common workflows
- Troubleshooting

### Package Documentation
- Individual package guides
- API references
- Usage examples
- Migration guides

### Examples and Tutorials
- Step-by-step tutorials
- Code examples
- Best practices
- Common patterns

## Writing Documentation

When contributing documentation:

1. **Use clear, concise language**
2. **Include code examples** where relevant
3. **Follow the established structure**
4. **Update table of contents** when adding new sections
5. **Test all code examples** to ensure they work
6. **Use consistent formatting** (Markdown)

## Documentation Standards

- Use Markdown format (.md files)
- Include code syntax highlighting
- Add table of contents for longer documents
- Use relative links for internal references
- Include screenshots for UI-related documentation

## API Documentation

API documentation is automatically generated from dartdoc comments in the code. To generate:

```bash
# From the root directory
melos exec -- dart doc
```

## Building Documentation Site

If using a documentation site generator (like GitBook, Docusaurus, etc.):

```bash
# Instructions will be added when documentation site is set up
```

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on contributing to documentation.
