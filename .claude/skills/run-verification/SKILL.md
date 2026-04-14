# Skill: Run Verification

Execute the full verification pipeline and report results.

## When to Use

- Before creating a PR
- After completing a phase of an exec-plan
- When asked to verify current state

## Procedure

1. Run `scripts/verify.sh` and capture output
2. If any step fails:
   a. Identify the failure
   b. Fix if straightforward (lint, format, simple type error)
   c. Re-run verification
   d. If fix is non-trivial, report to user
3. Report results in this format:

```
## Verification Results
- Lint (frontend): PASS/FAIL
- Lint (backend): PASS/FAIL
- TypeCheck: PASS/FAIL
- Unit Tests (frontend): PASS/FAIL (coverage: XX%)
- Unit Tests (backend): PASS/FAIL (coverage: XX%)
- Build: PASS/FAIL
- Structure Check: PASS/FAIL
```

## Auto-Fix Rules

| Failure | Auto-fix allowed |
|---------|-----------------|
| Formatting | Yes — run prettier/ruff format |
| Unused imports | Yes — remove them |
| Missing type annotation | No — requires design decision |
| Test failure | No — investigate first |
| Build failure | No — investigate first |
| Structure violation | No — requires architecture review |
