#!/usr/bin/env bash
# Structural checks — enforce architecture rules
set -euo pipefail

FAILED=0

check() {
  if eval "$2"; then
    echo "  ✓ $1"
  else
    echo "  ✗ $1"
    FAILED=1
  fi
}

echo "--- Structure Check ---"

# Rule 1: No cross-domain imports in frontend
if [ -d "frontend/src/domains" ]; then
  CROSS_IMPORTS=$(grep -rn "from.*domains/" frontend/src/domains/ 2>/dev/null | grep -v "/shared/" | grep -v "from.*domains/$(basename)" | head -20 || true)
  if [ -z "$CROSS_IMPORTS" ]; then
    echo "  ✓ No cross-domain imports (frontend)"
  else
    echo "  ✗ Cross-domain imports found (frontend):"
    echo "$CROSS_IMPORTS" | head -5
    FAILED=1
  fi
fi

# Rule 2: No cross-domain imports in backend
if [ -d "backend/app/domains" ]; then
  CROSS_IMPORTS=$(grep -rn "from.*domains\." backend/app/domains/ 2>/dev/null | grep -v "\.shared" | head -20 || true)
  if [ -z "$CROSS_IMPORTS" ]; then
    echo "  ✓ No cross-domain imports (backend)"
  else
    echo "  ✗ Cross-domain imports found (backend):"
    echo "$CROSS_IMPORTS" | head -5
    FAILED=1
  fi
fi

# Rule 3: No files over 800 lines
LARGE_FILES=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.py" | xargs wc -l 2>/dev/null | awk '$1 > 800 && !/total/' | head -10 || true)
if [ -z "$LARGE_FILES" ]; then
  echo "  ✓ No files over 800 lines"
else
  echo "  ✗ Files over 800 lines:"
  echo "$LARGE_FILES"
  FAILED=1
fi

# Rule 4: No hardcoded secrets patterns
SECRETS=$(grep -rn "sk-\|password\s*=\s*[\"'][^\"']*[\"']\|api_key\s*=\s*[\"']" --include="*.ts" --include="*.tsx" --include="*.py" . 2>/dev/null | grep -v node_modules | grep -v ".env" | grep -v "test" | head -10 || true)
if [ -z "$SECRETS" ]; then
  echo "  ✓ No hardcoded secrets detected"
else
  echo "  ✗ Potential hardcoded secrets:"
  echo "$SECRETS"
  FAILED=1
fi

# Rule 5: No direct API calls from components (frontend)
if [ -d "frontend/src/domains" ]; then
  DIRECT_FETCH=$(grep -rn "fetch(\|axios\." frontend/src/domains/*/components/ 2>/dev/null | head -10 || true)
  if [ -z "$DIRECT_FETCH" ]; then
    echo "  ✓ No direct API calls from components"
  else
    echo "  ✗ Direct API calls in components:"
    echo "$DIRECT_FETCH"
    FAILED=1
  fi
fi

exit $FAILED
