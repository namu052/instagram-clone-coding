# DD-0001: Shared AI Agent Harness Design

- **Status**: Accepted
- **Author**: System Architect
- **Date**: 2026-04-14
- **Stack**: Next.js + FastAPI + PostgreSQL + GitHub Actions

---

# [1] 개요

## 목적

Claude Code와 Codex CLI가 하나의 리포지터리에서 동일한 품질 기준으로 작업할 수 있게 하는 **공용 하네스**를 설계한다.

## 핵심 원칙

**"하나의 코어, 두 개의 얇은 어댑터"**

```
정책·규칙·검증 → 공용 코어 (docs/, scripts/, ARCHITECTURE.md)
                    ↓
        ┌───────────┴───────────┐
        ▼                       ▼
   Codex 어댑터              Claude 어댑터
   (AGENTS.md,              (CLAUDE.md,
    .codex/config.toml)      .claude/skills/, hooks)
```

공용 코어에 정책을 두고, 어댑터는 각 도구의 런타임 특성에 맞는 **바인딩**만 담는다.

---

# [2] 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                             │
│                                                                      │
│  ┌──────────────────── 공용 코어 ────────────────────┐              │
│  │                                                    │              │
│  │  ARCHITECTURE.md          (구조 규칙)              │              │
│  │  docs/design-docs/        (설계 결정)              │              │
│  │  docs/product-specs/      (제품 요구사항)          │              │
│  │  docs/exec-plans/         (실행 계획)              │              │
│  │  docs/references/         (정책: 보안, 품질, SOP)  │              │
│  │  scripts/verify.sh        (통합 검증)              │              │
│  │  scripts/check-structure.sh (구조 검사)            │              │
│  │  .github/workflows/ci.yml (CI 파이프라인)          │              │
│  │  .github/PR_TEMPLATE.md   (PR 표준)                │              │
│  │                                                    │              │
│  └────────────────────────────────────────────────────┘              │
│           ▲                              ▲                           │
│           │ reads                         │ reads                    │
│  ┌────────┴──────────┐        ┌──────────┴────────────┐            │
│  │  Codex 어댑터      │        │  Claude 어댑터         │            │
│  │                    │        │                        │            │
│  │  AGENTS.md         │        │  CLAUDE.md             │            │
│  │  .codex/           │        │  .claude/skills/       │            │
│  │    config.toml     │        │  .claude/hooks/        │            │
│  │    config.cons..   │        │                        │            │
│  │    config.semi..   │        │                        │            │
│  └────────┬──────────┘        └──────────┬────────────┘            │
│           │                              │                           │
│           ▼                              ▼                           │
│  ┌────────────────────────────────────────────────────┐              │
│  │              CI / Quality Gates                     │              │
│  │                                                     │              │
│  │  lint → typecheck → test → build → structure-check  │              │
│  │                      ↓                              │              │
│  │               merge-gate                            │              │
│  └────────────────────────────────────────────────────┘              │
│                              ↓                                       │
│  ┌────────────────────────────────────────────────────┐              │
│  │           PR Review Loop                            │              │
│  │                                                     │              │
│  │  agent self-review → human review → fix → re-verify │              │
│  └────────────────────────────────────────────────────┘              │
│                              ↓                                       │
│  ┌────────────────────────────────────────────────────┐              │
│  │        Drift / Cleanup Control                      │              │
│  │                                                     │              │
│  │  weekly structure scan → tech debt scoring →         │              │
│  │  auto-cleanup PRs → staleness alerts                │              │
│  └────────────────────────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────────┘
```

## 각 요소의 역할

| 요소 | 역할 | 입력 | 출력 | 상호작용 |
|------|------|------|------|----------|
| **CI / Quality Gates** | 모든 PR에 대해 동일한 검증 실행 | PR diff, 코드 | pass/fail 결과 | merge-gate에 결과 전달 |
| **Codex 어댑터 (AGENTS.md)** | Codex CLI에 리포 규칙 전달 | 없음 (정적 파일) | Codex 행동 지침 | 공용 docs를 참조링크 |
| **.codex/config.toml** | Codex 런타임 설정: 승인모드, 샌드박스, 모델 | 없음 (정적 설정) | Codex 실행 제약 | AGENTS.md와 쌍으로 동작 |
| **Claude 어댑터 (CLAUDE.md)** | Claude Code에 리포 규칙 전달 | 없음 (정적 파일) | Claude 행동 지침 | 공용 docs를 참조링크 |
| **.claude/skills/** | Claude 전용 절차를 스킬로 캡슐화 | 작업 컨텍스트 | 구조화된 출력 | verify.sh, exec-plans 활용 |
| **hooks** | 편집/실행 시 자동 검증·차단 | 도구 호출 이벤트 | pass/block | PreToolUse, PostToolUse, Stop |
| **PR review loop** | 자기 리뷰 → 사람 리뷰 → 수정 반복 | PR diff | 승인/거절 | CI gates 연동 |
| **merge gate** | 모든 검증 통과 시만 병합 허용 | CI 결과 | merge 허용/차단 | GitHub branch protection |
| **cleanup / drift control** | 구조 편차, 문서 노후화, 기술부채 감시 | 코드베이스 상태 | cleanup PR, 경고 | tech-debt-tracker 갱신 |

---

# [3] 리포지터리 구조 설계

```
instagram-clone/
├── AGENTS.md                          # Codex CLI 진입점
├── CLAUDE.md                          # Claude Code 진입점
├── ARCHITECTURE.md                    # 구조 규칙 (source of truth)
│
├── docs/
│   ├── design-docs/
│   │   └── index.md                   # 설계 결정 색인
│   ├── product-specs/
│   │   └── index.md                   # 제품 요구사항 색인
│   ├── exec-plans/
│   │   ├── active/
│   │   │   └── _template.md           # 실행 계획 템플릿
│   │   ├── completed/
│   │   │   └── _template.md           # 완료 보고 템플릿
│   │   └── tech-debt-tracker.md       # 기술부채 추적
│   ├── references/
│   │   ├── golden-rules.md            # 불변 규칙
│   │   ├── QUALITY_SCORE.md           # 품질 점수 체계
│   │   ├── SECURITY.md                # 보안 정책
│   │   ├── RELIABILITY.md             # 안정성 정책
│   │   ├── commit-convention.md       # 커밋 규칙
│   │   ├── sop-shared-agent.md        # 공용 SOP
│   │   ├── sop-codex.md              # Codex SOP
│   │   ├── sop-claude.md             # Claude SOP
│   │   ├── sop-human-approval.md     # 승인 SOP
│   │   └── sop-worktree.md           # 워크트리 SOP
│   └── generated/                     # 자동생성 문서 (커버리지 등)
│
├── scripts/
│   ├── verify.sh                      # 통합 검증 파이프라인
│   ├── check-structure.sh             # 구조 규칙 검사
│   └── quality-score.sh               # 품질 점수 계산
│
├── tests/                             # 테스트 루트
├── tooling/                           # 개발 도구 설정
├── observability/                     # 관측 설정 (로그, 메트릭)
│
├── .codex/
│   ├── config.toml                    # 기본 설정
│   ├── config.conservative.toml       # 보수형 설정
│   └── config.semi-autonomous.toml    # 반자율형 설정
│
├── .claude/
│   ├── skills/
│   │   ├── explore-codebase/SKILL.md
│   │   ├── create-exec-plan/SKILL.md
│   │   ├── run-verification/SKILL.md
│   │   └── prepare-pr/SKILL.md
│   └── hooks/
│       └── hooks-design.md            # 훅 설계 명세
│
├── .github/
│   ├── workflows/ci.yml               # CI 파이프라인
│   └── PR_TEMPLATE.md                 # PR 템플릿
│
├── frontend/                          # Next.js 앱
└── backend/                           # FastAPI 앱
```

### 각 항목 상세

| 항목 | 목적 | SoT | 관리자 | 읽는 시점 | 신선도 규칙 | 정리 기준 |
|------|------|-----|--------|----------|------------|----------|
| `AGENTS.md` | Codex 진입점 | 아니오 (포인터) | 사람 | Codex 시작 시 | 공용 docs 변경 시 링크 확인 | 절대 비대화 금지: 30줄 이내 |
| `CLAUDE.md` | Claude 진입점 | 아니오 (포인터) | 사람 | Claude 시작 시 | 공용 docs 변경 시 링크 확인 | 절대 비대화 금지: 50줄 이내 |
| `ARCHITECTURE.md` | 구조 규칙 | **예** | 사람 (설계 리뷰 후) | 모든 작업 시작 전 | 설계 결정마다 갱신 | 현 구조와 불일치 시 즉시 갱신 |
| `docs/design-docs/` | 설계 결정 | **예** (개별 결정) | 사람 + 에이전트 제안 | 관련 영역 작업 시 | 90일 미갱신 → 리뷰 | Superseded → 90일 후 삭제 |
| `docs/product-specs/` | 제품 요구 | **예** | 사람 | 기능 구현 전 | Draft 30일 → 리뷰 | Completed → 180일 후 아카이브 |
| `docs/exec-plans/active/` | 진행 중 작업 | **예** (작업 상태) | 에이전트 + 사람 | 매 작업 시작 시 | 작업 중 실시간 갱신 | 완료 → completed/로 이동 |
| `docs/exec-plans/completed/` | 완료 기록 | 아니오 (이력) | 에이전트 | 유사 작업 참조 시 | 갱신 불요 | 180일 후 삭제 가능 |
| `docs/exec-plans/tech-debt-tracker.md` | 기술부채 | **예** | 에이전트 + 사람 | 영역 작업 전 | 주간 리뷰 | 해결 항목: 30일 후 제거 |
| `docs/references/` | 정책 문서 | **예** | 사람 | 정책 관련 판단 시 | 분기 리뷰 | 현행 정책과 불일치 시 갱신 |
| `docs/generated/` | 자동 생성 산출물 | 아니오 | 자동생성 (CI) | 품질 확인 시 | 매 CI 실행 시 갱신 | 최신 1개만 유지 |
| `scripts/` | 검증 스크립트 | **예** (검증 정의) | 사람 | 검증 실행 시 | 검증 기준 변경 시 갱신 | 사용하지 않는 스크립트 삭제 |
| `.codex/` | Codex 런타임 설정 | Codex 전용 SoT | 사람 | Codex 시작 시 | 정책 변경 시 갱신 | 사용 안 하는 프로필 삭제 |
| `.claude/skills/` | Claude 절차 캡슐화 | Claude 전용 SoT | 사람 | 스킬 호출 시 | 절차 변경 시 갱신 | 사용 안 하는 스킬 삭제 |
| `.claude/hooks/` | 자동 강제 규칙 | Claude 전용 SoT | 사람 | 도구 호출 시 (자동) | 규칙 변경 시 갱신 | 무효화된 훅 제거 |
| `.github/workflows/` | CI 파이프라인 | **예** (CI 정의) | 사람 | PR/push 시 (자동) | 검증 기준 변경 시 갱신 | — |

---

# [4] 공용 코어 설계 원칙

## 배치 구분

| 공용 코어에 둘 것 | Codex 전용 | Claude 전용 |
|-------------------|-----------|-------------|
| 아키텍처 규칙 | approval policy (suggest/auto-edit) | skills (절차 캡슐화) |
| 보안 정책 | sandbox 설정 | hooks (자동 강제) |
| 품질 점수 체계 | worktree 전략 | 인터랙티브 UI 검증 절차 |
| 검증 스크립트 | config profiles | context window 관리 |
| PR 템플릿 | blocked commands 목록 | dev server 실행 방식 |
| 커밋 규칙 | model 선택 | memory 시스템 활용 |
| SOP (공용 루프) | | |
| 기술부채 추적 | | |
| 실행 계획 체계 | | |

### 공용처럼 보이지만 분리해야 하는 것

| 항목 | 이유 | 해결 |
|------|------|------|
| "파일 수정 금지 목록" | Codex는 config.toml에서, Claude는 hooks에서 강제 | 공용 docs에 **목록**만 두고, 각 어댑터가 자기 방식으로 구현 |
| "위험 명령 차단" | 메커니즘이 다름 (sandbox vs hooks) | 공용 docs에 **목록**만 두고, 각 어댑터가 구현 |
| "자율성 수준" | 실행 모델이 다름 | 공용 SOP에 **수준 정의**, 각 어댑터가 매핑 |

### 중복 방지 방법

1. 정책은 `docs/references/`에 한 번만 작성
2. AGENTS.md와 CLAUDE.md는 해당 문서를 **참조링크**
3. 어댑터 파일은 "이 도구에서 어떻게 적용하나"만 기술
4. 정책 변경 시 공용 docs만 수정; 어댑터는 링크가 바뀌지 않으면 수정 불요
5. 주간 drift 검사: 어댑터 파일이 공용 docs와 모순되는지 확인

## 10대 설계 원칙

1. **Single Source of Truth** — 하나의 정보는 하나의 장소에만 존재
2. **Pointer, Not Copy** — 어댑터는 정책을 복사하지 않고 참조
3. **Same Gate, Different Path** — 도구가 달라도 최종 검증은 동일
4. **Enforce, Don't Ask** — 가능하면 CI/hook으로 강제; 문서로만 "부탁"하지 않음
5. **Minimal Adapter** — 어댑터에는 런타임 바인딩만; 정책은 공용으로
6. **Readable by Machines** — 규칙은 파싱 가능한 형태로 작성
7. **Staleness Is a Bug** — 오래된 문서는 잘못된 문서; 신선도 관리 필수
8. **Plan Before Code** — 비자명한 작업은 exec-plan 우선
9. **Small Changes** — PR 300줄 이하; 큰 변경은 분할
10. **Escalate, Don't Guess** — 불확실하면 사람에게 에스컬레이션

## Source of Truth 계층

```
1. 코드 자체         (최고 권위: 코드가 진실)
2. ARCHITECTURE.md   (구조 규칙)
3. docs/references/  (정책)
4. docs/design-docs/ (설계 결정)
5. docs/exec-plans/  (작업 상태)
6. AGENTS.md / CLAUDE.md (포인터, 최하위)
```

## 변경 책임 분배

| 변경 대상 | 제안 가능 | 승인 필수 | 자동 적용 가능 |
|----------|----------|----------|--------------|
| 공용 정책 (docs/references/) | 에이전트 | 사람 | 아니오 |
| 아키텍처 규칙 | 에이전트 | 사람 | 아니오 |
| 실행 계획 | 에이전트 | 사람 (검토) | 예 (생성만) |
| 기술부채 항목 | 에이전트 | 아니오 | 예 |
| CI 파이프라인 | 에이전트 | 사람 | 아니오 |
| 어댑터 설정 | 사람 | 사람 | 아니오 |
| 스크립트 | 에이전트 | 사람 | 아니오 |
| 소스 코드 | 에이전트 | PR 리뷰 | 아니오 |
| 테스트 코드 | 에이전트 | PR 리뷰 | 아니오 |

---

# [5] AGENTS.md와 CLAUDE.md 역할 분리

## 역할 비교

| 측면 | AGENTS.md | CLAUDE.md |
|------|-----------|-----------|
| **대상** | Codex CLI | Claude Code |
| **핵심 역할** | 런타임 제약 전달 | 빌드 명령 + 스킬/훅 안내 |
| **공통 내용** | 읽기 순서, 프로젝트 설명, 공용 docs 링크 | 동일 |
| **고유 내용** | sandbox, approval policy, worktree 규칙 | 빌드/테스트 명령, skills, hooks |
| **절대 넣지 말 것** | 전체 보안 정책, 아키텍처 규칙, PR 템플릿 | 동일 |
| **크기 제한** | 30줄 (링크 제외) | 50줄 (명령어 포함) |

## 동기화 원칙

1. 공용 내용 변경 → `docs/references/` 수정 → 두 파일의 링크는 자동 유효
2. 프로젝트 설명 변경 → 두 파일 동시 수정 (검색: "## Project")
3. 주간 drift 검사: 두 파일이 참조하는 docs가 실제 존재하는지 확인
4. 두 파일 모두 PR 리뷰 대상 — 비대화 시 리뷰어가 차단

> 초안은 이미 생성된 `AGENTS.md`와 `CLAUDE.md` 파일 참조.

---

# [6] 공용 docs/ 기록 시스템

## 하위 디렉터리 역할

| 디렉터리 | 역할 | SoT | 읽기 우선순위 |
|----------|------|-----|-------------|
| `design-docs/` | "왜 이렇게 만들었나" — 아키텍처/기술 결정 기록 | 예 (개별 결정) | 관련 영역 작업 시 |
| `product-specs/` | "무엇을 만드나" — 요구사항, 수용 기준 | 예 | 기능 구현 전 |
| `exec-plans/active/` | "지금 무엇을 하고 있나" — 진행 중 작업 | 예 (상태) | **매 작업 시작 시 (최우선)** |
| `exec-plans/completed/` | "무엇을 했나" — 완료 기록 | 아니오 (이력) | 유사 작업 참조 시 |
| `references/` | "어떤 규칙을 따르나" — 정책, SOP, 점수 체계 | 예 | 판단이 필요할 때 |
| `generated/` | CI가 자동 생성한 리포트 | 아니오 | 품질 확인 시 |

## 에이전트 문서 읽기 우선순위

```
1. docs/exec-plans/active/   (현재 진행 중인 작업)
2. ARCHITECTURE.md            (구조 제약)
3. docs/references/           (정책)
4. docs/design-docs/          (설계 결정)
5. docs/product-specs/        (요구사항)
6. docs/exec-plans/completed/ (이력 참조)
```

## 오래된 문서 정리 규칙

| 문서 유형 | 비활성 기간 | 조치 |
|----------|-----------|------|
| design-docs (Draft) | 90일 | 리뷰 → 승인 또는 삭제 |
| design-docs (Superseded) | 90일 | 삭제 |
| product-specs (Draft) | 30일 | 리뷰 → 승인 또는 삭제 |
| product-specs (Completed) | 180일 | 아카이브 |
| exec-plans/active | 14일 무활동 | 에스컬레이션 |
| exec-plans/completed | 180일 | 삭제 가능 |
| tech-debt (Resolved) | 30일 | 제거 |

> 템플릿은 이미 생성된 `docs/` 하위 파일들 참조.

---

# [7] 공용 실행 루프

## 표준 작업 루프

```
┌─────────┐
│ 1.Orient │ ← exec-plans, tech-debt, ARCHITECTURE.md 읽기
└────┬─────┘
     ▼
