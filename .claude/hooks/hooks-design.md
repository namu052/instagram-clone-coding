# Claude Code Hooks Design

These hooks are configured in `~/.claude/settings.json` or project `.claude/settings.json`.

## PreToolUse Hooks

### 1. Block Protected Path Writes
```json
{
  "matcher": "tool == 'Edit' || tool == 'Write'",
  "hooks": [{
    "type": "command",
    "command": "echo \"$file_path\" | grep -qE '\\.(env|pem|key)$|AGENTS\\.md|\\.codex/|\\.github/workflows/' && echo 'BLOCKED: Protected file' && exit 1 || exit 0"
  }]
}
```

### 2. Warn on Dangerous Commands
```json
{
  "matcher": "tool == 'Bash'",
  "hooks": [{
    "type": "command",
    "command": "echo \"$command\" | grep -qE 'rm -rf|git push --force|git reset --hard|DROP TABLE' && echo 'WARNING: Dangerous command detected. Confirm with user.' && exit 1 || exit 0"
  }]
}
```

### 3. Exec Plan Check
```json
{
  "matcher": "tool == 'Edit' || tool == 'Write'",
  "hooks": [{
    "type": "command",
    "command": "ls docs/exec-plans/active/*.md 2>/dev/null | head -1 > /dev/null || echo 'REMINDER: No active exec-plan found. Consider creating one.'"
  }]
}
```

## PostToolUse Hooks

### 4. Auto-Format on Edit
```json
{
  "matcher": "tool == 'Edit'",
  "hooks": [{
    "type": "command",
    "command": "echo \"$file_path\" | grep -qE '\\.(ts|tsx|js|jsx)$' && npx prettier --write \"$file_path\" || true"
  }],
},
{
  "matcher": "tool == 'Edit'",
  "hooks": [{
    "type": "command",
    "command": "echo \"$file_path\" | grep -qE '\\.py$' && ruff format \"$file_path\" || true"
  }]
}
```

### 5. TypeCheck After TS Edit
```json
{
  "matcher": "tool == 'Edit'",
  "hooks": [{
    "type": "command",
    "command": "echo \"$file_path\" | grep -qE '\\.(ts|tsx)$' && cd frontend && npx tsc --noEmit 2>&1 | tail -5 || true"
  }]
}
```

## Stop Hooks

### 6. Final Verification Reminder
```json
{
  "matcher": "true",
  "hooks": [{
    "type": "command",
    "command": "echo 'REMINDER: Run scripts/verify.sh before ending session'"
  }]
}
```

## Implementation Notes

- Hooks are the enforcement layer — they catch violations that documentation alone cannot prevent
- Keep hooks fast (< 5 seconds) to avoid disrupting workflow
- Hooks should fail gracefully — a broken hook should not block all work
- Test hooks manually before committing to settings
