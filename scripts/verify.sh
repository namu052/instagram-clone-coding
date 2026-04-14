#!/usr/bin/env bash
# Shared verification pipeline — used by both Claude Code and Codex CLI
# Exit on first failure
set -euo pipefail

echo "========================================="
echo "  Shared Verification Pipeline"
echo "========================================="

FAILED=0

step() {
  echo ""
  echo "--- [$1] $2 ---"
}

pass() {
  echo "  ✓ $1 PASSED"
}

fail() {
  echo "  ✗ $1 FAILED"
  FAILED=1
}

# --- Frontend ---
if [ -d "frontend" ]; then
  step "1/6" "Frontend Lint"
  (cd frontend && npm run lint) && pass "Frontend Lint" || fail "Frontend Lint"

  step "2/6" "Frontend TypeCheck"
  (cd frontend && npx tsc --noEmit) && pass "Frontend TypeCheck" || fail "Frontend TypeCheck"

  step "3/6" "Frontend Tests"
  (cd frontend && npm run test -- --run) && pass "Frontend Tests" || fail "Frontend Tests"

  step "4/6" "Frontend Build"
  (cd frontend && npm run build) && pass "Frontend Build" || fail "Frontend Build"
else
  echo "  [skip] frontend/ not found"
fi

# --- Backend ---
if [ -d "backend" ]; then
  step "5/6" "Backend Lint"
  (cd backend && ruff check .) && pass "Backend Lint" || fail "Backend Lint"

  step "6/6" "Backend Tests"
  (cd backend && pytest --tb=short -q) && pass "Backend Tests" || fail "Backend Tests"
else
  echo "  [skip] backend/ not found"
fi

# --- Structure Check ---
step "7/7" "Structure Check"
if [ -f "scripts/check-structure.sh" ]; then
  bash scripts/check-structure.sh && pass "Structure Check" || fail "Structure Check"
else
  echo "  [skip] scripts/check-structure.sh not found"
fi

echo ""
echo "========================================="
if [ $FAILED -eq 0 ]; then
  echo "  ALL CHECKS PASSED"
else
  echo "  SOME CHECKS FAILED"
  exit 1
fi
echo "========================================="
