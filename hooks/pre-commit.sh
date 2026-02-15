#!/usr/bin/env bash
set -euo pipefail

echo "Running pre-commit checks..."

FAILED=0

# Frontend checks
if [ -d "frontend" ] || [ -d "client" ] || [ -d "web" ]; then
    FRONTEND_DIR=""
    for dir in frontend client web; do
        if [ -d "$dir" ]; then
            FRONTEND_DIR="$dir"
            break
        fi
    done

    if [ -n "$FRONTEND_DIR" ]; then
        echo "-- Checking frontend ($FRONTEND_DIR) --"

        if [ -f "$FRONTEND_DIR/package.json" ]; then
            # Determine package manager
            if [ -f "$FRONTEND_DIR/pnpm-lock.yaml" ]; then
                PKG_MGR="pnpm"
            elif [ -f "$FRONTEND_DIR/yarn.lock" ]; then
                PKG_MGR="yarn"
            else
                PKG_MGR="npm"
            fi

            # ESLint
            if $PKG_MGR --prefix "$FRONTEND_DIR" run lint --if-present 2>/dev/null; then
                echo "  ESLint: passed"
            else
                echo "  ESLint: FAILED"
                FAILED=1
            fi

            # TypeScript type check
            if $PKG_MGR --prefix "$FRONTEND_DIR" run typecheck --if-present 2>/dev/null; then
                echo "  TypeScript: passed"
            else
                echo "  TypeScript: FAILED"
                FAILED=1
            fi
        fi
    fi
fi

# Backend checks
if [ -d "backend" ] || [ -d "api" ] || [ -d "server" ]; then
    BACKEND_DIR=""
    for dir in backend api server; do
        if [ -d "$dir" ]; then
            BACKEND_DIR="$dir"
            break
        fi
    done

    if [ -n "$BACKEND_DIR" ]; then
        echo "-- Checking backend ($BACKEND_DIR) --"

        # Ruff linting
        if command -v ruff &>/dev/null; then
            if ruff check "$BACKEND_DIR"; then
                echo "  Ruff: passed"
            else
                echo "  Ruff: FAILED"
                FAILED=1
            fi
        else
            echo "  Ruff: skipped (not installed)"
        fi

        # MyPy type checking
        if command -v mypy &>/dev/null; then
            if mypy "$BACKEND_DIR" --ignore-missing-imports; then
                echo "  MyPy: passed"
            else
                echo "  MyPy: FAILED"
                FAILED=1
            fi
        else
            echo "  MyPy: skipped (not installed)"
        fi
    fi
fi

if [ "$FAILED" -ne 0 ]; then
    echo ""
    echo "Pre-commit checks failed. Fix the issues above before committing."
    exit 1
fi

echo "All pre-commit checks passed."
exit 0
