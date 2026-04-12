---
name: prompt-to-plan
description: |
  Transforms rough user input into structured implementation specs, then enters
  Plan Mode to build actionable plans. Only when explicitly requested.
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
---

# Prompt to Plan

Transform rough user input into well-structured implementation specs using proven prompt
engineering frameworks (Anthropic, CO-STAR, 7R), then enter Plan Mode to build actionable
implementation plans from the refined output.

## Mandatory Workflow Gates

This skill has two non-negotiable gates. Skipping either defeats its purpose.

1. **Refinement gate** — Analyze and structure raw input into a refined spec.
   Present to user. Do not proceed without explicit approval.
2. **Plan Mode gate** — After approval, enter Plan Mode and create the
   implementation plan. Do not skip Plan Mode.

The transformation step is the core value. The raw prompt goes in, a structured
spec comes out. Executing the raw prompt directly would bypass the entire skill.

Even when the input is already well-structured (explicit steps, clear scope,
specified tools), the refinement gate still applies. In this case, refinement
may be brief — acknowledge the structure, note any assumptions or substitutions
you would make (e.g. subagent instead of tmux), and confirm before executing.
The gate exists to catch misalignment early, not to add ceremony.

## Workflow Checklist

The skill has exactly two user-visible phases: **REFINE** and **PLAN**. Everything
else (language detection, triage, analysis) happens silently as part of REFINE —
do NOT announce these as separate steps or make the user wait through a visible
"analyzing..." prelude. The user asked for `prompt → plan`; give them that.

### Phase 1: REFINE (produce the refined spec)

1. **Read the raw input** — Accept verbatim, detect language silently, respond in that language.
2. **Draft the refined spec directly** — While drafting, internally decide complexity tier
   (Lite / Standard / Deep) based on scope signals and pick the matching template.
   Do not announce the tier as a separate step; it shows up implicitly in which
   sections you fill.
3. **Clarify only if blocking** — If a critical ambiguity would make the spec wrong,
   ask 1-3 targeted Flipped-Interaction questions (see pattern below). Otherwise
   state your assumptions inside the spec's `<context>` and move on. Never ask
   clarifying questions for Lite-tier inputs.
4. **Research only if Deep + warranted** — Skip by default. Only run WebSearch
   (max 3 queries) when the tier is Deep AND the domain is unfamiliar AND the user
   did not say "just plan it". Research findings feed into `<context>` / `<constraints>`.
4b. **Self-check before presenting** — Before showing the spec, verify:
   - Every intent from the raw input maps to a section in the spec
   - No requirements were dropped or altered beyond clarification
   - Assumptions stated in `<context>` are reasonable defaults
   This check is silent — do not announce it to the user.
5. **Present the refined spec** — Code block + a short "What Changed" summary
   (3-5 bullets) + a one-line plan preview. End with: "Ready to enter Plan Mode?"
6. **Iterate on request** — If the user asks for changes, revise the spec in place
   and re-present. Do not proceed without explicit approval.

### Phase 2: PLAN (produce the implementation plan)

7. **Enter Plan Mode** — Call `EnterPlanMode` the moment approval is given.
8. **Write the implementation plan** — Follow write-plan conventions (section below).
   Every requirement in the refined spec maps to at least one task.
9. **Self-review and present the plan** — Check for placeholders, consistency,
   spec coverage. Then offer the execution handoff (Subagent-Driven vs Inline).

## Complexity Triage (silent)

Triage happens in your head while you draft the spec — it is NOT a user-visible
step. Pick the tier that matches the input and fill the matching template sections.

| Tier | Signal | Sections Used | Research? | Plan Depth | Reasoning Guidance |
|------|--------|---------------|-----------|------------|--------------------|
| **Lite** | Single file change, clear intent | `task` + `deliverables` | No | 1-3 tasks | None needed |
| **Standard** | Multi-file, some ambiguity | `role` + `context` + `task` + `constraints` + `deliverables` | No (unless asked) | 4-10 tasks | Default adaptive |
| **Deep** | Complex architecture, high stakes, ambiguous scope | All sections + `acceptance_criteria` + optional `examples` | Yes (if warranted) | 10+ tasks, phased | Outcome-oriented guidance in Plan Mode (e.g. "evaluate architecture tradeoffs and edge cases") |

> **Tip**: For Deep tier plans, consider running `/effort high` or `/effort max`
> before entering Plan Mode to maximize reasoning depth. For Lite tier,
> `/effort medium` keeps responses fast.

If the user pushes back on the depth after seeing the spec ("simpler" / "more detail"),
shift tiers then — don't pre-negotiate depth before they've seen anything.

## Flipped Interaction Pattern (Clarification)

Do NOT ask vague open-ended questions. Instead, propose a concrete interpretation and ask for confirmation:

