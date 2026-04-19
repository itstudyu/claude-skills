---
name: prompt-to-plan
description: |
  Transforms rough user input into structured implementation specs using proven prompt
  engineering frameworks (Anthropic, CO-STAR, 7R), then enters Plan Mode to build
  actionable implementation plans. Two mandatory gates: Refinement (refined spec
  presented and approved) and Plan (plan presented and approved). Use this skill
  whenever the user says "refine and plan", "rough prompt", "정리해서 플랜",
  "프롬프트 다듬어서 플랜", "整理してプラン", "ざっくり要件からプラン",
  or otherwise asks to convert a half-formed request into a structured implementation
  plan. Proactively suggest this skill when the user's request is vague,
  contradictory, or missing context that must be refined before coding.
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

### Pre-research approval

When the input requires research before a meaningful spec can be written
(e.g. "analyze this codebase", "read these articles", URLs provided),
present a brief research plan first:

> "This request needs upfront research to write a meaningful spec.
> I plan to: [what you'll research, how, estimated scope].
> Proceed?"

Get approval before launching any research agents, searches, or fetches.
Do not announce research as already completed — that removes the user's
ability to adjust scope or method.

### Respect user-specified execution methods

When the user specifies how something should be done (e.g. tmux sessions,
specific tools, particular file structure, execution order), treat it as a
requirement, not a suggestion. If you believe an alternative is better:

1. Present the spec with the user's method as specified
2. Add a note: "Alternative: [your suggestion] because [reason]. Switch?"
3. Wait for approval before using the alternative

Do not silently substitute and report it after the fact in "What Changed".
The user chose that method for a reason you may not know.

## Workflow Checklist

The skill has exactly two user-visible phases: **REFINE** and **PLAN**. Everything
else (language detection, triage, analysis) happens silently as part of REFINE —
do NOT announce these as separate steps or make the user wait through a visible
"analyzing..." prelude. The user asked for `prompt → plan`; give them that.

### Phase 1: REFINE (produce the refined spec)

1. **Read the raw input** — Accept verbatim, detect language silently, respond in that language.
1b. **Scan project context (Standard + Deep only)** — Before drafting, run a
    lightweight codebase scan to ground the spec in reality. Keep it fast:
    - Glob for project config files (package.json, pyproject.toml, Cargo.toml,
      go.mod, build.gradle, etc.) to detect tech stack
    - Glob for directory structure (src/*/, tests/*/, app/*/) to understand layout
    - Grep for patterns relevant to the user's request (existing implementations,
      naming conventions, test patterns)
    Store findings as compact identifiers (file paths, version strings, pattern
    names) — not full file contents. These feed into the spec's `<context>` tag.
    Skip this step if the user provides explicit tech stack info or says
    "just plan it". Skip entirely for Lite tier.
2. **Draft the refined spec directly** — While drafting, internally decide complexity tier
   (Lite / Standard / Deep) based on scope signals and pick the matching template.
   Incorporate codebase scan findings into `<context>` where available.
   Do not announce the tier as a separate step; it shows up implicitly in which
   sections you fill.
3. **Clarify only if blocking** — If a critical ambiguity would make the spec wrong,
   ask 1-3 targeted Flipped-Interaction questions (see pattern below). Otherwise
   state your assumptions inside the spec's `<context>` and move on. Never ask
   clarifying questions for Lite-tier inputs.
4. **Research only if Deep + warranted** — Skip by default. Only run WebSearch
   (max 3 queries) when the tier is Deep AND the domain is unfamiliar AND the user
   did not say "just plan it". Research findings feed into `<context>` / `<constraints>`.
4b. **Self-correct before presenting (Generate → Review → Refine)** — This is
    still silent (no user-visible output), but it is a structured 3-pass check:

    Pass 1 — Coverage: Every intent from the raw input maps to a section in the
    spec. No requirements dropped or altered beyond clarification.

    Pass 2 — Cross-validation: Re-read the original input and compare against the
    spec. Flag any drift between what the user said and what the spec says.
    Check that assumptions in `<context>` are reasonable defaults, not inventions.
    Apply a quick health check to the spec text:
    - No undefined jargon (terms the executing agent might not know)
    - No ambiguous scope words ("appropriate", "relevant", "as needed") without
      specific definitions
    - No subjective modifiers without measurable criteria ("fast" → "p99 < 200ms")

    Pass 3 — Completeness: Ask yourself "what did I miss?" Check for: implicit
    requirements the user likely expects but didn't state, error handling needs,
    edge cases visible from the codebase scan. If anything surfaces, fold it into
    the spec as an explicit assumption in `<context>` or a constraint.

    If any pass reveals a problem, fix the spec before presenting.
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

## Best Practices

**Presentation flow**: Jump straight to the refined spec. Triage and analysis
happen silently — the user sees input → spec, not input → analysis → triage → spec.

**Clarification**: State assumptions in `<context>` rather than asking. Reserve
questions for blocking ambiguities only (never for Lite tier).

**Research**: Deep tier only, domain-unfamiliar only. Standard and Lite use
codebase scan results instead.

**Constraint phrasing**: Use calm, positive phrasing ("Use CSS modules for
styling" not "Do NOT use inline styles"). Avoid CAPS LOCK emphasis,
"IMPORTANT:", "CRITICAL:", "YOU MUST" — these are counterproductive for Claude.

**Scope discipline**: State what is in scope AND what is out of scope. Omit
empty template sections rather than filling them for completeness.

**Task specificity**: Every plan task names exact files and contains actual code.
"Implement the feature" is not a task.

**Reasoning guidance**: Use outcome-oriented phrasing ("evaluate tradeoffs",
"identify edge cases") rather than "think step by step" or "think hard" — these
are regular text on current Claude models, not thinking budget controls.

**Instruction style**: General goals with constraints produce better reasoning
than hand-written step-by-step procedures in `<task>`.

### Common Pitfalls

- Announcing complexity tier as a separate visible step
- Adding constraints the user never implied
- Running WebSearch for Standard/Lite tiers
- Over-specifying Lite-tier tasks or adding role for Lite tier
- Assuming English when input is in another language
- Executing without explicit approval or skipping Plan Mode
- Generating a plan without refining the prompt first
- Adding scope beyond what the refined spec defines

## Target Model Adaptation

- **Default (Claude)**: Use XML tags as shown above
- **OpenAI (GPT)**: Switch to Markdown headers (`# Role`, `## Task`, etc.)
- **Other models**: Use Markdown headers as universal fallback

Detect if the user mentions a target model and adjust delimiter style accordingly.

### Current Claude Notes

When the refined spec will be executed by a current-generation Claude model:

- **No prefilling**: Prefilled assistant responses are not supported.
  Use explicit instructions instead.
- **Scope boundaries required**: Opus-class models tend to create extra files and
  unnecessary abstractions. Include in `<task>`: "implement only what is
  specified, no additional features or abstractions." Explicitly state what
  is OUT of scope.
- **Soften thoroughness cues**: If raw input contains "be thorough" or "think
  about everything", soften or remove — it causes over-exploration.

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
| Large feature with many unknowns | Offer interview mode: "This is broad enough that an interview would produce a better spec. I'll ask 5-8 structured questions, then write a spec from your answers. Or I can draft a spec now with assumptions marked. Preference?" If interview chosen, use Flipped Interaction Pattern for questions, compile answers into spec, present for approval. |
| User provides URL or file reference | Incorporate as context material |
| EnterPlanMode denied by user | Write plan as structured markdown in chat instead |
