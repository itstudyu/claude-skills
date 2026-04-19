---
name: project-analyzer
description: |
  Deep fact-based 6-axis analysis of one or more codebases — tech stack, features,
  data model, code patterns, dependencies, and architecture. Every claim traces back
  to a file/line. Supports cross-project comparison. Use this skill whenever the user
  says "deep project analysis", "project analysis", "analyze projects", "compare
  projects", "deep dive into this codebase", "tell me exactly what this project does",
  "프로젝트 깊이 분석", "코드베이스 깊이 분석", "프로젝트 비교", "프로젝트 상세 분석",
  "プロジェクト詳細分析", "コードベース詳細分析", "プロジェクト比較". Proactively suggest
  when the user asks questions about project internals that require reading actual
  source code.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
---

# Project Analyzer

Deep, fact-based analysis of one or multiple codebases. Every claim must trace back
to a file you actually read. If you cannot verify something from source, say
"not detected" — never guess.

<HARD-GATE>
Every statement in the output must reference the file and line where you found it.
Do NOT write anything you did not read from the actual codebase. No assumptions,
no generalizations, no "typically this framework does X". Facts only.
</HARD-GATE>

## Phase 0: Input & Clarification

### 0-1. Receive project paths

Accept one or more project paths from the user. They may say:
- A single path: `/Users/me/projects/app`
- Multiple paths: `/Users/me/projects/app1` and `/Users/me/projects/app2`
- A vague reference: "this project", "the current directory"

### 0-2. Validate paths

For each path, verify it exists and contains source code:

```bash
ls <path>
find <path> -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" \
  -o -name "*.go" -o -name "*.rb" -o -name "*.kt" -o -name "*.swift" \
  -o -name "*.rs" -o -name "*.php" -o -name "*.vue" -o -name "*.tsx" \
  -o -name "*.jsx" -o -name "*.cs" -o -name "*.cpp" -o -name "*.c" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
  -not -path "*/build/*" -not -path "*/__pycache__/*" | wc -l
```

If a path does not exist or has 0 source files, tell the user and ask for correction.

### 0-3. Clarify ambiguity (Flipped Interaction)

If anything is unclear, propose your interpretation and ask for confirmation.
Do NOT proceed with assumptions. Examples:

```
Your request: "analyze the backend"

My interpretation:
- Scope: server-side code only (excluding frontend, tests, scripts)
- Depth: function-level analysis with call chains
- Focus: all 6 axes (structure, stack, features, data model, patterns, dependencies)

Does this match? Anything to adjust?
```

Rules:
- Maximum 3 rounds of clarification
- Each question structured as "I think you mean X — correct?"
- If the user's question targets a specific area (e.g., "how does auth work?"),
  focus the analysis on that area but still cover all 6 axes within that scope
- Continue asking until you are confident about: scope, depth, and focus areas

## Phase 1: Confirm Save Location

Before writing any files, ask the user where to save the output:

```
I'll generate these analysis files:
- tech-stack.md
- features.md
- data-model.md
- code-patterns.md
- dependencies.md
- architecture.md (design doc — compressed summary of all categories)
[If multiple projects: + comparison.md]

Where should I save them?
Default: <project-root>/docs/analysis/

OK to proceed with this location?
```

Wait for explicit confirmation before writing.

## Phase 2: Per-Project Deep Analysis

For each project, analyze these 6 axes. Read files directly — do not rely on
file names alone or make assumptions based on framework conventions.

Each axis has a full output-format template in `resources/templates/`.
Read the template before you write the corresponding file — it defines the
exact sections, columns, and evidence format the user expects.

| Axis | What to read | Output template |
|------|--------------|-----------------|
| 1 Tech Stack | package.json / tsconfig / Dockerfile / CI configs / lockfiles | [resources/templates/tech-stack.md](resources/templates/tech-stack.md) |
| 2 Features | routes, controllers, services, data access layers | [resources/templates/features.md](resources/templates/features.md) |
| 3 Data Model | schema files, migrations, ORM model decorators | [resources/templates/data-model.md](resources/templates/data-model.md) |
| 4 Code Patterns | 5–10 representative files across layers | [resources/templates/code-patterns.md](resources/templates/code-patterns.md) |
| 5 Dependencies | package manifests + lock files + actual imports | [resources/templates/dependencies.md](resources/templates/dependencies.md) |
| 6 Architecture | synthesis of axes 1–5 | [resources/templates/architecture.md](resources/templates/architecture.md) |

