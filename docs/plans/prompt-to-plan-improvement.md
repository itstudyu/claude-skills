# prompt-to-plan 스킬 개선 구현 계획

> **생성일**: 2026-04-12
> **리서치 리포트**: `docs/research/2026-04-12-prompt-to-plan-improvements.md`
> **대상 파일**: `workflow/prompt-to-plan/SKILL.md`, `workflow/prompt-to-plan/evals/evals.json`
> **총 Diff**: 20개 (전부 채택)

## 사전 준비

새 세션에서 작업 시작 전:
1. `workflow/prompt-to-plan/SKILL.md` 읽기
2. `workflow/prompt-to-plan/evals/evals.json` 읽기
3. 이 계획서 전체를 읽기

---

## Phase 1: 구조 변경 (Diff 7 먼저 — 파일 분리)

Diff 7을 먼저 적용해야 나머지 diff들이 올바른 파일에 들어간다.

### Task 1: SKILL.md에서 templates 분리 → `templates.md`

**생성**: `workflow/prompt-to-plan/templates.md`

SKILL.md L115-201 (## Implementation-Focused Template 전체)을 잘라내서 `templates.md`로 이동.
SKILL.md에는 다음 참조만 남김:

```markdown
## 구현 중심 템플릿

티어별 XML 템플릿은 [templates.md](templates.md) 참조.
```

### Task 2: SKILL.md에서 research protocol 분리 → `research-protocol.md`

**생성**: `workflow/prompt-to-plan/research-protocol.md`

SKILL.md L203-237 (## Domain Research Protocol 전체)을 잘라내서 `research-protocol.md`로 이동.
SKILL.md에는 다음 참조만 남김:

```markdown
## 도메인 리서치 프로토콜 (Deep 티어 전용)

WebSearch 패턴은 [research-protocol.md](research-protocol.md) 참조.
```

### Task 3: SKILL.md에서 plan conventions 분리 → `plan-conventions.md`

**생성**: `workflow/prompt-to-plan/plan-conventions.md`

SKILL.md L259-330 (## Plan Mode Transition의 ### Plan Document Header부터 ### Self-Review Before Presenting Plan까지)을 잘라내서 `plan-conventions.md`로 이동.
SKILL.md에는 다음 참조만 남김:

```markdown
## 플랜 규칙

플랜 문서 구조는 [plan-conventions.md](plan-conventions.md) 참조.
```

### Task 4: 커밋

```bash
git add workflow/prompt-to-plan/templates.md workflow/prompt-to-plan/research-protocol.md workflow/prompt-to-plan/plan-conventions.md workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: progressive disclosure — SKILL.md를 4파일로 분리"
```

---

## Phase 2: Frontmatter 수정 (Diff 4, 9, 10)

### Task 5: description 압축 (Diff 4 + 10)

SKILL.md frontmatter의 description을 다음으로 교체:

```yaml
description: |
  Transforms rough user input into structured implementation specs, then enters
  Plan Mode to build actionable plans. Only when explicitly requested.
```

트리거 문구 목록 제거. Activation Triggers 섹션도 추가하지 않음.

### Task 6: allowed-tools 축소 (Diff 9)

```yaml
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
```

Bash, Write, Edit 제거.

### Task 7: 커밋

```bash
git add workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: frontmatter 개선 — description 압축, allowed-tools 축소"
```

---

## Phase 3: HARD-GATE 재작성 (Diff 2)

### Task 8: HARD-GATE → 필수 워크플로우 게이트

SKILL.md에서 `<HARD-GATE>` 블록 전체를 다음으로 교체:

```markdown
## Mandatory Workflow Gates

This skill has two non-negotiable gates. Skipping either defeats its purpose.

1. **Refinement gate** — Analyze and structure raw input into a refined spec.
   Present to user. Do not proceed without explicit approval.
2. **Plan Mode gate** — After approval, enter Plan Mode and create the
   implementation plan. Do not skip Plan Mode.

The transformation step is the core value. The raw prompt goes in, a structured
spec comes out. Executing the raw prompt directly would bypass the entire skill.
```

### Task 9: 커밋

```bash
git add workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: HARD-GATE를 calm phrasing으로 재작성"
```

---

## Phase 4: 스펙 자체 검증 추가 (Diff 6)

### Task 10: Phase 1 워크플로우에 자체 검증 단계 삽입

Phase 1 REFINE의 Step 4 (Research only if Deep + warranted) 이후, Step 5 (Present the refined spec) 이전에 삽입:

```markdown
4b. **Self-check before presenting** — Before showing the spec, verify:
   - Every intent from the raw input maps to a section in the spec
   - No requirements were dropped or altered beyond clarification
   - Assumptions stated in `<context>` are reasonable defaults
   This check is silent — do not announce it to the user.
```

### Task 11: 커밋

```bash
git add workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: REFINE 단계에 스펙 자체 검증 추가"
```

---

## Phase 5: 템플릿 개선 (Diff 1, 5, 11, 12, 13, 16)

이 작업은 Phase 1에서 분리한 `templates.md`에 적용.

### Task 12: `<task>` 템플릿에 WHY + 목표 지향 수정 (Diff 12)

`templates.md`의 Full Template `<task>` 가이드를 수정:

```xml
<task>
[Clear, specific implementation instruction.
 - Why this task matters (1 sentence of motivation/background)
 - One primary action verb (build, create, refactor, migrate)
 - What to achieve (goals, not step-by-step procedure)
 - Explicit scope: what to include AND what to exclude]
</task>
```

### Task 13: 긍정형 지시 원칙 추가 (Diff 11)

`templates.md`의 `<constraints>` 설명 이후에 추가:

```markdown
When writing constraints, prefer positive instructions over prohibitions:
- Instead of: "Do not use inline styles"
- Write: "Use CSS modules for all styling"
```

### Task 14: Deep 템플릿에 선택적 `<examples>` 추가 (Diff 13)

Full Template의 `<acceptance_criteria>` 이후에 추가:

```xml
<examples> (optional — include when the task involves complex transformation,
classification, or format conversion that benefits from concrete demonstrations)
<example>
[Input → expected output pair showing the desired transformation]
</example>
</examples>
```

### Task 15: 태그 순서 근거 설명 추가 (Diff 16)

`templates.md` 상단에 다음 메모 추가:

```markdown
> **Tag ordering rationale**: `<context>` and long data come first, the core
> query comes last. Anthropic docs confirm queries at the end can improve
> response quality by up to 30%. This ordering is intentional.
```

### Task 16: 커밋

```bash
git add workflow/prompt-to-plan/templates.md
git commit -m "prompt-to-plan: 템플릿 개선 — WHY, 긍정형 지시, examples, 태그 순서 설명"
```

---

## Phase 6: Few-shot 변환 예시 추가 (Diff 1)

### Task 17: SKILL.md에 Transformation Examples 섹션 추가

Flipped Interaction Pattern 섹션 이후에 삽입. 아래 전문을 그대로 사용:

```markdown
## Transformation Examples

<examples>

<example>
**Tier: Lite**

Raw input:
> Fix the login button color. It should be blue not gray.

Refined spec:
<task>Change the login button background color from gray to blue (#2563EB)
in the login form component.</task>
<deliverables>
- Modify: `src/components/LoginForm.tsx` (button style)
- Verify: login page renders with blue button
</deliverables>
</example>

<example>
**Tier: Standard**

Raw input:
> 다크모드 추가하고 싶어

Refined spec:
<context>
프로젝트는 React + Tailwind CSS 기반. 현재 라이트 모드만 지원.
CSS custom properties를 사용하면 테마 전환이 용이함.
</context>
<task>CSS custom properties 기반 다크모드 토글 기능을 구현한다.
사용자의 OS 설정을 기본값으로 감지하고, 수동 토글도 지원한다.</task>
<constraints>
- Tailwind dark: variant 활용 — 기존 클래스 시스템과 일관성 유지
- localStorage에 선호 테마 저장 — 페이지 새로고침 후에도 유지
- 전환 시 깜빡임(FOUC) 방지 — 초기 로드 시 `<script>`로 클래스 적용
</constraints>
<deliverables>
- Create: `src/hooks/useTheme.ts` (테마 상태 관리 훅)
- Modify: `src/App.tsx` (테마 provider 래핑)
- Modify: `tailwind.config.js` (darkMode: 'class')
- Create: `src/components/ThemeToggle.tsx`
- Test: `tests/useTheme.test.ts`
</deliverables>
</example>

<example>
**Tier: Deep**

Raw input:
> マイクロサービスアーキテクチャへの移行戦略を設計して

Refined spec:
<role>
分散システムアーキテクトとして、モノリスからマイクロサービスへの段階的移行を設計する。
大規模トラフィック環境での実務経験を持つ視点で助言する。
</role>
<context>
現行システムはDjango monolith (Python 3.11)、PostgreSQL 15、Redis。
月間アクティブユーザー約50万人。デプロイ頻度は週1回。
チームは5名のバックエンドエンジニア。Kubernetes環境あり。
</context>
<task>
Strangler Fig パターンを用いた段階的マイクロサービス移行計画を策定する。
Phase 1で認証サービスを分離、Phase 2でユーザー管理、Phase 3で通知サービスを対象とする。
</task>
<constraints>
- 移行中もサービス無停止を維持 — SLA 99.9%要件
- サービス間通信はgRPCを基本、非同期処理はKafka — チーム既存スキルとの整合
- 各Phaseは独立デプロイ可能 — ロールバック容易性の確保
- データベースは段階的分離(shared DB → schema分離 → 独立DB) — データ整合性リスク最小化
</constraints>
<deliverables>
- Architecture Decision Record (ADR) for each phase
- Service boundary diagrams (Mermaid)
- API contract definitions (protobuf)
- Migration runbook per phase
- Rollback procedures
- Monitoring/alerting setup (Prometheus + Grafana dashboards)
</deliverables>
<acceptance_criteria>
- Phase 1完了後、認証レイテンシがp99 < 200msを維持
- 移行中のエラー率が0.1%未満
- 各サービスが独立してCI/CDパイプラインを持つ
- カナリアデプロイで段階的リリース可能
</acceptance_criteria>

上記の移行計画を、各Phaseの実装タスクレベルまで詳細化してください。
</example>

</examples>
```

### Task 18: 커밋

```bash
git add workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: 티어별 few-shot 변환 예시 3개 추가"
```

---

## Phase 7: Claude 4.6 참고사항 + Anti-patterns (Diff 5, 8)

### Task 19: Target Model Adaptation 확장 (Diff 5)

SKILL.md의 "Target Model Adaptation" 섹션 끝에 다음 서브섹션 추가:

```markdown
### Claude 4.6 Notes

When the refined spec will be executed by Claude 4.6 (the default):

- **No prefilling**: Prefilled assistant responses are no longer supported.
  Use explicit instructions instead.
- **Overengineering tendency**: Opus 4.6 tends to create extra files, add
  unnecessary abstractions, and build in flexibility that wasn't requested.
  Include clear scope boundaries in `<task>`: "implement only what is specified,
  no additional features or abstractions."
- **Overthinking tendency**: Opus 4.6 does significantly more upfront exploration
  than previous models. If the raw prompt contains "be thorough" or "think about
  everything", soften or remove — it causes over-exploration.
- **General > prescriptive**: "Think thoroughly about the tradeoffs" produces
  better reasoning than a hand-written step-by-step analysis plan.
  In `<task>`, state goals and constraints; let the model determine the approach.
- **Scope control**: Refined specs should explicitly state what is OUT of scope,
  not just what is in scope. This counteracts the overengineering tendency.
```

### Task 20: 사고 관련 anti-pattern 추가 (Diff 8)

SKILL.md의 Anti-Patterns "Do NOT:" 리스트 끝에 추가:

```markdown
- Include "think step by step" or "think hard" in refined specs — these are
  regular prompt text on Claude 4.6, not thinking budget controls. Prefer
  outcome-oriented guidance ("evaluate tradeoffs", "identify edge cases")
- Over-prescribe implementation steps in `<task>` — general instructions produce
  better reasoning than hand-written step-by-step plans with adaptive thinking
```

### Task 21: 커밋

```bash
git add workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: Claude 4.6 참고사항 + 사고 관련 anti-pattern 추가"
```

---

## Phase 8: 복잡도 분류 확장 (Diff 14, 20)

### Task 22: Complexity Triage 테이블 확장 (Diff 14 + 20)

SKILL.md의 Complexity Triage 테이블을 다음으로 교체:

```markdown
| Tier | Signal | Sections Used | Research? | Plan Depth | Reasoning Guidance |
|------|--------|---------------|-----------|------------|--------------------|
| **Lite** | Single file change, clear intent | `task` + `deliverables` | No | 1-3 tasks | None needed |
| **Standard** | Multi-file, some ambiguity | `role` + `context` + `task` + `constraints` + `deliverables` | No (unless asked) | 4-10 tasks | Default adaptive |
| **Deep** | Complex architecture, high stakes, ambiguous scope | All sections + `acceptance_criteria` + optional `examples` | Yes (if warranted) | 10+ tasks, phased | Outcome-oriented guidance in Plan Mode (e.g. "evaluate architecture tradeoffs and edge cases") |
```

테이블 아래에 각주 추가 (Diff 20):

```markdown
> **Tip**: For Deep tier plans, consider running `/effort high` or `/effort max`
> before entering Plan Mode to maximize reasoning depth. For Lite tier,
> `/effort medium` keeps responses fast.
```

### Task 23: 커밋

```bash
git add workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: 복잡도 분류에 추론 안내 + effort 팁 추가"
```

---

## Phase 9: Plan Mode Transition 개선 (Diff 15, 17, 19)

### Task 24: Plan Mode ↔ Extended Thinking 메모 추가 (Diff 17)

SKILL.md의 "Plan Mode Transition" 섹션, "Enter Plan Mode" 단계 이후에 추가:

```markdown
> **Note**: Plan Mode is a read-only prompt mode — it does not change thinking
> depth. Extended thinking is always active with adaptive depth regardless of mode.
> For Deep tier, add reasoning guidance in your first instruction after entering
> Plan Mode.
```

### Task 25: Execution Handoff 명확화 (Diff 15 + 19)

SKILL.md의 Execution Handoff를 다음으로 교체:

```markdown
> **Plan complete.** Saved to `docs/plans/<feature>.md`.
>
> **Two execution options:**
>
> **1. Subagent-Driven (recommended)** — fresh subagent per task, review between tasks.
>    Run: `/subagent-dev docs/plans/<feature>.md`
>
> **2. Inline Execution** — execute tasks in this session with checkpoints.
>
> **Which approach?**

- Subagent-Driven → User runs `/subagent-dev <plan-path>` (ensures clean context)
- Inline Execution → Execute tasks sequentially in current session

> **Note**: For parallel implementation tasks, subagents can use `isolation: worktree`
> to get isolated repo copies, avoiding file conflicts.
```

### Task 26: 커밋

```bash
git add workflow/prompt-to-plan/SKILL.md
git commit -m "prompt-to-plan: Plan Mode 설명 보강 + 핸드오프 명확화 + worktree 언급"
```

---

## Phase 10: 리서치 프로토콜 개선 (Diff 18)

### Task 27: 인터리브드 사고 안내 추가 (Diff 18)

`workflow/prompt-to-plan/research-protocol.md`의 WebSearch 쿼리 규칙 부분에 추가:

```markdown
After each WebSearch result, reflect on how the findings affect the spec
before running the next query. Let each search inform the next rather than
running all searches upfront.
```

### Task 28: 커밋

```bash
git add workflow/prompt-to-plan/research-protocol.md
git commit -m "prompt-to-plan: 리서치 프로토콜에 인터리브드 반성 안내 추가"
```

---

## Phase 11: evals.json 리팩터링 (Diff 3)

### Task 29: evals.json을 공식 스키마로 교체 (Diff 3)

`workflow/prompt-to-plan/evals/evals.json` 전체를 다음으로 교체:

```json
{
  "skill_name": "prompt-to-plan",
  "evals": [
    {
      "skills": ["prompt-to-plan"],
      "query": "다크모드 추가하고 싶어. 정리해서 플랜 만들어줘.",
      "files": [],
      "expected_behavior": [
        "Classified as Standard tier",
        "Flipped Interaction pattern used for clarification",
        "Refined spec contains <context>, <task>, <constraints>, <deliverables>",
        "All content in Korean (matching input language)",
        "Waits for approval before planning",
        "Calls EnterPlanMode after approval",
        "Plan follows write-plan conventions (checkbox steps, TDD, no placeholders)"
      ]
    },
    {
      "skills": ["prompt-to-plan"],
      "query": "Fix the login button color. It should be blue not gray.",
      "files": [],
      "expected_behavior": [
        "Classified as Lite tier",
        "No Flipped Interaction (clear intent)",
        "Refined spec uses only <task> and <deliverables>",
        "Plan has 1-3 bite-sized tasks",
        "Calls EnterPlanMode"
      ]
    },
    {
      "skills": ["prompt-to-plan"],
      "query": "マイクロサービスアーキテクチャへの移行戦略を設計して、実装プランまで作って",
      "files": [],
      "expected_behavior": [
        "Classified as Deep tier",
        "2-3 WebSearch queries executed",
        "Research findings in <context>",
        "All sections present including <acceptance_criteria>",
        "Content in Japanese",
        "What Changed summary in Japanese",
        "Plan is phased with 10+ tasks",
        "Calls EnterPlanMode"
      ]
    }
  ]
}
```

### Task 30: 커밋

```bash
git add workflow/prompt-to-plan/evals/evals.json
git commit -m "prompt-to-plan: evals.json을 공식 스키마에 맞게 리팩터링"
```

---

## 최종 검증

### Task 31: 전체 검증

1. SKILL.md가 500줄 이하인지 확인: `wc -l workflow/prompt-to-plan/SKILL.md`
2. 분리된 파일 3개 존재 확인: `ls workflow/prompt-to-plan/*.md`
3. evals.json 유효성: `python3 -c "import json; json.load(open('workflow/prompt-to-plan/evals/evals.json'))"`
4. SKILL.md에서 HARD-GATE, NEVER, IMPORTANT, CRITICAL 등 공격적 표현 잔존 여부: `grep -i "HARD-GATE\|NEVER\|IMPORTANT:\|CRITICAL:\|YOU MUST" workflow/prompt-to-plan/SKILL.md`
5. 분리된 파일 참조 링크가 SKILL.md에 존재하는지 확인

### Task 32: 최종 커밋 (필요 시)

검증에서 발견된 문제 수정 후 커밋.

---

## 실행 가이드

새 세션에서 이 계획서를 열고 다음과 같이 실행:

```
이 계획서를 읽고 Phase 1부터 순서대로 실행해줘:
docs/plans/prompt-to-plan-improvement.md
```

Phase별로 커밋하므로 문제 발생 시 해당 Phase만 롤백 가능.
