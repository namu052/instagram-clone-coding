# AGENTS.md

This file provides guidance to Codex CLI when working with code in this repository.

## Read Order

1. **This file** — Codex runtime constraints
2. `ARCHITECTURE.md` — system structure and layer rules
3. `docs/design-docs/index.md` — current design decisions
4. `docs/exec-plans/active/` — in-progress execution plans
5. `docs/product-specs/index.md` — product requirements

## Project

Instagram clone: Next.js (frontend) + FastAPI (backend) + PostgreSQL (database).

## Codex-Specific Constraints

### Sandbox & Approval

- Default mode: `suggest` (propose changes, human approves)
- File writes limited to `src/`, `tests/`, `scripts/`, `docs/`
- Network access: disabled in sandbox
- No direct database mutations outside migrations
- No `rm -rf`, `git push --force`, `git reset --hard`

### Execution Rules

- Always read `docs/exec-plans/active/` before starting work
- Run `scripts/verify.sh` before proposing any PR
- Never modify `CLAUDE.md`, `.claude/`, or `.github/workflows/` directly
- Never install new dependencies without human approval
- Commit messages follow: `<type>: <description>` (see `docs/references/commit-convention.md`)

### Worktree Strategy

- Use isolated worktree for every task
- Branch naming: `codex/<ticket-id>-<short-desc>`
- Clean up worktree after merge or abandonment

### Shared Policies

All architecture rules, testing requirements, security policies, and quality gates
are defined in shared docs — not duplicated here:

- Architecture constraints → `ARCHITECTURE.md`
- Verification commands → `scripts/verify.sh`
- Quality gates → `docs/references/QUALITY_SCORE.md`
- Security policy → `docs/references/SECURITY.md`
- PR standards → `.github/PR_TEMPLATE.md`
