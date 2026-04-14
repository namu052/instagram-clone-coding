# Quality Score

Standardized quality scoring for PRs and codebase health.

## PR Quality Score (0–10)

| Criterion | Weight | 0 (Fail) | 1 (Pass) | 2 (Excellent) |
|-----------|--------|----------|----------|---------------|
| Tests pass | 2x | Tests fail | All pass | All pass + new coverage |
| Lint clean | 1x | New warnings | Clean | Clean + fixes existing |
| Type safe | 1x | Type errors | Clean | Strict mode clean |
| Architecture | 2x | Violates rules | Follows rules | Improves structure |
| PR size | 1x | >500 lines | <300 lines | <150 lines |
| Self-review | 1x | None | Checklist done | Annotated diff |
| Documentation | 1x | Missing | Present | Linked to design doc |

**Score = sum of (criterion * weight) / max possible * 10**

| Score | Verdict |
|-------|---------|
| 8–10 | Auto-mergeable (if CI passes) |
| 6–7 | Minor revisions needed |
| 4–5 | Significant revisions needed |
| 0–3 | Reject, redesign needed |

## Codebase Health Score

Run `scripts/quality-score.sh` to compute:

| Metric | Weight | Measurement |
|--------|--------|-------------|
| Test coverage | 25% | `npm test -- --coverage` / `pytest --cov` |
| Lint violations | 20% | Count of warnings + errors |
| Type errors | 20% | `tsc --noEmit` / `mypy` error count |
| File size compliance | 15% | % of files under 400 lines |
| Tech debt score | 20% | From tech-debt-tracker.md |
