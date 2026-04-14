# Skill: Create Execution Plan

Write a structured execution plan before starting non-trivial work.

## When to Use

- Any task touching 3+ files
- Any new feature implementation
- Any refactoring across domain boundaries
- Bug fixes where root cause is unclear

## Procedure

1. Run explore-codebase skill first
2. Copy `docs/exec-plans/active/_template.md` to `docs/exec-plans/active/EP-NNNN-<title>.md`
3. Fill in all sections:
   - Objective (one sentence)
   - Pre-conditions
   - Steps broken into phases
   - Verification criteria
   - Risks and mitigations
4. Review the plan against `ARCHITECTURE.md` constraints
5. Present to user for approval before executing

## Rules

- Plans must reference specific files and functions
- Each step must be independently verifiable
- Verification section must include `scripts/verify.sh`
- If the plan exceeds 15 files changed, split into multiple plans
- After completion, move to `docs/exec-plans/completed/` with results filled in
