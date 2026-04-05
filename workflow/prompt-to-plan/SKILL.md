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

Complete these steps in order:

1. **RECEIVE** — Accept the user's raw input verbatim
2. **DETECT LANGUAGE** — Identify the user's language, respond in the same language throughout
3. **ANALYZE** — Extract: core goal, domain, technical stack, scope, unstated assumptions, ambiguities
4. **TRIAGE** — Classify complexity as Lite / Standard / Deep, announce to user
5. **CLARIFY** — (Skip for Lite) Use Flipped Interaction pattern, max 3 questions
6. **RESEARCH** — (Deep only, or if user requests) WebSearch 2-3 queries for domain best practices
7. **BUILD** — Apply implementation-focused template, fill tier-appropriate sections
8. **PRESENT** — Show refined spec in code block with "What Changed" summary
9. **APPROVE** — Wait for explicit user approval. If changes requested, return to BUILD
10. **PLAN** — Call `EnterPlanMode`, write implementation plan following write-plan conventions

## Complexity Triage

Before doing anything, classify the input:

| Tier | Signal | Sections Used | Research? | Plan Depth |
|------|--------|---------------|-----------|------------|
| **Lite** | Single file change, clear intent | `task` + `deliverables` | No | 1-3 tasks |
| **Standard** | Multi-file, some ambiguity | `role` + `context` + `task` + `constraints` + `deliverables` | No (unless asked) | 4-10 tasks |
| **Deep** | Complex architecture, high stakes, ambiguous scope | All sections + `acceptance_criteria` | Yes | 10+ tasks, phased |

Announce the detected tier and let the user override:
"I classified this as **Standard**. Want me to do domain research and go deeper?"

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

## Plan Mode Transition (Step 10)

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
- Use CAPS LOCK emphasis in constraints (calm phrasing works better for Claude)
- Over-specify simple tasks (Lite tier exists for a reason)
- Add constraints the user never implied
- Assume English — always match the user's language
- Make specs longer just to fill sections — omit empty sections
- Add a role for Lite tier (unnecessary overhead)
- Research when user just wants quick structuring
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
