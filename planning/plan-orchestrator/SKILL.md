---
name: plan-orchestrator
description: |
  Automatically scan all available skills from all sources, match the relevant ones to
  the user's task, collect required context, apply coding standards, and generate a
  structured execution plan with dependency ordering and checkpoints. Use when the user
  says "plan-orchestrator", "plan this for me", "which skills should I use", "make a
  plan", "プラン作って", "어떤 스킬 쓰면 돼", "플랜 세워줘", or when a complex task
  would benefit from coordinated multi-skill execution. This skill is explicitly
  invoked — it does not auto-trigger.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
---

# Plan Orchestrator

Scan all available skills, match the right ones to the task, collect required context,
load coding standards and project patterns, generate a plan, and execute it step by step
after user approval.

## When to Use

Only when the user explicitly invokes this skill. It does not auto-trigger.
For simple tasks, direct `/skill-name` invocation is faster and preferred.

Use plan-orchestrator when:
- The task spans multiple concerns (design + code + test + review)
- The user isn't sure which skills to use
- The task needs coordinated execution across several skills

## Two-Tier Skill Loading (Token Efficiency)

### Tier 1: Skill Catalog (always loaded)

`skill-catalog.md` (project root) is the unified skill registry. It lists ALL
skills from ALL sources (gstack, claude-skills, custom packs) with one line each:

```
## gstack (source: ~/.claude/skills/gstack/)
| Skill | Path | Description | Tags |
|-------|------|-------------|------|
| review | review/ | Pre-landing PR review | #review #quality |
| qa | qa/ | QA test web app + fixes | #testing #browser |

## claude-skills (source: ./)
| Skill | Path | Description | Tags |
|-------|------|-------------|------|
| brainstorm | workflow/brainstorm/ | Socratic design process | #design #planning |
| figma-to-code | figma/figma-to-code/ | Figma → Angular code | #figma #agent |
```

This costs ~500 tokens for 30 skills. Even at 100 skills, ~1500 tokens.
Each skill has a **source** (gstack, claude-skills, etc.) for clear attribution.

If `skill-catalog.md` is missing, run `/skill-catalog scan` first.

### Tier 2: SKILL.md (loaded on demand)

After filtering candidates from Tier 1, read only the matched SKILL.md files
to understand their full capabilities. Use the **Path** column to locate each
SKILL.md. For gstack skills: `~/.claude/skills/gstack/<path>/SKILL.md`.
For project skills: `./<path>/SKILL.md`. Typically 5-7 skills per plan.

## Pipeline

### Phase 1: Understand the Task

Read the user's request carefully. Identify:
- **What** they want to build/fix/analyze
- **Scope** — single file, feature, full page, system-wide
- **Inputs** — Figma URL, error message, requirements doc, etc.
- **Constraints** — timeline, technology, quality requirements

Then execute the following sub-phases IN ORDER before proceeding to Phase 2.

#### 1a. Context Collection (HARD GATE)

**Do NOT proceed to Phase 2 until all relevant context is collected.**

Detect task signals in the user's request and check whether the required context
has been provided. If ANY relevant row is missing context, ask via AskUserQuestion.
Never guess. Always ask in the user's language.

| Task Signal | Required Context | Question if Missing |
|-------------|-----------------|---------------------|
| DB / table / CRUD / schema | Table DDL, column types, relationships (FK), indexes | "Provide the DDL or structure of the target table (columns, types, PK/FK)" |
| Data create / update / delete | Input fields, required vs optional, validation rules | "What fields and validation rules apply to this data?" |
| API call / integration | Endpoint URL, HTTP method, auth method, request/response format | "Provide the API endpoint, auth method, and request/response format" |
| Modify existing screen | Current screen URL or screenshot, target area to change | "Provide the URL or screenshot of the screen, and which area to modify" |
| New screen / page | Figma URL or wireframe, routing path | "Provide the design (Figma URL) and the routing path for this new screen" |
| Auth / permissions | Auth method (JWT/session/OAuth), role structure | "What auth method and role structure does this use?" |
| File upload / download | Allowed extensions, max size, storage location (S3/local) | "What are the allowed file types, max size, and storage location?" |
| External service integration | API docs URL, auth credential location, rate limits, error handling | "Provide the external API documentation URL and auth management approach" |
| Batch / scheduled job | Execution interval, data scope, retry strategy on failure | "What is the execution interval and failure handling strategy?" |
| Performance optimization | Current response time, target metric, bottleneck location | "What are the current and target performance metrics?" |

