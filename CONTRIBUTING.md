# Contributing to Kora

Thank you for your interest in contributing to Kora!

## Development Guidelines

1. **Safety First**: Never bypass `PermissionManager` or `CommandRunner` safety checks.
2. **Modular Architecture**: Ensure changes maintain clear separation between UI, Scanner, Build Engine, Builders, and Database.
3. **Automated Testing**: Write unit tests for new features under `tests/`.
4. **Code Quality**: Keep functions modular, type-annotated, and documented with docstrings.

## Running Tests

```bash
PYTHONPATH=. pytest -v tests/
```
