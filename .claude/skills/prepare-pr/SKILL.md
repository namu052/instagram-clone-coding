# Skill: Prepare PR

Prepare a pull request with self-review and quality checks.

## When to Use

- After completing an exec-plan or task
- After verification passes

## Procedure

1. Run `run-verification` skill — must pass
2. Review all changed files:
   - Check against `ARCHITECTURE.md` constraints
   - Check for hardcoded secrets
   - Check for adequate test coverage (80%+)
   - Check file sizes (< 400 lines preferred)
3. Write PR description using `.github/PR_TEMPLATE.md`
4. Self-review checklist:
   - [ ] Changes match the exec-plan objective
   - [ ] No unrelated changes included
   - [ ] Tests cover new/changed behavior
   - [ ] No TODO comments without tech-debt-tracker entries
   - [ ] Commit messages follow convention
5. Compute PR quality score (see `docs/references/QUALITY_SCORE.md`)
6. If score < 6, improve before submitting
7. Present PR summary to user for final approval

## PR Size Limits

| Size | Lines Changed | Verdict |
|------|--------------|---------|
| Small | < 150 | Ideal |
| Medium | 150–300 | Acceptable |
| Large | 300–500 | Split if possible |
| Too Large | > 500 | Must split |

## Branch Naming

- Feature: `feature/<ticket-id>-<short-desc>`
- Fix: `fix/<ticket-id>-<short-desc>`
- Refactor: `refactor/<short-desc>`
