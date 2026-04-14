# Golden Rules

Inviolable rules that both Claude Code and Codex CLI must follow. These are enforced by CI, hooks, and structural checks.

## The 10 Rules

### 1. One Core, Two Thin Adapters
All substantive policy lives in shared docs. AGENTS.md and CLAUDE.md are pointers, not policy stores.

### 2. Source of Truth Hierarchy
`Code > ARCHITECTURE.md > docs/design-docs/ > docs/exec-plans/ > AGENTS.md/CLAUDE.md`

### 3. No Cross-Domain Imports
Domains are isolated. Use `shared/` for common code. No domain may import from a sibling domain.

### 4. Dependency Direction Is One-Way
Routes → Services → Repositories → Models. Never reverse. Never circular.

### 5. Same Quality Gate for All
Whether code was written by human, Claude, or Codex, it passes the same `scripts/verify.sh` pipeline.

### 6. Plan Before You Build
Non-trivial work (3+ files) requires an exec-plan in `docs/exec-plans/active/` before code is written.

### 7. Small PRs Only
Under 300 lines changed. If larger, split. No exceptions without explicit justification.

### 8. Immutability by Default
Never mutate objects or arrays. Create new ones. This applies to frontend state, API responses, and data transformations.

### 9. No Secrets in Code
All credentials via environment variables. `.env` in `.gitignore`. Hardcoded secrets = immediate revert.

### 10. Test What You Build
80% coverage minimum. Critical paths (auth, payments, data mutations) require 100% coverage.
