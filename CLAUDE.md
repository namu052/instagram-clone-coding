# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Read Order

1. **This file** — Claude Code runtime guidance
2. `ARCHITECTURE.md` — system structure and layer rules
3. `docs/design-docs/index.md` — current design decisions
4. `docs/exec-plans/active/` — in-progress execution plans
5. `docs/product-specs/index.md` — product requirements

## Project

Instagram clone: Next.js (frontend) + FastAPI (backend) + PostgreSQL (database).

## Build & Dev Commands

```bash
# Frontend
cd frontend && npm install && npm run dev      # dev server :3000
cd frontend && npm run build                    # production build
cd frontend && npm run lint                     # ESLint
cd frontend && npm run test                     # Vitest unit tests
cd frontend && npm run test -- --run path/to/file.test.ts  # single test

# Backend
cd backend && pip install -r requirements.txt
cd backend && uvicorn app.main:app --reload     # dev server :8000
cd backend && pytest                            # all tests
cd backend && pytest tests/path/to/test.py -k test_name  # single test

# Full verification
scripts/verify.sh                               # lint + typecheck + test + build
```

## Claude-Specific Guidance

### Skills

Custom skills are in `.claude/skills/`:
- `explore-codebase` — structured codebase exploration
- `create-exec-plan` — write execution plans to `docs/exec-plans/active/`
- `run-verification` — run full verification pipeline
- `prepare-pr` — prepare PR with self-review

### Hooks

Hooks enforce quality gates automatically:
- **PreToolUse**: block writes to protected paths, warn on risky commands
- **PostToolUse**: auto-format on edit, typecheck on `.ts/.tsx` edit
- **Stop**: run `scripts/verify.sh` before session end

### Execution Rules

- Always read `docs/exec-plans/active/` before starting work
- Run `scripts/verify.sh` before any PR
- Never modify `AGENTS.md`, `.codex/`, or `.github/workflows/` directly
- Start dev server and test UI in browser for frontend changes
- Commit messages follow: `<type>: <description>`

### Shared Policies

All architecture rules, testing requirements, security policies, and quality gates
are defined in shared docs — not duplicated here:

- Architecture constraints → `ARCHITECTURE.md`
- Verification commands → `scripts/verify.sh`
- Quality gates → `docs/references/QUALITY_SCORE.md`
- Security policy → `docs/references/SECURITY.md`
- PR standards → `.github/PR_TEMPLATE.md`