┌──────────┐
│ 2.Plan   │ ← exec-plan 작성 (3+ 파일 변경 시)
└────┬─────┘
     ▼
┌────────────┐
│ 3.Reproduce│ ← 버그 재현 또는 요구사항 재진술
└────┬───────┘
     ▼
┌──────────┐
│ 4.Code   │ ← 도메인 경계 준수, 테스트 동시 작성
└────┬─────┘
     ▼
┌──────────┐
│ 5.Verify │ ← scripts/verify.sh
└────┬─────┘
     ▼
┌──────────────┐
│ 6.UI Check   │ ← 프론트엔드: 브라우저 확인
└────┬─────────┘
     ▼
┌──────────────┐
│ 7.Observe    │ ← 로그/메트릭/트레이스 확인
└────┬─────────┘
     ▼
┌──────────────┐
│ 8.Self-Review│ ← 아키텍처 규칙, 보안, PR 크기 점검
└────┬─────────┘
     ▼
┌────────────┐
│ 9.PR Prep  │ ← PR 생성, 품질 점수 계산
└────┬───────┘
     ▼
┌──────────────┐
│10.Review Fix │ ← 리뷰 코멘트 반영 → 5로 돌아감
└────┬─────────┘
     ▼
┌───────────────────┐
│11.Merge/Escalate  │ ← 병합 또는 사람에게 에스컬레이션
└───────────────────┘
```

## 도구별 실행 포인트

| 단계 | 공용 | Codex 특이사항 | Claude 특이사항 | 사람 개입 |
|------|------|--------------|----------------|----------|
| 1. Orient | exec-plans 읽기 | 자동 (AGENTS.md) | 자동 (CLAUDE.md) + skills | — |
| 2. Plan | exec-plan 작성 | 파일 생성 제안 | create-exec-plan 스킬 | 계획 승인 |
| 3. Reproduce | 테스트/실행 | sandbox 내 실행 | 인터랙티브 실행 가능 | — |
| 4. Code | 파일 수정 | suggest mode: 사람 승인 | 직접 수정 (hooks 감시) | Level 1: 매 수정 승인 |
| 5. Verify | verify.sh | sandbox 내 실행 | run-verification 스킬 | — |
| 6. UI Check | — | 불가 (sandbox) | 브라우저 실행 + 스크린샷 | Codex: 사람이 확인 |
| 7. Observe | 로그 확인 | 제한적 | 실시간 확인 가능 | — |
| 8. Self-Review | diff 검토 | 제안에 포함 | prepare-pr 스킬 | — |
| 9. PR Prep | PR 생성 | 사람 승인 필요 | prepare-pr 스킬 | 최종 확인 |
| 10. Review Fix | 수정 반영 | 새 제안 | 직접 수정 | 리뷰 제공 |
| 11. Merge | — | — | — | **반드시 사람** |

## 자율성 수준

### Level 1: Supervised (기본)

| 항목 | 규칙 |
|------|------|
| 허용 | 파일 읽기, 코드 탐색, 테스트/lint 실행, exec-plan 작성 |
| 필수 검증 | 매 행동 전 사람 확인 |
| 금지 | 파일 수정, git push, 의존성 변경, 설정 변경 |
| 승인 | 모든 쓰기 작업에 사람 승인 필요 |
| Codex | `mode = "suggest"` |
| Claude | 모든 Edit/Write에 사용자 확인 |

### Level 2: Semi-Autonomous

| 항목 | 규칙 |
|------|------|
| 허용 | src/, tests/ 파일 수정, verify 실행, 브랜치 생성 |
| 필수 검증 | verify.sh 통과, 구조 검사 통과 |
| 금지 | git push --force, .env 수정, 아키텍처 변경, 의존성 추가 |
| 승인 | PR 생성, 의존성 변경, 설정 변경에 사람 승인 |
| Codex | `mode = "auto-edit"` |
| Claude | 소스 파일 자동 수정 허용, 보호 파일은 hooks가 차단 |

### Level 3: Autonomous

| 항목 | 규칙 |
|------|------|
| 허용 | Level 2 전체 + PR 생성, 품질 점수 8+ 시 자동 병합 요청 |
| 필수 검증 | verify.sh + 구조 검사 + 품질 점수 계산 |
| 금지 | git push --force, .env 수정, CI 파이프라인 변경 |
| 승인 | 아키텍처 변경, 새 의존성, 프로덕션 배포에만 사람 승인 |
| Codex | `mode = "full-auto"` (제한된 환경에서만) |
| Claude | 대부분 자동, 보호 파일만 hooks가 차단 |

---

# [8] 공용 검증 체계

## 검증 명령 체계

```bash
scripts/verify.sh              # 전체 파이프라인 (CI와 동일)
scripts/check-structure.sh     # 구조 규칙만
scripts/quality-score.sh       # 품질 점수 계산

