#!/bin/bash
# Install git hooks for this repository

set -e

HOOKS_DIR=".githooks"
GIT_HOOKS_DIR=".git/hooks"

echo "Installing git hooks..."

# Check if .git directory exists
if [ ! -d ".git" ]; then
    echo "Error: Not a git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    cp "$HOOKS_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
    chmod +x "$GIT_HOOKS_DIR/pre-commit"
    echo "✓ Installed pre-commit hook (blocks commits to main/development)"
else
    echo "Warning: $HOOKS_DIR/pre-commit not found"
fi

echo ""
echo "Git hooks installed successfully!"
echo ""
echo "The following protections are now active:"
echo "  - Direct commits to 'main' and 'development' branches are blocked"
echo "  - You must use feature branches for all changes"
echo ""
