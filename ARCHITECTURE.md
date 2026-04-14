# ARCHITECTURE.md

Source of truth for system structure. Both Claude Code and Codex CLI must follow these rules.

## System Overview

```
┌─────────────────────────────────────────────────┐
│                   Client (Browser)               │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│             Frontend (Next.js 14+)               │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │  Pages/   │ │Components│ │  State (Zustand)  │ │
│  │  Routes   │ │  (UI)    │ │  + React Query    │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
└──────────────────────┬──────────────────────────┘
                       │ REST / WebSocket
┌──────────────────────▼──────────────────────────┐
│              Backend (FastAPI)                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │  Routes   │ │ Services │ │  Repositories     │ │
│  │  (API)    │ │ (Logic)  │ │  (Data Access)    │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
└──────────────────────┬──────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────┐
│           PostgreSQL + Object Storage            │
└─────────────────────────────────────────────────┘
```

## Domain Modules

```
frontend/src/
├── domains/
│   ├── auth/          # login, register, session
│   ├── feed/          # home feed, explore
│   ├── post/          # create, view, edit posts
│   ├── profile/       # user profiles
│   ├── comment/       # comments
│   ├── notification/  # notifications
│   ├── message/       # direct messages
│   └── shared/        # shared UI components, hooks, utils
```

```
backend/app/
├── domains/
│   ├── auth/          # authentication & authorization
│   ├── user/          # user management
│   ├── post/          # posts CRUD
│   ├── comment/       # comments
│   ├── notification/  # notifications
│   ├── message/       # direct messages
│   └── shared/        # shared utilities, base classes
```

## Layer Rules

### Frontend Layers (top → bottom)

| Layer | Allowed Imports | Forbidden Imports |
|-------|----------------|-------------------|
| Pages/Routes | Components, Hooks, Services | Direct API calls |
| Components | Hooks, Utils, shared/ | Services, Repositories |
| Hooks | Services, Utils | Components |
| Services (API clients) | Utils | Components, Hooks |
| Utils | Nothing domain-specific | Everything above |

### Backend Layers (top → bottom)

| Layer | Allowed Imports | Forbidden Imports |
|-------|----------------|-------------------|
| Routes (API endpoints) | Services | Repositories, Models directly |
| Services (business logic) | Repositories, Models | Routes |
| Repositories (data access) | Models, DB session | Routes, Services |
| Models (SQLAlchemy) | Nothing | Everything above |

### Dependency Direction

```
ALLOWED:    Pages → Components → Hooks → Services → Utils
FORBIDDEN:  Utils → Services, Services → Components, Any circular

ALLOWED:    Routes → Services → Repositories → Models
FORBIDDEN:  Models → Repositories, Repositories → Routes, Any circular
```

## Cross-Cutting Concerns

These enter the system through defined paths only:

| Concern | Frontend Entry | Backend Entry |
|---------|---------------|---------------|
| Authentication | `domains/auth/hooks/useAuth` | `domains/auth/middleware.py` |
| Error handling | `domains/shared/ErrorBoundary` | `app/middleware/error_handler.py` |
| Logging | N/A | `app/core/logging.py` |
| Validation | Zod schemas per domain | Pydantic models per domain |
| Caching | React Query config | Redis via `app/core/cache.py` |

## Mandatory Constraints

1. **No cross-domain imports** — domains must not import from sibling domains; use shared/ or events
2. **No business logic in routes** — routes call services, services contain logic
3. **No raw SQL** — use SQLAlchemy ORM or repository methods
4. **No frontend direct DB access** — all data goes through API
5. **Shared types** — API request/response types defined once, used by both frontend and backend
6. **Immutability** — never mutate state; always create new objects
7. **Max file size** — 400 lines preferred, 800 lines hard limit
8. **Max function size** — 50 lines
9. **Max nesting depth** — 4 levels
10. **Environment variables** — no hardcoded secrets; all config via env vars