# 개별 실행
cd frontend && npm run lint    # 프론트엔드 lint
cd frontend && npx tsc --noEmit # 프론트엔드 타입 체크
cd frontend && npm run test    # 프론트엔드 테스트
cd frontend && npm run build   # 프론트엔드 빌드
cd backend && ruff check .     # 백엔드 lint
cd backend && pytest           # 백엔드 테스트
```

## CI 단계 설계

```
PR 생성/업데이트
    │
    ├─┬─ lint (frontend)         ─┐
    │ └─ lint (backend)           │
    ├── typecheck (frontend)      ├─ 병렬 실행
    ├─┬─ test (frontend)         │
    │ └─ test (backend)           │
    ├── structure-check          ─┘
    │
    └── build (frontend)          ← 위 모두 통과 후
         │
         └── merge-gate           ← 모두 통과 시만 병합 허용
```

## 실패 시 자동 대응

| 실패 유형 | 자동 대응 | 사람 필요 |
|----------|----------|----------|
| Lint 오류 | 에이전트가 자동 수정 (prettier/ruff format) | 아니오 |
| 미사용 import | 에이전트가 자동 제거 | 아니오 |
| 타입 오류 | 에이전트가 분석 후 수정 시도 | 복잡한 경우 예 |
| 테스트 실패 | 에이전트가 원인 분석 | 로직 오류 시 예 |
| 빌드 실패 | 에이전트가 원인 분석 | 대부분 예 |
| 구조 위반 | 에이전트 중단, 사람에게 보고 | 예 |

## 도구별 실행 차이 최소화

1. 두 도구 모두 `scripts/verify.sh`를 동일하게 실행
2. CI도 같은 스크립트 사용 → 로컬과 CI 결과 일치
3. 어댑터별 추가 검증은 허용하되, 공용 검증을 대체하면 안 됨

---

# [9] 아키텍처 제약과 구조 검사

## 아키텍처 규칙 목록

| ID | 규칙 | 강제 방법 |
|----|------|----------|
| A1 | 도메인 간 직접 import 금지 | check-structure.sh + CI |
| A2 | 의존성 방향 단방향 (위→아래만) | check-structure.sh |
| A3 | 컴포넌트에서 직접 API 호출 금지 | check-structure.sh |
| A4 | 라우트에서 직접 리포지토리 접근 금지 | 코드 리뷰 |
| A5 | 모델에서 상위 레이어 import 금지 | check-structure.sh |
| A6 | raw SQL 금지 (ORM만 사용) | grep 검사 |
| A7 | 파일 800줄 초과 금지 | check-structure.sh |
| A8 | 하드코딩된 시크릿 금지 | check-structure.sh |
| A9 | `dangerouslySetInnerHTML` 사용 시 DOMPurify 필수 | 코드 리뷰 |
| A10 | 환경별 설정은 env 변수만 사용 | check-structure.sh |

## CI 실패 조건

```yaml
# 이 중 하나라도 실패하면 PR 병합 불가
- lint errors > 0
- type errors > 0
- test failures > 0
- test coverage < 80%
- build failure
- structure check failure (cross-domain import, large files, secrets)
```

## 구조 위반 사례와 수정

### 사례 1: Cross-Domain Import
```typescript
// ✗ 위반: post 도메인에서 comment 도메인 직접 import
import { CommentList } from '@/domains/comment/components/CommentList'

