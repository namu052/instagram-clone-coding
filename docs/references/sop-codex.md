# Codex CLI Execution SOP

Codex-specific procedures, layered on top of the shared agent SOP.

## Startup Sequence

1. Codex reads `AGENTS.md` (automatic)
2. Codex loads `.codex/config.toml` (automatic)
3. Agent reads `ARCHITECTURE.md`
4. Agent reads `docs/exec-plans/active/`
5. Agent begins work loop (see shared SOP)

## Config Profiles

| Profile | File | Use When |
|---------|------|----------|
| Default | `.codex/config.toml` | Normal development |
| Conservative | `.codex/config.conservative.toml` | Security work, hotfixes |
| Semi-auto | `.codex/config.semi-autonomous.toml` | Routine tasks, trusted areas |

Switch profile: `codex --config .codex/config.conservative.toml`

## Worktree Strategy

- Every task gets an isolated git worktree
- Branch: `codex/<ticket>-<desc>`
- Worktree cleaned up after merge or abandonment (max 7 days)
- Never work on `main` directly

## Approval Request Template

When Codex needs human approval:

```
## Approval Request

**Action**: <what Codex wants to do>
**Reason**: <why this action is needed>
**Risk**: Low | Medium | High
**Files affected**: <list>
**Reversible**: Yes | No
**Alternative**: <what else could be done>

Approve? [y/n]
```

## Dangerous Command Control

| Command Pattern | Policy |
|----------------|--------|
| `rm -rf` | BLOCKED always |
| `git push --force` | BLOCKED always |
| `git reset --hard` | BLOCKED always |
| `DROP TABLE` / `DELETE FROM` | BLOCKED always |
| `chmod 777` | BLOCKED always |
| `git push` | Requires approval |
| `npm install <new>` | Requires approval |
| `pip install <new>` | Requires approval |
| Database migrations | Requires approval |

## Sandbox Boundaries

- **Filesystem**: write only to `src/`, `tests/`, `scripts/`, `docs/` (configurable)
- **Network**: disabled by default
- **Processes**: cannot spawn long-running background processes
- **Git**: can commit, cannot push without approval
