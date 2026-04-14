# Tech Debt Tracker

Source of truth for known technical debt. Updated by agents and humans.

## Scoring

| Score | Meaning | Action |
|-------|---------|--------|
| 1 | Minor — cosmetic or naming | Fix when touching the file |
| 2 | Moderate — duplication, missing tests | Plan within 2 sprints |
| 3 | Significant — wrong abstraction, brittle | Dedicate exec-plan |
| 4 | Critical — security risk, data loss risk | Fix immediately |

## Active Debt

| ID | Area | Description | Score | Filed | Owner | Status |
|----|------|-------------|-------|-------|-------|--------|
| — | — | (none yet) | — | — | — | — |

## Resolved Debt

| ID | Area | Description | Score | Filed | Resolved | PR |
|----|------|-------------|-------|-------|----------|-----|
| — | — | (none yet) | — | — | — | — |

## Rules

1. Any agent that introduces intentional shortcuts must add an entry here
2. Score 4 items block feature work until resolved
3. Review this tracker weekly; remove resolved items after 30 days
4. Items without movement for 60 days → escalate to Score +1
5. Agents must check this tracker before starting work in an affected area

## Quantification

Total debt score = sum of all active items' scores.

| Threshold | State | Action |
|-----------|-------|--------|
| 0–10 | Healthy | Continue |
| 11–25 | Watch | Dedicate 20% of next sprint |
| 26–50 | Warning | Stop features, address debt |
| 51+ | Critical | Full stop, debt sprint |
