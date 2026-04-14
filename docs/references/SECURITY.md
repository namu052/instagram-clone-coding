# Security Policy

Mandatory for all agents and human contributors. Non-negotiable rules.

## Classification

| Level | Description | Example | Action |
|-------|-------------|---------|--------|
| Critical | Secret exposure, injection | Hardcoded API key | Immediate revert |
| High | Auth bypass, XSS | Missing CSRF token | Block merge |
| Medium | Missing rate limiting | Unbounded query | Fix within sprint |
| Low | Information leakage | Stack trace in 500 | Track as tech debt |

## Mandatory Rules

### Secrets
- **Never** hardcode secrets (API keys, passwords, tokens, connection strings)
- All secrets via environment variables
- `.env` files in `.gitignore` — always
- Rotate any secret found in git history immediately

### Input Validation
- Validate all user input at system boundary
- Frontend: Zod schemas
- Backend: Pydantic models
- Reject invalid input; never coerce silently

### SQL Injection
- No raw SQL string concatenation — ever
- Use SQLAlchemy ORM or parameterized queries only

### XSS
- No `dangerouslySetInnerHTML` without DOMPurify
- Use `textContent` over `innerHTML`
- CSP headers enabled

### Authentication & Authorization
- Every API endpoint must have auth middleware
- Role-based access control on sensitive operations
- JWT tokens with expiration
- Password hashing with bcrypt (cost factor >= 12)

### CSRF
- CSRF tokens on all state-changing requests
- SameSite cookie attribute set

### Rate Limiting
- All public endpoints rate-limited
- Auth endpoints: 5 attempts per minute per IP
- API endpoints: 100 requests per minute per user

## Public Sector / Internal Network Addendum

For government or restricted network environments:

- **Audit logging**: every state change must be logged with actor, timestamp, action, target
- **Data classification**: PII fields must be tagged in models
- **Access control**: principle of least privilege; no shared service accounts
- **Network**: assume no outbound internet; all dependencies vendored or mirrored
- **Approval**: production deployments require 2-person approval
- **Retention**: audit logs retained for minimum 3 years
- **Encryption**: data at rest and in transit; TLS 1.2+

## Agent-Specific Rules

### Codex CLI
- Sandbox mode prevents network access — cannot exfiltrate data
- Cannot modify `.env` files or secrets manager
- Cannot execute database migrations without human approval

### Claude Code
- PreToolUse hooks block writes to `.env`, credentials files
- Cannot execute `curl`, `wget`, or external HTTP calls to unknown hosts
- Must flag any file containing potential secrets during review
