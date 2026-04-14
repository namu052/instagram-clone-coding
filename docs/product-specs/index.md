# Product Specs Index

Source of truth for product requirements and feature specifications.

## Active Specs

| ID | Feature | Status | Priority | Last Updated |
|----|---------|--------|----------|-------------|
| — | (none yet) | — | — | — |

## How to Use

1. Create a new file: `docs/product-specs/PS-NNNN-<feature-name>.md`
2. Use the template below
3. Update this index
4. Create a corresponding exec-plan when implementation begins

## Template

```markdown
# PS-NNNN: <Feature Name>

- **Status**: Draft | Approved | In Progress | Completed
- **Priority**: P0 | P1 | P2 | P3
- **Author**: <name>
- **Date**: <YYYY-MM-DD>

## Problem Statement

What user problem does this solve?

## Requirements

### Functional
1. ...

### Non-Functional
1. ...

## Acceptance Criteria

- [ ] ...

## Out of Scope

- ...

## Related

- Design doc: (link)
- Exec plan: (link)
```

## Lifecycle

- **Draft** → gathering requirements
- **Approved** → ready for implementation
- **In Progress** → exec-plan created, work started
- **Completed** → shipped and verified

## Staleness Rule

Specs in Draft for 30+ days → review or archive. Specs in Approved for 60+ days without an exec-plan → escalate.