### Axis-specific notes

**Axis 1 — Tech Stack**: detect exact versions + the config file/line where each
value is declared. No guessing from filenames; open the config.

**Axis 2 — Features**: for each feature, trace the full code path (entry →
controller → service → data access) and quote the actual function behavior.
Report what the code does, not what you think it should do.

**Axis 3 — Data Model**: if no schema files exist, fall back to raw SQL in
migrations, ORM decorators, or NoSQL collection usage. If nothing is found,
write `"No database schema detected in source files."`

**Axis 4 — Code Patterns**: include actual code snippets from the file, not
paraphrases. Document what you observed across the 5–10 files you read.

**Axis 5 — Dependencies**: for the "Purpose" column, check how the package is
actually imported and used — not the package description.

**Axis 6 — Architecture**: this is a synthesis document. Do not invent
architectural claims — compress what axes 1–5 already established, with
pointers back to the detail files.

## Phase 3: Category Document Generation

Write each axis to its own file in the confirmed save location.
Order of writing:

1. `tech-stack.md` — fastest, config files only
2. `dependencies.md` — package manifest reading
3. `data-model.md` — schema files
4. `code-patterns.md` — sample file reading
5. `features.md` — deepest analysis, traces code paths
6. `architecture.md` — last, because it references all others

For each file, include the analysis date and source project path in the header.

## Phase 4: Cross-Project Comparison (Multiple Projects Only)

If 2+ projects were analyzed, generate `comparison.md`:

```markdown
# Cross-Project Comparison

> Analyzed on YYYY-MM-DD
> Projects: [list of project names and paths]

## Stack Comparison
| Aspect | [Project A] | [Project B] | Notes |
|--------|-------------|-------------|-------|
| Language | TypeScript 5.3 | Python 3.12 | |
| Framework | Angular 17 | FastAPI 0.109 | |
| Database | PostgreSQL 16 | PostgreSQL 16 | Same DB engine |
| ORM | Prisma 5.8 | SQLAlchemy 2.0 | |
| Test | Jest 29 | pytest 8.0 | |

## Structural Comparison
| Aspect | [Project A] | [Project B] |
|--------|-------------|-------------|
| Architecture | Layered MVC | Hexagonal |
| API style | REST | REST + GraphQL |
| File count | 245 | 189 |
| Directory depth | 4 levels | 3 levels |

## Shared Patterns
[List patterns that appear in both/all projects]

## Divergent Patterns
[List patterns that differ, with specific file references]

## Shared Dependencies
| Package | [Project A] Version | [Project B] Version |
|---------|--------------------|--------------------|
| express | 4.18.2 | 4.19.0 |

## Data Model Overlap
[Any shared or similar table structures]
```

Only include facts observed in both codebases. Do not speculate about
why differences exist unless the code explicitly documents it.

## Phase 5: Output Summary

After all files are written, present a summary to the user:

```
Analysis complete. Files saved to [location]:

[Project Name]
├── tech-stack.md       (X technologies detected)
├── features.md         (X features traced)
├── data-model.md       (X tables/collections documented)
├── code-patterns.md    (X files sampled)
├── dependencies.md     (X production + X dev dependencies)
├── architecture.md     (design doc — start here)
[└── comparison.md      (cross-project comparison)]

Start with architecture.md for the full picture.
Questions about any specific area?
```

## Answering User Questions

After the initial analysis, the user may ask follow-up questions about the
project(s). When answering:

1. **Re-read the relevant source files** — do not answer from memory of the
   analysis documents. The code may have changed, or you may need deeper detail.
2. **Cite file:line** for every claim
3. **If the answer requires reading files you haven't read yet**, read them
   before answering — never say "based on the typical behavior of X framework"
4. **If you cannot find the answer in the code**, say so explicitly:
   "I could not find evidence of X in the source files I examined."

## Key Principles

- **Facts only.** Every statement traces to file:line. "Not detected" > guessing.
- **Ask, don't assume.** Use Flipped Interaction when scope is unclear.
- **User controls save location.** Never write without confirmation.
- **Depth over speed.** Read function bodies, trace call chains, check actual usage.
- **Category separation.** Keep documents focused — the design doc ties them together.
- **Living analysis.** Suggest re-running when the user makes significant changes.
