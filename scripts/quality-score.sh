#!/usr/bin/env bash
# Compute codebase health score
set -euo pipefail

echo "========================================="
echo "  Codebase Health Score"
echo "========================================="

TOTAL=0
MAX=100

# Test coverage (25 points)
echo ""
echo "--- Test Coverage (25 pts) ---"
# Placeholder — replace with actual coverage extraction
echo "  [manual] Check coverage reports"

# Lint violations (20 points)
echo ""
echo "--- Lint Violations (20 pts) ---"
LINT_ERRORS=0
if [ -d "frontend" ]; then
  LINT_ERRORS=$((LINT_ERRORS + $(cd frontend && npx eslint . --format json 2>/dev/null | python3 -c "import sys,json; print(sum(len(f['messages']) for f in json.load(sys.stdin)))" 2>/dev/null || echo 0)))
fi
echo "  Lint errors: $LINT_ERRORS"

# Type errors (20 points)
echo ""
echo "--- Type Errors (20 pts) ---"
TYPE_ERRORS=0
if [ -d "frontend" ]; then
  TYPE_ERRORS=$(cd frontend && npx tsc --noEmit 2>&1 | grep "error TS" | wc -l || echo 0)
fi
echo "  Type errors: $TYPE_ERRORS"

# File size compliance (15 points)
echo ""
echo "--- File Size Compliance (15 pts) ---"
TOTAL_FILES=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.py" 2>/dev/null | grep -v node_modules | wc -l || echo 0)
LARGE_FILES=$(find . -name "*.ts" -o -name "*.tsx" -o -name "*.py" 2>/dev/null | grep -v node_modules | xargs wc -l 2>/dev/null | awk '$1 > 400 && !/total/' | wc -l || echo 0)
echo "  Total source files: $TOTAL_FILES"
echo "  Files over 400 lines: $LARGE_FILES"

# Tech debt (20 points)
echo ""
echo "--- Tech Debt (20 pts) ---"
echo "  [manual] Check docs/exec-plans/tech-debt-tracker.md"

echo ""
echo "========================================="
echo "  Score computation requires manual review"
echo "  See docs/references/QUALITY_SCORE.md"
echo "========================================="
