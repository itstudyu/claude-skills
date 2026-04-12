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

| Tier | Signal | Sections Used | Research? | Plan Depth |
|------|--------|---------------|-----------|------------|
| **Lite** | Single file change, clear intent | `task` + `deliverables` | No | 1-3 tasks |
| **Standard** | Multi-file, some ambiguity | `role` + `context` + `task` + `constraints` + `deliverables` | No (unless asked) | 4-10 tasks |
| **Deep** | Complex architecture, high stakes, ambiguous scope | All sections + `acceptance_criteria` | Yes (if warranted) | 10+ tasks, phased |

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

## Target Model Adaptation

- **Default (Claude)**: Use XML tags as shown above
- **OpenAI (GPT)**: Switch to Markdown headers (`# Role`, `## Task`, etc.)
- **Other models**: Use Markdown headers as universal fallback

Detect if the user mentions a target model and adjust delimiter style accordingly.

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
