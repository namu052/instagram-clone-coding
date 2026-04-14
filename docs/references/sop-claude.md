# Claude Code Execution SOP

Claude-specific procedures, layered on top of the shared agent SOP.

## Startup Sequence

1. Claude reads `CLAUDE.md` (automatic)
2. Claude loads skills from `.claude/skills/`
3. Hooks activate from settings
4. Agent reads `ARCHITECTURE.md`
5. Agent reads `docs/exec-plans/active/`
6. Agent begins work loop (see shared SOP)

## Skills Usage

| Skill | When to Use |
|-------|------------|
| `explore-codebase` | Starting any task in an unfamiliar area |
| `create-exec-plan` | Before non-trivial implementation (3+ files) |
| `run-verification` | Before any PR, after completing a phase |
| `prepare-pr` | When code is ready for review |

## Hooks Enforcement

Hooks are the automated guard rails. They run without user intervention:

- **PreToolUse**: blocks writes to `.env`, `AGENTS.md`, `.codex/`, `.github/workflows/`
- **PreToolUse**: warns on dangerous bash commands
- **PostToolUse**: auto-formats TS/Python files after edit
- **PostToolUse**: runs typecheck after TS edits
- **Stop**: reminds to run verify pipeline

See `.claude/hooks/hooks-design.md` for full specification.

## Interactive Capabilities

Claude Code can do things Codex cannot:
- Start dev server and observe output
- Take screenshots for UI verification
- Interactive debugging sessions
- Real-time user Q&A during execution

Use these capabilities actively — don't skip UI verification for frontend changes.

## Session Management

- If context window is getting large (many files read), summarize findings and focus
- Use skills to structure long sessions
- Create exec-plans for tasks that span sessions
- Update tech-debt-tracker before ending session if applicable
