#!/bin/bash
# pre-commit hook — auto-run make validate
# Install: make hook-install

set -e
cd "$(git rev-parse --show-toplevel)"

echo "🔍 Running make validate (pre-commit) ..."
make validate

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ make validate failed. Please fix the issues before committing."
    exit 1
fi