// ✓ 수정: shared로 이동하거나 props로 전달
import { CommentList } from '@/domains/shared/components/CommentList'
```

### 사례 2: 컴포넌트에서 직접 fetch
```typescript
// ✗ 위반
function PostCard() {
  const data = await fetch('/api/posts')
}

// ✓ 수정: hook을 통해 접근
function PostCard() {
  const { data } = usePost(postId)
}
```

### 사례 3: 라우트에서 직접 DB 접근
```python
# ✗ 위반
@router.get("/users/{id}")
async def get_user(id: int, db: Session):
    return db.query(User).filter(User.id == id).first()

# ✓ 수정: 서비스 레이어 사용
@router.get("/users/{id}")
async def get_user(id: int, service: UserService = Depends()):
    return await service.get_user(id)
```

### 사례 4: 순환 의존성
```python
# ✗ 위반: user_service imports post_service, post_service imports user_service

# ✓ 수정: 이벤트나 shared 인터페이스 사용
```

### 사례 5: 800줄 초과 파일
```
# ✗ 위반: frontend/src/domains/feed/components/Feed.tsx (1200줄)

# ✓ 수정: 기능 단위로 분리
# Feed.tsx (200줄) — 메인 컴포넌트
# FeedList.tsx (150줄) — 목록 렌더링
# FeedItem.tsx (200줄) — 개별 항목
# useFeed.ts (100줄) — 데이터 로직
```

---

# [10] Codex CLI 어댑터 설계

## AGENTS.md와의 관계

AGENTS.md는 Codex가 시작 시 자동으로 읽는 파일이다. 여기에는:
- 공용 docs 읽기 순서
- Codex 전용 제약 (sandbox, approval, worktree)
- 공용 정책 참조 링크

정책 자체는 넣지 않는다.

## .codex/config.toml 역할

| 설정 | 역할 |
|------|------|
| `[approval].mode` | suggest / auto-edit / full-auto |
| `[sandbox].enabled` | 파일시스템·네트워크 격리 |
| `[sandbox].writable_paths` | 쓰기 허용 경로 |
| `[sandbox].network` | 네트워크 접근 허용 여부 |
| `[commands]` | 자주 쓰는 명령 바로가기 |
| `[guardrails]` | 변경 규모 제한, 차단 명령 목록 |

## 프로필별 차이

| 설정 | 기본 | 보수형 | 반자율형 |
|------|------|--------|---------|
| approval mode | suggest | suggest (reads도 승인) | auto-edit |
| writable paths | src, tests, scripts, docs | src, tests만 | src, tests, scripts, docs |
| max file changes | — | 5 | 15 |
| max lines changed | — | 200 | 500 |
| require test | — | 예 | 예 |

> 설정 파일 초안은 `.codex/config.toml`, `.codex/config.conservative.toml`, `.codex/config.semi-autonomous.toml` 참조.

---

# [11] Claude Code 어댑터 설계

## CLAUDE.md와의 관계

CLAUDE.md는 Claude Code가 시작 시 자동으로 읽는 파일이다. 여기에는:
- 빌드/테스트/dev 명령어
- skills 목록과 용도
- hooks 개요
- 공용 정책 참조 링크

## Skills vs Hooks 구분

| | Skills | Hooks |
|---|--------|-------|
| **목적** | 절차 캡슐화 (how-to) | 규칙 강제 (must/must-not) |
| **실행** | 명시적 호출 | 자동 (이벤트 트리거) |
| **예시** | "실행 계획 작성법" | "보호 파일 수정 차단" |
| **실패 시** | 절차 안내 | 동작 차단 |

### Skills로 빼야 할 것
- 코드베이스 탐색 절차
- 실행 계획 작성 절차
- 검증 파이프라인 실행 절차
- PR 준비 절차

### Hooks로 강제할 것
- 보호 파일 쓰기 차단 (.env, AGENTS.md, .codex/, .github/workflows/)
- 위험 명령 경고 (rm -rf, git push --force)
- 편집 후 자동 포맷
- TS 편집 후 타입 체크
- 세션 종료 시 검증 리마인더

> 스킬 파일은 `.claude/skills/*/SKILL.md`, 훅 설계는 `.claude/hooks/hooks-design.md` 참조.

---

# [12] 관측 가능성 및 UI 검증

## Observability Architecture

```
┌─────────────────────────────────────────┐
│              Application                 │
│  Frontend (Next.js) │ Backend (FastAPI)  │
└─────────┬───────────┴───────┬───────────┘
          │                   │
    ┌─────▼─────┐      ┌─────▼──────┐
    │ Browser   │      │ Structured │
    │ Console   │      │ Logging    │
    │ DevTools  │      │ (JSON)     │
    └─────┬─────┘      └─────┬──────┘
          │                   │
    ┌─────▼─────────────┬─────▼──────┐
    │  Observability Layer            │
    │                                 │
    │  Logs → stdout/file             │
    │  Metrics → /metrics endpoint    │
    │  Traces → request-id tracking   │
    └─────────────────────────────────┘
```

## 에이전트 관측 질의 예시

```bash
# 최근 에러 로그
tail -100 backend/logs/app.log | grep ERROR

# API 응답 시간
curl -s http://localhost:8000/metrics | grep response_time

# 특정 요청 추적
grep "request-id: abc123" backend/logs/app.log
```

## UI 회귀 검증 시나리오 (10개)

| # | 시나리오 | 검증 방법 |
|---|---------|----------|
| 1 | 로그인 폼 렌더링 및 제출 | Playwright: 폼 입력 → 제출 → 리다이렉트 확인 |
| 2 | 피드 무한 스크롤 | Playwright: 스크롤 → 새 포스트 로드 확인 |
| 3 | 이미지 업로드 및 미리보기 | Playwright: 파일 선택 → 미리보기 표시 확인 |
| 4 | 좋아요 토글 | Playwright: 클릭 → 카운트 변경 → 재클릭 → 원복 확인 |
| 5 | 댓글 작성 및 표시 | Playwright: 입력 → 제출 → 목록에 표시 확인 |
| 6 | 프로필 편집 | Playwright: 수정 → 저장 → 반영 확인 |
| 7 | 알림 배지 업데이트 | Playwright: 이벤트 발생 → 배지 숫자 변경 확인 |
| 8 | 반응형 레이아웃 (모바일) | Playwright: viewport 변경 → 레이아웃 확인 |
| 9 | 다크모드 전환 | Playwright: 토글 → CSS 변수 변경 확인 |
| 10 | 에러 상태 표시 | Playwright: API 실패 시뮬레이션 → 에러 메시지 확인 |

## 임시 환경 운영 절차

```
1. 생성: git worktree add → npm install → db:migrate → seed
2. 실행: frontend dev server + backend dev server
3. 검증: Playwright 테스트 + 수동 확인
4. 정리: 서버 종료 → worktree 제거 → 임시 DB 삭제
```

---

# [13] PR, 리뷰, 병합 체계

## 원칙

| 원칙 | 규칙 |
|------|------|
| 작은 PR 우선 | 300줄 이하. 500줄 초과는 반드시 분할 |
| 자기 리뷰 | PR 생성 전 에이전트가 자체 체크리스트 완료 |
| 에이전트 리뷰어 | 다른 에이전트에게 독립 리뷰 요청 가능 (code-reviewer) |
| 사람 리뷰 필수 | 아키텍처 변경, 보안 관련, 새 의존성, 데이터 스키마 변경 |
| 병합 게이트 | CI 전체 통과 + 사람 승인 (최소 1명) |

## "검토 가능한 변경"의 정의

- 변경 300줄 이하
- 하나의 논리적 목적
- 자체 포함 (이 PR만 봐도 이해 가능)
- 테스트 포함
- 의존하는 PR이 이미 병합됨

## 실패한 빌드 자동 복구 루프

```
CI 실패 → 에이전트에게 실패 로그 전달
       → 에이전트가 자동 수정 가능한 오류 식별
       → lint/format 오류: 자동 수정 → 재커밋 → 재실행
       → 그 외: 사람에게 에스컬레이션
       → 최대 2회 자동 수정 시도 후 중단
```

## PR 생성 프롬프트 템플릿

```
다음 변경사항에 대해 PR을 준비하세요:

1. scripts/verify.sh를 실행하고 모든 검증이 통과하는지 확인
2. 변경된 모든 파일을 ARCHITECTURE.md 규칙과 대조 검토
3. .github/PR_TEMPLATE.md 양식으로 PR 설명 작성
4. 품질 점수 계산 (docs/references/QUALITY_SCORE.md 기준)
5. 점수 6 미만이면 개선 후 재시도
6. 최종 요약을 사용자에게 제시
```

## 리뷰 프롬프트 템플릿

```
PR #{number}를 리뷰하세요:

1. ARCHITECTURE.md 제약 위반 확인
2. 보안 정책 (docs/references/SECURITY.md) 준수 확인
3. 테스트 커버리지 80% 이상 확인
4. 파일 크기 규칙 준수 확인
5. 불필요한 변경 포함 여부 확인
6. 코멘트를 구체적으로 작성 (파일:줄번호 포함)
```

## 수정 반영 프롬프트 템플릿

```
PR #{number}의 리뷰 코멘트를 반영하세요:

1. 모든 코멘트를 읽고 이해
2. 각 코멘트에 대해 수정 또는 반론 준비
3. 수정 적용
4. scripts/verify.sh 재실행
5. 수정 내역 요약
```

## 병합 승인 체크리스트

- [ ] CI 파이프라인 전체 통과
- [ ] 사람 리뷰어 1명 이상 승인
- [ ] 품질 점수 6 이상
- [ ] 충돌 해결 완료
- [ ] exec-plan 상태 업데이트 완료
- [ ] 보안 민감 변경 시: 보안 리뷰어 승인

---

# [14] 드리프트, 엔트로피, 정리 자동화

## Golden Rules

> `docs/references/golden-rules.md` 참조 — 이미 생성됨.

## 정기 점검 Job 설계

| 주기 | 점검 항목 | 실행 방법 |
|------|----------|----------|
| 매 PR | 구조 검사, lint, typecheck, 테스트 | CI (자동) |
| 일간 | 활성 exec-plan 상태 확인 | 스케줄 잡 or 수동 |
| 주간 | tech-debt-tracker 리뷰 | 팀 회의 |
| 주간 | AGENTS.md/CLAUDE.md 링크 유효성 | 스크립트 검사 |
| 월간 | 문서 신선도 감사 | 날짜 기반 스캔 |
| 분기 | 정책 문서 전체 리뷰 | 사람 |

## Drift 감지 규칙

| 감지 대상 | 감지 방법 | 조치 |
|----------|----------|------|
| AGENTS.md/CLAUDE.md가 참조하는 문서 부재 | 링크 유효성 검사 스크립트 | 즉시 수정 |
| ARCHITECTURE.md와 실제 코드 불일치 | check-structure.sh | 코드 수정 또는 규칙 갱신 |
| 오래된 exec-plan (14일+ 미활동) | 날짜 스캔 | 에스컬레이션 |
| 중복 유틸리티 함수 | 코드 유사도 검사 | cleanup PR |
| 미사용 의존성 | depcheck / pip-audit | cleanup PR |

## Cleanup PR 분류

| 유형 | 자동 병합 가능 | 예시 |
|------|--------------|------|
| 포맷팅 수정 | 예 (CI 통과 시) | prettier/ruff format |
| 미사용 import 제거 | 예 (CI 통과 시) | ESLint --fix |
| 문서 날짜 갱신 | 예 | last-updated 필드 |
| 미사용 코드 제거 | 아니오 (리뷰 필요) | dead code 삭제 |
| 의존성 업데이트 | 아니오 (리뷰 필요) | npm update |
| 구조 리팩토링 | 아니오 (리뷰 필요) | 파일 분할 |

## 기술부채 수치화

`docs/exec-plans/tech-debt-tracker.md`의 점수 합계:
- 0–10: 건강 → 유지
- 11–25: 주의 → 다음 스프린트 20% 할당
- 26–50: 경고 → 기능 중단, 부채 해결
- 51+: 위기 → 전면 부채 스프린트

---

# [15] 운영 정책

## 15.1 보안

| 항목 | 내용 |
|------|------|
| 정책명 | 코드 보안 |
| 필요성 | 사용자 데이터 보호, 규정 준수 |
| 규칙 | `docs/references/SECURITY.md` 전체 |
| 자동화 | check-structure.sh 시크릿 패턴 탐지, CI 실행 |
| 위반 시 | Critical: 즉시 revert. High: 병합 차단 |
| Codex | sandbox로 네트워크 차단, .env 쓰기 불가 |
| Claude | hooks로 .env, credentials 파일 쓰기 차단 |

## 15.2 비밀정보 처리

| 항목 | 내용 |
|------|------|
| 정책명 | 시크릿 관리 |
| 필요성 | 자격증명 유출 방지 |
| 규칙 | 환경변수만 사용, .env는 .gitignore, 하드코딩 금지 |
| 자동화 | git pre-commit hook + CI 시크릿 스캔 |
| 위반 시 | 즉시 revert + 키 로테이션 |
| Codex | .env 파일 쓰기 권한 없음 |
| Claude | PreToolUse 훅으로 .env 쓰기 차단 |

## 15.3 프로덕션 변경 권한

| 항목 | 내용 |
|------|------|
| 정책명 | 프로덕션 접근 통제 |
| 필요성 | 서비스 안정성, 데이터 무결성 |
| 규칙 | 에이전트는 프로덕션 직접 접근 불가. 모든 변경은 PR → 리뷰 → CI → 배포 파이프라인 |
| 자동화 | CI/CD 파이프라인으로만 배포 |
| 위반 시 | 즉시 롤백 + 사후 분석 |
| Codex | sandbox로 프로덕션 접근 불가 |
| Claude | 프로덕션 URL/호스트 접근 hooks로 차단 |

## 15.4 데이터 접근 통제

| 항목 | 내용 |
|------|------|
| 정책명 | 최소 권한 원칙 |
| 필요성 | 데이터 보호 |
| 규칙 | 에이전트는 로컬 개발 DB만 접근. 프로덕션 DB 직접 접근 금지 |
| 자동화 | 개발 환경 자동 설정 스크립트 |
| 위반 시 | 접근 즉시 차단, 감사 로그 검토 |

## 15.5 위험 명령 실행 제한

| 항목 | 내용 |
|------|------|
| 정책명 | 위험 명령 통제 |
| 필요성 | 비가역적 행동 방지 |
| 규칙 | `rm -rf`, `git push --force`, `git reset --hard`, `DROP TABLE`, `chmod 777` 절대 금지 |
| 자동화 | Codex: config.toml blocked_commands. Claude: PreToolUse 훅 |
| 위반 시 | 명령 차단 (자동) |

## 15.6 롤백 정책

| 항목 | 내용 |
|------|------|
| 정책명 | 변경 롤백 |
| 필요성 | 장애 신속 복구 |
| 규칙 | 모든 배포는 이전 버전으로 롤백 가능해야 함. DB 마이그레이션은 가역적 |
| 자동화 | CI/CD 파이프라인에 롤백 단계 포함 |
| 위반 시 | 가역성 없는 변경은 병합 차단 |

## 15.7 장애 시 에스컬레이션

| 항목 | 내용 |
|------|------|
| 정책명 | 에스컬레이션 체계 |
| 필요성 | 장애 시 신속 대응 |
| 규칙 | 에이전트가 해결 불가한 문제 → 즉시 사람에게 보고. 추측으로 진행 금지 |
| 자동화 | CI 실패 알림 자동 발송 |
| 위반 시 | — |

## 15.8 문서 신선도 관리

| 항목 | 내용 |
|------|------|
| 정책명 | 문서 신선도 |
| 필요성 | 오래된 문서 = 잘못된 문서 |
| 규칙 | 섹션 [6] 정리 규칙 적용 |
| 자동화 | 월간 날짜 스캔 스크립트 |
| 위반 시 | 스태일 문서 리뷰 요청 발송 |

## 15.9 감사 로그

| 항목 | 내용 |
|------|------|
| 정책명 | 감사 추적성 |
| 필요성 | 규정 준수, 사후 분석 (공공기관 필수) |
| 규칙 | 모든 상태 변경 로깅: 행위자, 시각, 대상, 결과 |
| 자동화 | 백엔드 미들웨어 자동 로깅 |
| 위반 시 | 감사 로그 누락 = 병합 차단 |
| 공공기관 추가 | 최소 3년 보관, 변경 불가 저장소 |

## 15.10 인간 승인 게이트

| 항목 | 내용 |
|------|------|
| 정책명 | 인간 승인 필수 게이트 |
| 필요성 | 고위험 변경의 안전망 |
| 규칙 | `docs/references/sop-human-approval.md` 참조 |
| 자동화 | GitHub branch protection rules |
| 위반 시 | 병합 불가 (자동 강제) |

---

# [16] 12주 구축 로드맵

## 1~2주: 최소 기반

| 항목 | 내용 |
|------|------|
| 목표 | 프로젝트 스캐폴딩 + 공용 코어 기본 파일 배치 |
| 산출물 | AGENTS.md, CLAUDE.md, ARCHITECTURE.md, docs/ 구조, scripts/verify.sh, .codex/config.toml, .claude/skills/, CI 기본 |
| 완료 기준 | `scripts/verify.sh` 실행 가능, CI 파이프라인 동작, 양 도구로 코드 생성 가능 |
| 위험 | 스택 선택 변경, 초기 구조 불안정 |
| 다음 의존 | 실제 도메인 코드 없이는 구조 검사 무의미 |
| Codex | config.toml 설정, suggest 모드 확인 |
| Claude | CLAUDE.md 빌드 명령 확인, skills 동작 확인 |
| 공용 | ARCHITECTURE.md 초안, golden-rules 확정 |

## 3~4주: 공용 문서와 제약 정착

| 항목 | 내용 |
|------|------|
| 목표 | 첫 도메인 (auth) 구현 + 공용 문서 체계 검증 |
| 산출물 | auth 도메인 (프론트+백), 첫 design-doc, 첫 exec-plan, tech-debt-tracker 운영 시작 |
| 완료 기준 | auth 로그인/회원가입 동작, verify.sh 통과, 구조 검사 통과, 80% 커버리지 |
| 위험 | exec-plan 체계 과중, 문서 업데이트 누락 |
| 다음 의존 | auth 완성이 다른 도메인의 선행 조건 |
| Codex | auth 일부 기능을 Codex로 구현 시도 |
| Claude | auth 주요 기능 Claude로 구현, 스킬 활용 |
| 공용 | design-doc, exec-plan 워크플로우 검증 |

## 5~6주: 핵심 도메인 확장

| 항목 | 내용 |
|------|------|
| 목표 | post, feed, profile 도메인 구현 |
| 산출물 | 3개 도메인 코드, 통합 테스트, E2E 테스트 시작 |
| 완료 기준 | 피드 렌더링, 포스트 CRUD, 프로필 조회 동작 |
| 위험 | 도메인 간 의존성 발생, 구조 위반 유혹 |
| 다음 의존 | 이 도메인들이 comment, notification의 기반 |
| Codex | 반복적 CRUD를 Codex에 위임 |
| Claude | UI 구현 + 브라우저 검증 |
| 공용 | check-structure.sh가 실제 위반 탐지 확인 |

## 7~8주: 검증 및 관측 가능성 강화

| 항목 | 내용 |
|------|------|
| 목표 | 관측 가능성 구축 + UI 회귀 테스트 + 품질 점수 체계 운영 |
| 산출물 | Playwright E2E 10개 시나리오, 로깅 미들웨어, quality-score.sh 운영, comment/notification 도메인 |
| 완료 기준 | E2E 테스트 CI 통합, 품질 점수 자동 계산, 로그 구조화 |
| 위험 | E2E 테스트 불안정성 (flaky tests) |
| 다음 의존 | 관측 가능성이 자율성 상향의 전제 |
| Codex | 테스트 코드 생성 위임 |
| Claude | Playwright 테스트 작성 + 실행 검증 |
| 공용 | CI에 E2E 단계 추가, 품질 점수 리포트 생성 |

## 9~10주: 자율성 상향

| 항목 | 내용 |
|------|------|
| 목표 | Level 2 자율성으로 상향 + message 도메인 + 실시간 기능 |
| 산출물 | DM 기능, WebSocket 통합, semi-autonomous config 실전 적용 |
| 완료 기준 | 에이전트가 semi-auto로 기능 구현 → PR → 리뷰 사이클 완주 |
| 위험 | 자율성 상향 후 품질 저하 |
| 다음 의존 | 안정적 자율성이 정리 자동화의 전제 |
| Codex | config.semi-autonomous.toml 적용 |
| Claude | hooks 기반 가드레일 확인 |
| 공용 | 자율성 수준별 품질 비교 메트릭 |

## 11~12주: 정리 자동화 및 안정화

| 항목 | 내용 |
|------|------|
| 목표 | drift 감지 자동화, cleanup PR 체계, 최종 안정화 |
| 산출물 | drift 감지 스크립트, 자동 cleanup PR, 문서 신선도 검사, 전체 기능 통합 테스트 |
| 완료 기준 | 주간 drift 검사 자동 실행, tech-debt 점수 10 이하, 전체 E2E 통과 |
| 위험 | 자동화 과잉으로 noise 증가 |
| 다음 의존 | — (운영 안정화 단계) |
| Codex | drift 감지 대상으로 포함 |
| Claude | cleanup PR 생성 자동화 |
| 공용 | 정기 점검 job 전체 운영, 운영 SOP 최종판 |

---

# [17] 실패 패턴과 대응책

## 1. AGENTS.md / CLAUDE.md 중복 비대화

| 항목 | 내용 |
|------|------|
| 징후 | 두 파일이 100줄 이상, 동일 정책 중복 |
| 원인 | "여기에도 넣어두자" 심리, 공용 docs 참조 누락 |
| 조기 탐지 | 파일 크기 모니터링 (AGENTS.md > 30줄, CLAUDE.md > 50줄 경고) |
| 교정 | 중복 내용을 docs/references/로 추출, 링크로 대체 |

## 2. 문서 드리프트

| 항목 | 내용 |
|------|------|
| 징후 | 문서가 코드와 불일치, 잘못된 경로 참조 |
| 원인 | 코드 변경 시 문서 미갱신 |
| 조기 탐지 | 월간 링크 유효성 검사, 구조 검사 vs ARCHITECTURE.md 비교 |
| 교정 | 문서 갱신을 PR 체크리스트에 포함, drift 감지 스크립트 |

## 3. Source of Truth 혼란

| 항목 | 내용 |
|------|------|
| 징후 | 같은 정보가 3곳 이상에 존재, 상충하는 내용 |
| 원인 | SoT 계층 미준수, "편의상" 복사 |
| 조기 탐지 | 중복 내용 grep 스캔 |
| 교정 | SoT 계층 재확인, 중복 제거, 단일 출처만 유지 |

## 4. Codex Config 난립

| 항목 | 내용 |
|------|------|
| 징후 | config 파일 5개 이상, 어떤 것을 쓸지 혼란 |
| 원인 | 상황별 미세 조정 과잉 |
| 조기 탐지 | .codex/ 내 파일 수 모니터링 |
| 교정 | 3개(기본/보수/반자율) 이하로 유지, 차이는 주석으로 문서화 |

## 5. Claude Skills 난립

| 항목 | 내용 |
|------|------|
| 징후 | skills 10개 이상, 겹치는 절차, 사용되지 않는 스킬 |
| 원인 | 작은 절차마다 스킬 생성 |
| 조기 탐지 | 스킬 사용 빈도 추적 |
| 교정 | 핵심 4개(탐색/계획/검증/PR) 유지, 나머지는 docs로 이동 |

## 6. Hook 과잉

| 항목 | 내용 |
|------|------|
| 징후 | 매 동작마다 5초+ 지연, 불필요한 경고 과다 |
| 원인 | 모든 규칙을 hook으로 강제하려는 시도 |
| 조기 탐지 | hook 실행 시간 측정 |
| 교정 | hook은 "차단/포맷" 용도만, 나머지는 CI에서 검증 |

## 7. 승인 정책 부적절

| 항목 | 내용 |
|------|------|
| 징후 | 모든 것에 승인 필요 (작업 지연) 또는 아무것도 승인 불요 (사고 발생) |
| 원인 | 자율성 수준 미설정 |
| 조기 탐지 | 승인 요청 빈도 vs 실제 위험도 분석 |
| 교정 | Level 1/2/3 체계 적용, 영역별 자율성 차등 |

## 8. 샌드박스 과개방/과제한

| 항목 | 내용 |
|------|------|
| 징후 | 과개방: 에이전트가 시스템 파일 수정. 과제한: 정상 작업도 차단 |
| 원인 | writable_paths 설정 오류 |
| 조기 탐지 | 차단 로그 모니터링 |
| 교정 | 프로필별 writable_paths 주기적 검토 |

## 9. 구조 제약 미강제

| 항목 | 내용 |
|------|------|
| 징후 | ARCHITECTURE.md에 규칙이 있으나 실제 코드는 위반 |
| 원인 | check-structure.sh 미실행 또는 불완전 |
| 조기 탐지 | CI에서 구조 검사 실행 확인 |
| 교정 | check-structure.sh 규칙 추가, CI 필수 단계화 |

## 10. 테스트 통과 + UI 깨짐

| 항목 | 내용 |
|------|------|
| 징후 | 모든 테스트 통과하나 화면이 렌더링 안 됨 |
| 원인 | E2E 테스트 부재, 컴포넌트 통합 미검증 |
| 조기 탐지 | E2E 테스트 커버리지 모니터링 |
| 교정 | Playwright E2E 필수화, 주요 사용자 흐름 10개 시나리오 |

## 11. 로그 있으나 해석 불가

| 항목 | 내용 |
|------|------|
| 징후 | 로그 양은 많으나 문제 원인 파악 불가 |
| 원인 | 비구조화 로그, request-id 미전파 |
| 조기 탐지 | 로그로 실제 문제 추적 시도 (실패하면 문제) |
| 교정 | JSON 구조화 로그, request-id 전 구간 전파 |

## 12. PR 과대화

| 항목 | 내용 |
|------|------|
| 징후 | PR 500줄 이상, 리뷰어가 전체를 파악 불가 |
| 원인 | "한 번에 끝내자" 심리, 분할 기준 불명확 |
| 조기 탐지 | PR 크기 자동 측정 (CI에서) |
| 교정 | 300줄 soft limit, 500줄 hard limit, 초과 시 자동 경고 |

## 13. 임시 패치 누적

| 항목 | 내용 |
|------|------|
| 징후 | TODO 주석 증가, "temporary fix" 코멘트, tech-debt 점수 급증 |
| 원인 | 일정 압박, 근본 원인 미해결 |
| 조기 탐지 | TODO grep 카운트, tech-debt 점수 추이 |
| 교정 | 모든 TODO에 tech-debt-tracker 항목 필수, 점수 임계치 강제 |

## 14. 승인 기준 불명확

| 항목 | 내용 |
|------|------|
| 징후 | "이건 승인 필요한가?" 반복, 에이전트 작업 중단 빈번 |
| 원인 | sop-human-approval.md 불완전 |
| 조기 탐지 | 에스컬레이션 빈도 추적 |
| 교정 | 명시적 승인 목록, 목록에 없으면 에이전트 자율 |

## 15. 잘못된 로컬 패턴 학습

| 항목 | 내용 |
|------|------|
| 징후 | 에이전트가 기존 안티패턴을 복제, 잘못된 코드 스타일 전파 |
| 원인 | 레거시 코드를 참조 기준으로 사용 |
| 조기 탐지 | 코드 리뷰에서 안티패턴 반복 발견 |
| 교정 | ARCHITECTURE.md를 우선 참조, 기존 코드보다 규칙 우선, 리팩토링 exec-plan 생성 |

---

# [18] 산출물 목록

모든 파일이 리포지터리에 생성 완료:

| 파일 | 위치 |
|------|------|
| AGENTS.md 초안 | `AGENTS.md` |
| CLAUDE.md 초안 | `CLAUDE.md` |
| ARCHITECTURE.md 초안 | `ARCHITECTURE.md` |
| Design docs index | `docs/design-docs/index.md` |
| Product specs index | `docs/product-specs/index.md` |
| Exec plan template (active) | `docs/exec-plans/active/_template.md` |
| Exec plan template (completed) | `docs/exec-plans/completed/_template.md` |
| Tech debt tracker | `docs/exec-plans/tech-debt-tracker.md` |
| Codex config (기본) | `.codex/config.toml` |
| Codex config (보수형) | `.codex/config.conservative.toml` |
| Codex config (반자율형) | `.codex/config.semi-autonomous.toml` |
| Skill: explore-codebase | `.claude/skills/explore-codebase/SKILL.md` |
| Skill: create-exec-plan | `.claude/skills/create-exec-plan/SKILL.md` |
| Skill: run-verification | `.claude/skills/run-verification/SKILL.md` |
| Skill: prepare-pr | `.claude/skills/prepare-pr/SKILL.md` |
| Hooks 설계 | `.claude/hooks/hooks-design.md` |
| QUALITY_SCORE.md | `docs/references/QUALITY_SCORE.md` |
| RELIABILITY.md | `docs/references/RELIABILITY.md` |
| SECURITY.md | `docs/references/SECURITY.md` |
| PR_TEMPLATE.md | `.github/PR_TEMPLATE.md` |
| Golden Rules | `docs/references/golden-rules.md` |
| 구조 검사 스크립트 | `scripts/check-structure.sh` |
| 검증 파이프라인 | `scripts/verify.sh` |
| 품질 점수 스크립트 | `scripts/quality-score.sh` |
| CI 파이프라인 | `.github/workflows/ci.yml` |
| 공용 SOP | `docs/references/sop-shared-agent.md` |
| Codex SOP | `docs/references/sop-codex.md` |
| Claude SOP | `docs/references/sop-claude.md` |
| 인간 승인 SOP | `docs/references/sop-human-approval.md` |
| Worktree SOP | `docs/references/sop-worktree.md` |
| 커밋 규칙 | `docs/references/commit-convention.md` |

---

# [19] 요약: MVP vs 확장

## 즉시 실행 가능한 MVP (1~2주)

**반드시** 배치:
1. `AGENTS.md` + `CLAUDE.md` (포인터 파일)
2. `ARCHITECTURE.md` (구조 규칙)
3. `docs/references/golden-rules.md` (불변 규칙)
4. `scripts/verify.sh` + `scripts/check-structure.sh` (검증)
5. `.codex/config.toml` (기본 설정)
6. `.claude/skills/` (4개 핵심 스킬)
7. `.github/workflows/ci.yml` (CI 파이프라인)
8. `.github/PR_TEMPLATE.md` (PR 표준)

**권장** 배치:
- `docs/exec-plans/` 구조 + 템플릿
- `docs/references/SECURITY.md`
- `.claude/hooks/` 설계

## 확장 버전 (3~12주)

점진 추가:
- design-docs, product-specs 체계 (3~4주)
- E2E 테스트 + 관측 가능성 (7~8주)
- 자율성 Level 2 전환 (9~10주)
- drift 감지 + cleanup 자동화 (11~12주)
- 품질 점수 자동 계산 + 리포트 (11~12주)

---

**핵심을 잊지 말 것: "하나의 코어, 두 개의 얇은 어댑터"**

정책은 공용 docs에 한 번만 쓴다. AGENTS.md와 CLAUDE.md는 가리키기만 한다.
Codex든 Claude든 최종적으로 같은 `scripts/verify.sh`를 통과한다.
