# Human Approval SOP

When and how human approval is required.

## Always Requires Approval

| Action | Reason |
|--------|--------|
| New dependency | Supply chain risk |
| Architecture change | System-wide impact |
| Database migration | Data integrity |
| Production deployment | User-facing impact |
| Security policy change | Compliance |
| CI/CD pipeline change | Build integrity |
| `.env` / secrets change | Credential safety |

## Approval Format

Agent presents:

```
## Approval Needed

**What**: <specific action>
**Why**: <business/technical reason>
**Risk**: Low / Medium / High
**Reversible**: Yes / No / Partial
**Impact**: <what breaks if this goes wrong>
**Alternative**: <other option if this is rejected>
```

Human responds:
- **Approve**: agent proceeds
- **Reject**: agent stops and asks for guidance
- **Modify**: human adjusts the approach, agent follows

## Response Time Expectations

- If no response within 30 minutes: agent pauses the task, moves to another task or stops
- Agent must never assume approval by default
- Agent must never retry the same approval request without new information

## Audit Trail

All approvals must be traceable:
- In exec-plan notes (with date)
- In PR description (reference to approval)
- In commit message (if relevant)
