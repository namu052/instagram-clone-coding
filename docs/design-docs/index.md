# Design Documents Index

Source of truth for architectural and technical decisions.

## Active Design Docs

| ID | Title | Status | Owner | Last Updated |
|----|-------|--------|-------|-------------|
| — | (none yet) | — | — | — |

## How to Use

1. Create a new file: `docs/design-docs/NNNN-<short-title>.md`
2. Use the template below
3. Update this index
4. Link from relevant exec-plan if applicable

## Template

```markdown
# DD-NNNN: <Title>

- **Status**: Draft | Review | Accepted | Superseded
- **Author**: <name>
- **Date**: <YYYY-MM-DD>
- **Supersedes**: (if applicable)

## Context

Why this decision is needed.

## Decision

What we decided and why.

## Alternatives Considered

What we rejected and why.

## Consequences

What changes as a result.
```

## Lifecycle

- **Draft** → author writes, gathers feedback
- **Review** → team reviews, agents can comment
- **Accepted** → becomes source of truth; update ARCHITECTURE.md if needed
- **Superseded** → replaced by newer DD; mark with link to successor

## Staleness Rule

Design docs without updates for 90 days must be reviewed. If still valid, update the date. If outdated, mark as Superseded or delete.