**Standards Gap Questions** — when standards define a rule but the project-specific
decision is not yet known:

| Standard Rule | Question if Not Determinable |
|---|---|
| No hardcoded values (#8) | "Where should config values be stored? (env vars / config file / DB / constants.ts)" |
| Branch naming (#7) | "Do you have a task/issue number for the branch name?" |
| Error handling (#10) | "What language for user-facing errors? Any error code system? (share existing pattern if any)" |
| Frontend: State management | "State management approach for this screen? (signals / NgRx / existing pattern?)" |
| Frontend: Design tokens | "Where is the design token file? Any theme variable naming convention?" |
| Frontend: Routing | "What routing path and are route guards needed?" |
| File structure | "Where should new files go? (share existing directory pattern)" |

**Logic:**
1. Detect task signal keywords in the user's request
2. Check whether the Required Context for each matching row is already provided
3. Read standards files and identify project-specific decisions that standards do not cover
4. **Everything NOT defined in standards MUST be asked** — never assume
5. Bundle all task-related + standards-gap questions into a single AskUserQuestion call
6. Only proceed to Phase 1b after ALL relevant items are resolved

**Compound tasks:** If multiple rows match, ask ALL related questions at once.

**Principle:** Follow standards rules as-is. For anything NOT covered by standards,
always confirm with the user. Never assume.

#### 1b. Standards Loading

Automatically identify which coding standards apply based on the task scope:

1. **Always read:** `standards/common/CODING-STANDARDS.md` (10 common rules)
2. **Frontend task — also read:** `standards/frontend/FRONTEND-STANDARDS.md`
   - Detection: Figma URL, component, screen, UI, CSS/SCSS, Angular keywords
3. **Backend task — also read:** `standards/backend/` (if it exists)
   - Detection: API, DB, server, migration, service keywords

Extract only the rules relevant to the current task:

```
Applicable Standards:
  ✓ Rule 1: File header (one-line English summary)
  ✓ Rule 2: Function max 30 lines
  ✓ Rule 5: Comments in Japanese
  ✓ Rule 8: No hardcoded values — use design tokens
  ✓ Frontend: OnPush change detection
  ✓ Frontend: SCSS only, BEM naming
  ✗ Rule 7: Branch naming — not applicable (no branching in this task)
```

#### 1c. Project Context Loading

If `project-context.md` exists, read it and extract:
- **Tech stack:** framework, language, DB, ORM
- **Directory structure:** where each type of file goes (services/, components/, etc.)
- **Existing patterns:** API call patterns, error handling patterns, state management
- **Shared components:** reusable components available in the project

If `project-context.md` does not exist:
1. Suggest to the user: "No project context file found. Run `/project-analyzer` to generate one?"
2. At minimum, run `ls src/` or equivalent to quickly identify directory structure

**Usage in plan:** When creating new files, always reference existing patterns:
- "Create order.service.ts following the pattern in user.service.ts"
- "Place in `/pages/order/` following the existing `/pages/user/` pattern"

#### 1d. Instincts Loading

Search `instincts/code-patterns/` and `instincts/errors/` for patterns related
to the current task:

1. Grep instincts files using task keywords
2. If matching patterns found, include them in plan as "Known Pitfalls"
3. Patterns with confidence >= 0.8: auto-include as warnings
4. Patterns with confidence 0.6-0.8: include as informational notes

```
Known Pitfalls (from instincts):
  ⚠️ [0.9] Angular standalone component missing OnPush → view not updating
  ⚠️ [0.8] Prisma relation not defined but include used → runtime error
  ℹ️ [0.6] FormControl without initial value → null error in template
```

If no instincts directory or no matching patterns exist, skip this step silently.

### Phase 2: Skill Matching

#### Step 2a — Tier 1 Scan (Skill Catalog)

Read `skill-catalog.md`. For each skill across ALL sources, check:
1. Do the tags match the task domain?
2. Does the description match the task intent?
3. Is the skill relevant to the identified scope?
4. Note the **source** for each candidate.

List all matched candidates WITH source:

```
Tier 1 Matches:
  ✓ [gstack] project-analyzer — #analysis — new project needs context
  ✓ [gstack] review — #review — PR diff analysis needed
  ✓ [claude-skills] figma-to-code — #figma #agent — Figma URL provided
  ✓ [claude-skills] brainstorm — #design #planning — explore design options
  ✗ [claude-skills] tdd — #testing — matched but figma-to-code has built-in validation
```

**Matching heuristics (starting points only):**

| Task Signal | Likely Skills (source) |
|---|---|
| New feature / page | project-analyzer [g] → brainstorm [cs] → write-plan [cs] → tdd [cs] → verify-complete [cs] |
| Figma URL + page | project-analyzer [g] → figma-to-code [cs] → review [g] |
| Figma URL + common | figma-component-writer [cs] |
| Bug / error | systematic-debug [cs] → tdd [cs] → verify-complete [cs] |
| Code review | review [g] → cso [g] |
| Performance issue | benchmark [g] → investigate [g] |
| New project | project-analyzer [g] → brainstorm [cs] → write-plan [cs] |
| Refactoring | brainstorm [cs] → write-plan [cs] → review [g] → verify-complete [cs] |

Legend: [g] = gstack, [cs] = claude-skills

Adjust based on the actual SKILL.md capabilities confirmed in Step 2b.

#### Step 2b — Tier 2 Read (HARD GATE)

**Do NOT skip this step.**

You MUST read the full SKILL.md of every Tier 1 matched candidate.
This step cannot be skipped for ANY reason — not "simple task", not "obvious
match", not "I already know what this skill does". No exceptions.

For each Tier 1 match:
1. **Read** the full SKILL.md file (use the Read tool)
2. **Confirm** the skill's Pipeline/Phases match the task
3. **Check** prerequisite skills (e.g., figma-to-code requires project-context.md)
4. **Note** inputs/outputs for dependency chaining in Phase 3

Report what you read:

```
Tier 2 Confirmed:
  ✓ project-analyzer — SKILL.md read ✓ — Generates project-context.md
  ✓ figma-to-code — SKILL.md read ✓ — Phase 1-6, requires project-context.md
  ✗ brainstorm — SKILL.md read ✓ — Not needed: Figma design already defines the UI
```

**If this step is skipped, the entire plan is INVALID. Do not proceed to Phase 3.**

### Phase 3: Generate Plan

**Call `EnterPlanMode` before writing the plan.**
The plan MUST be written to the plan file, NOT as chat text.

If EnterPlanMode is denied by the user, write the plan as structured markdown
in the chat — but always attempt plan mode first.

Produce a plan using this template:

```markdown
# Plan: [Task Title]

## Context
[Why this needs to be done — 2-3 lines]

## Collected Context
[From Phase 1a Context Collection]
- **Table:** users (id, name, email, role, created_at), roles (id, name)
- **API:** POST /api/users, JWT Bearer auth
- **Validation:** email required, name max 100 chars
- **Existing pattern:** HttpClient wrapper at `src/app/core/http.service.ts`

## Applicable Standards
[From Phase 1b Standards Loading]
| Rule | Description | Applies To |
|------|-------------|------------|
| Common #1 | File header — one-line English summary | All new files |
| Common #2 | Function max 30 lines | All functions |
| Common #5 | Comments in Japanese | All code |
| Common #8 | No hardcoded values | Colors, URLs, config |
| Frontend: OnPush | OnPush change detection | All components |
| Frontend: SCSS | SCSS only, BEM naming | All styles |

## Known Pitfalls
[From Phase 1d Instincts Loading — omit section if none found]
- ⚠️ Standalone component missing OnPush — view not updating
- ⚠️ FormControl without initial value — null error in template

## Skill Selection (from Tier 2 verification)

| Source | Skill | Selected | Reason |
|--------|-------|----------|--------|
| gstack | project-analyzer | ✓ | New project — context needed for downstream skills |
| claude-skills | figma-to-code | ✓ | Figma URL provided, Phase 1-6 pipeline matches task |
| claude-skills | brainstorm | ✗ | Figma design already defines UI — no need to explore options |
| claude-skills | verify-complete | ✓ | Final verification gate after code generation |

## Dependency
Step1 → Step2 → Step3
(use parallel notation: Step2 ∥ Step3)

## Steps

### Step 1: [Goal]
- **Skills:** project-analyzer [gstack]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Standards:** Common #1, #2, #5
- **Pattern ref:** (from project-context.md, if applicable)
- **Pitfall:** (from instincts, if applicable)
- **Files:** (discovered during execution)
- **Output:** project-context.md
- **Checkpoint:** Auto

### Step 2: [Goal]
- **Skills:** write-plan [claude-skills], tdd [claude-skills]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Standards:** Common #1, #2, #5, #8 + Frontend OnPush, SCSS
- **Pattern ref:** Follow existing `user-edit.component.ts` structure
- **Pitfall:** OnPush required, FormControl needs initial values
- **Files:** src/features/login/
- **Output:** Implementation + tests
- **Checkpoint:** User confirmation required

### Step 3: [Goal]
- **Skills:** review [gstack], cso [gstack]
- **Why this skill:** [1-line reason from Tier 2 confirmation]
- **Standards:** All applicable
- **Files:** (all changed files)
- **Output:** Review report
- **Checkpoint:** Auto

## Scope
- Out of scope: [what we're NOT doing]

## Verification
- [How to verify the plan succeeded]
```

### Phase 4: Present Plan & Get Approval

**Pre-presentation checklist (self-verify before presenting):**
- [ ] Phase 1a: All relevant task context collected? No missing information?
- [ ] Phase 1a: All standards-gap decisions confirmed with user?
- [ ] Phase 1b: Applicable standards identified and listed in plan?
- [ ] Phase 1c: project-context.md read and existing patterns referenced?
- [ ] Phase 1d: Instincts searched and relevant pitfalls included?
- [ ] Phase 2b: Every matched candidate's SKILL.md actually Read?
- [ ] Each Step's skills confirmed in Tier 2 (not just Tier 1 guesses)?
- [ ] Skill input/output dependencies chained correctly?
- [ ] Each Step has Standards + Pattern ref + Pitfall lines?

If any check fails → go back to the failed phase. Do not present an unverified plan.

**Call `ExitPlanMode` to request user approval.**
Do NOT ask "Proceed? [Y/n]" in chat text — ExitPlanMode handles the approval
workflow and lets the user review/edit the plan file before approving.
Do not start execution without explicit user approval via ExitPlanMode.

Allow the user to:
- Remove steps
- Add skills to steps
- Change checkpoint types
- Reorder steps
- Cancel entirely

### Phase 5: Execute

After approval, execute each step sequentially:

1. **Before each step:** Announce what's about to happen
2. **Invoke the skill(s):** Run the skill as if the user typed `/skill-name`
3. **At checkpoints (User confirmation):** Pause and ask for user confirmation
4. **After each step:** Report what was produced, mark as complete
5. **On failure:** Stop, report what failed, ask user how to proceed

Track progress visually:

```
Step 1: project-analyzer ✓ (completed — project-context.md generated)
Step 2: write-plan + tdd ◉ (in progress...)
Step 3: review + cso ○ (pending)
Step 4: verify-complete ○ (pending)
```

## Important Principles

1. **Explicit invocation only.** This skill never auto-triggers.
2. **Ask, don't assume.** If information is missing, ask. Never guess.
3. **Standards-aware.** Every plan references applicable coding standards.
4. **Pattern-aware.** New files follow existing project patterns.
5. **Pitfall-aware.** Past mistakes inform current plans.
6. **Show before doing.** Always present the plan and get approval.
7. **Respect checkpoints.** Never skip a user-confirmation checkpoint.
8. **Minimum viable plan.** Don't suggest 10 steps when 3 will do.
9. **Token-aware.** Use 2-tier loading. Don't read every SKILL.md upfront.
