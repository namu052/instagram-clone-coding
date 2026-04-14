# Commit Convention

## Format

```
<type>: <description>

<optional body>

Co-Authored-By: <agent-name> <email>
```

## Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| refactor | Code restructuring without behavior change |
| docs | Documentation only |
| test | Adding or updating tests |
| chore | Maintenance (dependencies, config) |
| perf | Performance improvement |
| ci | CI/CD changes |

## Rules

- Description: imperative mood, lowercase, no period, under 72 characters
- Body: explain "why" not "what" — the diff shows what
- One logical change per commit
- Reference exec-plan ID if applicable: `feat: add user auth (EP-0001)`
