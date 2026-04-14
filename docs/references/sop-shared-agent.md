# Shared Agent Operation SOP

Standard operating procedure for both Claude Code and Codex CLI.

## Standard Work Loop

### 1. Orient
- Read `docs/exec-plans/active/` — what's in progress?
- Read `docs/exec-plans/tech-debt-tracker.md` — any blockers in the target area?
- Read `ARCHITECTURE.md` — refresh structural constraints

### 2. Plan
- For non-trivial tasks: create exec-plan in `docs/exec-plans/active/`
- For trivial tasks (< 3 files): proceed directly but note the intent

### 3. Reproduce / Restate
- Bugs: reproduce the issue first, confirm root cause
- Features: restate requirements, confirm acceptance criteria

### 4. Implement
- Follow domain boundaries from `ARCHITECTURE.md`
- One logical change per commit
- Write tests alongside code (not after)

### 5. Verify
- Run `scripts/verify.sh`
- Fix any failures before proceeding
- For frontend: start dev server, test in browser

### 6. Self-Review
- Review own changes against architecture rules
- Check PR size (< 300 lines)
- Check for secrets, dead code, missing tests

### 7. Prepare PR
- Use `.github/PR_TEMPLATE.md`
- Compute quality score
- Present to human for approval

### 8. Respond to Review
- Address all comments
- Re-run verification after changes
- Request re-review

### 9. Complete
- After merge: move exec-plan to `completed/`
- Update tech-debt-tracker if applicable
- Clean up branches/worktrees

## Autonomy Levels

### Level 1: Supervised (Default)
- **Allowed**: read files, explore code, run tests, lint
- **Requires approval**: any file edit, any command execution, PR creation
- **Forbidden**: git push, dependency changes, config changes
- **Use when**: unfamiliar codebase, security-sensitive areas, new agent

### Level 2: Semi-Autonomous
- **Allowed**: file edits in `src/`, `tests/`, run verify pipeline, create branches
- **Requires approval**: PR creation, dependency changes, architecture changes
- **Forbidden**: git push --force, production changes, .env modifications
- **Use when**: well-tested areas, routine bug fixes, trusted agent with track record

### Level 3: Autonomous
- **Allowed**: all Level 2 + PR creation, auto-merge if quality score >= 8
- **Requires approval**: architecture changes, new dependencies, production access
- **Forbidden**: git push --force, .env modifications, bypassing CI
- **Use when**: established patterns, high test coverage, mature CI pipeline

## Escalation Triggers

Immediately stop and ask human when:
- Architecture rule would need to be broken
- Test coverage would drop below 80%
- Change affects authentication or authorization
- Data migration needed
- External service integration
- Ambiguous requirements
