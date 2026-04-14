# Reliability Policy

Standards for system reliability and operational stability.

## Error Handling

### Frontend
- Error boundaries at domain module level
- Failed API calls → user-friendly message, not stack trace
- Retry with exponential backoff for transient failures (max 3 retries)
- Offline state detection and graceful degradation

### Backend
- Global exception handler middleware
- Structured error responses: `{ "error": { "code": "...", "message": "..." } }`
- Never expose internal details in production error responses
- Log full error context server-side

## Database

- All schema changes via versioned migrations (Alembic)
- No manual DDL in production
- Connection pooling enabled
- Query timeout: 30 seconds default
- Migrations must be reversible

## Deployment

- Zero-downtime deployments (rolling update)
- Health check endpoint: `GET /health`
- Readiness check: `GET /ready`
- Rollback plan for every deployment

## Monitoring Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| API response time p95 | > 500ms | > 2000ms |
| Error rate | > 1% | > 5% |
| Database connection pool | > 80% | > 95% |
| Disk usage | > 70% | > 90% |

## Incident Response

1. Detect (monitoring alert)
2. Assess severity
3. Mitigate (rollback if needed)
4. Communicate (stakeholders)
5. Root cause analysis
6. Preventive action → tech debt tracker
