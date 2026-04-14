# Worktree Operation SOP

Isolation strategy for agent work.

## Purpose

Every agent task runs in an isolated environment to prevent cross-contamination and enable parallel work.

## Codex: Git Worktree

```bash
# Create worktree for task
git worktree add ../worktree-<ticket-id> -b codex/<ticket-id>-<desc>

# Work in worktree
cd ../worktree-<ticket-id>

# After merge, clean up
git worktree remove ../worktree-<ticket-id>
git branch -d codex/<ticket-id>-<desc>
```

## Claude Code: Branch Isolation

```bash
# Create feature branch
git checkout -b feature/<ticket-id>-<desc>

# Or use Claude's built-in worktree support
# (uses isolation: "worktree" in Agent tool)
```

## Rules

1. Never work directly on `main` or `develop`
2. One task per branch/worktree
3. Worktree lifetime: max 7 days
4. Abandoned worktrees: cleaned up in weekly maintenance
5. Verify worktree has latest `main` merged before starting

## Cleanup Schedule

| Condition | Action |
|-----------|--------|
| PR merged | Remove worktree + branch immediately |
| PR rejected | Archive branch, remove worktree |
| 7 days without activity | Notify owner, then remove after 3 more days |
| Orphaned worktree (no branch) | Remove immediately |