```
Your request: "write something about our new feature"

My interpretation:
- Goal: Announce a new product feature to existing users
- Tone: Professional but friendly (marketing copy)
- Length: ~200 words
- Audience: Current customers

Does this match your intent? Anything to adjust?
```

Rules:
- Maximum 1-3 targeted questions
- Each structured as "I think you mean X — correct?"
- Skip entirely for Lite tier (intent is already clear)

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

## 구현 중심 템플릿

티어별 XML 템플릿은 [templates.md](templates.md) 참조.

## 도메인 리서치 프로토콜 (Deep 티어 전용)

WebSearch 패턴은 [research-protocol.md](research-protocol.md) 참조.

## Presenting the Refined Spec

When showing the refined spec to the user:

1. **"What Changed" summary** above the code block (3-5 bullet points):
   - What you clarified or made explicit
   - What structure you added
   - What constraints you inferred from context
   - What research findings you incorporated (if Deep tier)

2. **The refined spec** in a fenced code block

3. **Plan preview** — Brief outline of what the implementation plan will cover

4. **Approval prompt**: "Ready to enter Plan Mode? Or want me to adjust anything?"

If the user says "shorter" or "simpler" — drop sections, reduce tier.
If the user says "more detail" — add sections, expand constraints, upgrade tier.

## Plan Mode Transition

After the user approves the refined spec:

1. **Enter Plan Mode** — Call `EnterPlanMode`

> **Note**: Plan Mode is a read-only prompt mode — it does not change thinking
> depth. Extended thinking is always active with adaptive depth regardless of mode.
> For Deep tier, add reasoning guidance in your first instruction after entering
> Plan Mode.

2. **Write the implementation plan** following write-plan conventions:

## 플랜 규칙

플랜 문서 구조는 [plan-conventions.md](plan-conventions.md) 참조.

## Anti-Patterns

Do NOT:
- **Announce an "analyzing" phase before the refined spec.** The user asked for
  `prompt → plan`, not `prompt → analysis → triage → clarification → plan`. Do the
  thinking silently and jump straight to presenting the refined spec.
- Announce the complexity tier as a separate step ("I classified this as Standard...").
  Just pick the tier and draft accordingly; the user will see the result.
- Ask clarifying questions unless a blocking ambiguity would make the spec wrong.
  State assumptions in `<context>` instead.
- Run WebSearch for Standard or Lite tiers. Research is Deep-tier only, and only
  when the domain is genuinely unfamiliar.
- Use CAPS LOCK emphasis in constraints (calm phrasing works better for Claude)
- Over-specify simple tasks (Lite tier exists for a reason)
- Add constraints the user never implied
- Assume English — always match the user's language
- Make specs longer just to fill sections — omit empty sections
- Add a role for Lite tier (unnecessary overhead)
- Execute without explicit approval
- Skip Plan Mode after approval
- Add "IMPORTANT:", "CRITICAL:", "YOU MUST" phrasing (counterproductive for Claude)
- Generate a plan without refining the prompt first
- Create vague tasks ("implement the feature") — every task needs exact files and code
- Add scope beyond what the refined spec defines
- Include "think step by step" or "think hard" in refined specs — these are
  regular prompt text on Claude 4.6, not thinking budget controls. Prefer
  outcome-oriented guidance ("evaluate tradeoffs", "identify edge cases")
- Over-prescribe implementation steps in `<task>` — general instructions produce
  better reasoning than hand-written step-by-step plans with adaptive thinking

## Target Model Adaptation

- **Default (Claude)**: Use XML tags as shown above
- **OpenAI (GPT)**: Switch to Markdown headers (`# Role`, `## Task`, etc.)
- **Other models**: Use Markdown headers as universal fallback

Detect if the user mentions a target model and adjust delimiter style accordingly.

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

## Multi-Language Support

- Detect the user's input language and operate entirely in that language
- XML tag names stay in English (structural, not content)
- All content inside tags is in the user's language
- The "What Changed" summary is in the user's language
- Plan content (task descriptions, comments) follow the user's language
- Code comments follow project coding standards (e.g., Japanese if project requires)

## Edge Cases

| Case | Handling |
|------|----------|
| Input is already well-structured | Acknowledge it, suggest minor improvements, proceed to plan |
| User says "just plan it, don't ask" | Lite tier, minimal refinement, straight to Plan Mode |
| Mixed languages in input | Preserve the dominant language, keep technical terms as-is |
| User wants the refined spec but not the plan | Present and stop |
| User wants the plan but not refinement | Suggest refinement benefits, respect override if insisted |
| Single word or phrase input | Treat as Lite, expand into minimal task + deliverables |
| Extremely long rambling input | Extract core intent, summarize into context, confirm interpretation |
| User provides URL or file reference | Incorporate as context material |
| EnterPlanMode denied by user | Write plan as structured markdown in chat instead |
