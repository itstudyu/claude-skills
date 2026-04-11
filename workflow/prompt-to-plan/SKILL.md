---
name: prompt-to-plan
description: |
  Transform rough, informal user input into optimally structured prompts, then enter
  Plan Mode to create actionable implementation plans from the refined output.
  Use this skill whenever the user says "refine and plan", "clean up this prompt
  and make a plan", "turn this into a plan", "prompt to plan", "/prompt-to-plan",
  "refine this into a plan", "help me structure this and plan it",
  "프롬프트 정리하고 플랜 만들어줘", "이거 정리해서 계획 세워줘",
  "정리해서 플랜", "프롬프트 정리해줘",
  "プロンプト整理してプラン作って", "このアイデアを整理して実装計画を",
  "整理してプラン作って".
  Do NOT auto-trigger on every user message — only when prompt refinement + planning
  is explicitly requested.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - Edit
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

<HARD-GATE>
NEVER execute the user's original rough prompt directly. Always:
1. Analyze and structure into a refined implementation spec
2. Show the refined spec to the user
3. Get explicit approval before proceeding
4. Enter Plan Mode and create an implementation plan

The transformation step IS the value. Skipping it defeats the purpose.
Skipping Plan Mode defeats the purpose. Both gates are mandatory.
</HARD-GATE>

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

## Implementation-Focused Template

The canonical template adapted for implementation planning. Sections are tuned for
code implementation, not generic AI prompts.

### Full Template (Deep Tier)

```xml
<role>
[Domain expert persona with specific expertise.
 Include what perspective they bring and why they are suited for this task.]
</role>

<context>
[Background information needed for implementation:
 - Project state, tech stack, existing patterns
 - Codebase conventions and architecture
 - Target users or systems
 - Research findings from domain research step (if applicable)]
</context>

<task>
[Clear, specific implementation instruction.
 - One primary action verb (build, create, refactor, migrate)
 - What files to create or modify
 - Explicit scope: what to include AND what to exclude
 - Sequential phases as numbered list if multi-phase]
</task>

<constraints>
[Technical constraints with WHY each matters:
 - Framework/library requirements — compatibility reason
 - Performance targets — user experience or SLA reason
 - Testing requirements — quality gate reason
 - Coding standards — team convention reason]
</constraints>

<deliverables>
[Exact implementation artifacts expected:
 - Files to create: list with paths
 - Files to modify: list with paths
 - Tests: unit, integration, e2e as applicable
 - Documentation: if required
 - Definition of "done": what state indicates completion]
</deliverables>

<acceptance_criteria>
[Concrete scenarios that define "done":
 - "When user clicks X, Y should happen"
 - "API returns Z status code with payload format"
 - "Test coverage for new code exceeds 80%"
 - Include edge cases and error scenarios]
</acceptance_criteria>

[Final query restating the core implementation ask]
```

### Standard Tier

Omit `<acceptance_criteria>`. Use `<role>` only if domain expertise needed.

```xml
<role>[Only if domain expertise needed]</role>

<context>
[Condensed background — 2-4 sentences covering project state and tech stack]
</context>

<task>
[Clear implementation instruction with scope]
</task>

<constraints>
[2-4 key technical constraints with WHY]
</constraints>

<deliverables>
[Files to create/modify, tests, definition of done]
</deliverables>
```

### Lite Tier

```xml
<task>[Single clear implementation instruction]</task>
<deliverables>[Files and expected outcome]</deliverables>
```

## Domain Research Protocol (Deep Tier Only)

Only activate for Deep tier or when the user explicitly requests research.

1. Construct 2-3 WebSearch queries:
   - `"{domain} best practices {current_year}"`
   - `"{specific_task} implementation patterns"`
   - `"site:docs.anthropic.com {topic}"` or official docs for mentioned tools
2. Prioritize: official documentation > established tech blogs > conference talks > community forums
3. Extract actionable patterns and incorporate into `<context>` and `<constraints>`
4. Maximum 3 WebSearch calls — avoid analysis paralysis

### Domain-Specific Query Patterns

```
# Software Development
"{language} coding conventions official style guide"
"{framework} architecture patterns {year}"

# Web Frontend
"{framework} component design patterns {year}"
"{framework} state management best practices"

# Backend / API
"REST API design guidelines {year}"
"{database} query optimization guide"

# DevOps / Infrastructure
"{platform} deployment best practices"
"CI/CD pipeline {tool} configuration guide"

# AI / ML
"prompt engineering {model} best practices {year}"
"RAG implementation best practices {year}"
```

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

### Plan Document Header

```markdown
# [Feature Name] Implementation Plan

> **Refined from user prompt via /prompt-to-plan**

**Goal:** [One sentence from refined spec's <task>]
**Architecture:** [2-3 sentences from <context> and <constraints>]
**Tech Stack:** [Key technologies from <constraints>]

---
```

### Task Structure

Each task is bite-sized (2-5 minutes), following TDD:

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext`
- Test: `tests/exact/path/to/test.ext`

- [ ] **Step 1: Write the failing test**
```code
// 実際のテストコード
```

- [ ] **Step 2: Run test to verify it fails**
Run: `test command`
Expected: FAIL

- [ ] **Step 3: Write minimal implementation**
```code
// 実際の実装コード
```

- [ ] **Step 4: Run test to verify it passes**
Run: `test command`
Expected: PASS

- [ ] **Step 5: Commit**
```bash
git add <files>
git commit -m "feat: description"
```
````

### Plan Rules

- **No placeholders**: Every step contains actual code, commands, file paths
- **No "TBD"**: If you cannot specify something, investigate first
- **No "Similar to Task N"**: Repeat the code — tasks may be read in isolation
- **Spec coverage**: Every requirement from the refined spec maps to at least one task
- **Acceptance criteria**: Include verification steps that match `<acceptance_criteria>`

### Self-Review Before Presenting Plan

1. Skim each requirement in the refined spec — can you point to a task that implements it?
2. Search for placeholders (TBD, TODO, "implement later", "add appropriate")
3. Check type/method name consistency across tasks
4. Fix issues inline

### Execution Handoff

After the plan is complete:

> **Plan complete. Two execution options:**
>
> **1. Subagent-Driven (recommended)** — fresh subagent per task, review between tasks
>
> **2. Inline Execution** — execute tasks in this session with checkpoints
>
> **Which approach?**

- Subagent-Driven -> invoke subagent-dev skill
- Inline Execution -> execute tasks sequentially

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
