# Fullstack Dev Kit

A DevSync configuration package providing development standards for teams building TypeScript/React frontends with Python API backends. Includes coding conventions, MCP server configurations, pre-commit hooks, developer commands, and shared editor settings.

## What's Included

### Instructions

- **react-patterns** -- Functional component patterns, hooks usage, TypeScript integration, state management, and testing conventions for React applications.
- **api-design** -- REST API conventions covering endpoint structure, error handling, pagination, versioning, authentication patterns, and request/response formats.
- **database-patterns** -- Database migration workflows, query optimization, ORM usage patterns, indexing strategies, and connection management.

### MCP Servers

- **postgres** -- PostgreSQL MCP server for running queries, inspecting schemas, and managing database operations directly from your AI coding assistant. Requires a `DATABASE_URL` credential.
- **filesystem** -- Filesystem MCP server for navigating and reading project files within the allowed project directory.

### Hooks

- **pre-commit** -- Runs frontend linting (ESLint, TypeScript type checking) and backend linting (Ruff, MyPy) before each commit. Ensures code quality gates are enforced locally.

### Commands

- **dev** -- A `/dev` slash command that starts both the frontend development server (Vite/Next.js) and the backend API server (uvicorn/gunicorn) in parallel.

### Resources

- **.gitignore** -- A comprehensive gitignore covering Python virtual environments, Node modules, build artifacts, IDE files, and environment secrets for fullstack projects.
- **.editorconfig** -- Shared editor configuration enforcing consistent indentation, line endings, and file formatting across the team.

## Installation

Install the package using the `aiconfig` CLI:

```bash
aiconfig package install ./devsync-fullstack-package --ide claude
```

To install for a different IDE:

```bash
aiconfig package install ./devsync-fullstack-package --ide cursor
aiconfig package install ./devsync-fullstack-package --ide windsurf
aiconfig package install ./devsync-fullstack-package --ide copilot
```

To overwrite existing files during installation:

```bash
aiconfig package install ./devsync-fullstack-package --ide claude --conflict overwrite
```

## IDE Compatibility

Not all IDEs support every component type. The installer automatically skips unsupported components.

| Component Type | Claude Code | Cursor | Windsurf | Copilot | Cline | Roo Code | Kiro | Codex |
|---------------|-------------|--------|----------|---------|-------|----------|------|-------|
| Instructions  | Yes         | Yes    | Yes      | Yes     | Yes   | Yes      | Yes  | Yes   |
| MCP Servers   | Yes         | No     | No       | No      | No    | Yes      | No   | No    |
| Hooks         | Yes         | No     | No       | No      | No    | No       | No   | No    |
| Commands      | Yes         | No     | No       | No      | No    | Yes      | No   | No    |
| Resources     | Yes         | Yes    | Yes      | No      | Yes   | Yes      | Yes  | Yes   |

For the fullest experience, use Claude Code which supports all component types. Other IDEs will still receive the instruction files and resources.

## Managing Installed Packages

List installed packages:

```bash
aiconfig package list
```

Uninstall this package:

```bash
aiconfig package uninstall fullstack-dev-kit
```

## Requirements

- DevSync CLI (`pip install devsync`)
- Python 3.10+
- An active project directory with a recognized project root (`.git/`, `pyproject.toml`, `package.json`, etc.)

## License

MIT
