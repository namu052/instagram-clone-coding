# Skill: Explore Codebase

Structured codebase exploration for understanding before modifying.

## When to Use

- Starting a new task in an unfamiliar area
- Before writing an exec-plan
- When investigating a bug's root cause

## Procedure

1. Read `ARCHITECTURE.md` for system structure
2. Read `docs/exec-plans/active/` for current work context
3. Read `docs/exec-plans/tech-debt-tracker.md` for known issues in the area
4. Identify the domain module(s) involved
5. Map the relevant layers: route → service → repository → model
6. Identify cross-domain dependencies
7. Check test coverage for the affected area
8. Summarize findings before proceeding

## Output

Produce a brief summary:
- **Area**: which domain(s) and layer(s)
- **Key files**: paths to the most relevant files
- **Dependencies**: what this area depends on and what depends on it
- **Test coverage**: existing tests and gaps
- **Tech debt**: any tracked issues in this area
- **Risk**: what could break if we change this area
