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
  source code. For a fast onboarding overview use /project-scan instead.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
---

# Project Analyzer

> **vs /project-scan**: project-analyzer performs DEEP 6-axis analysis with file/line evidence. Use `/project-scan` for a fast overview or onboarding document.

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

### Axis 1: Tech Stack (`tech-stack.md`)

Read config files and package manifests to identify exact versions and tools:

| What to detect | Where to look |
|----------------|---------------|
| Language + version | package.json engines, .python-version, go.mod, Cargo.toml |
| Framework + version | package.json dependencies, requirements.txt, go.mod |
| Database | docker-compose.yml, .env, ORM config, connection strings |
| ORM/ODM | prisma/schema.prisma, typeorm config, sequelize config |
| CSS framework | tailwind.config, package.json, imported stylesheets |
| Test framework | jest.config, vitest.config, pytest.ini, test files |
| Build tools | webpack.config, vite.config, tsconfig.json, Makefile |
| CI/CD | .github/workflows/, .gitlab-ci.yml, Jenkinsfile |
| Container | Dockerfile, docker-compose.yml, k8s manifests |
| Linting | .eslintrc, .prettierrc, ruff.toml, .golangci.yml |

Output format for `tech-stack.md`:

```markdown
# Tech Stack — [Project Name]

> Analyzed on YYYY-MM-DD
> Source: [project path]

## Core
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Language | TypeScript | 5.3.3 | tsconfig.json:3 |
| Framework | Angular | 17.2.0 | package.json:15 |
| ...      | ...       | ...     | ...         |

## Infrastructure
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Database | PostgreSQL | 16 | docker-compose.yml:8 |
| ...      | ...       | ...     | ...         |

## Dev Tools
| Category | Technology | Version | Config File |
|----------|-----------|---------|-------------|
| Linter | ESLint | 8.56.0 | .eslintrc.json:1 |
| ...      | ...       | ...     | ...         |
```

### Axis 2: Features (`features.md`)

Identify features by reading route definitions, API endpoints, service files,
and module structures. For each feature, trace the code path:

- Entry point (route/endpoint)
- Handler/controller
- Service/business logic
- Data access layer

```markdown
# Features — [Project Name]

> Analyzed on YYYY-MM-DD

## Feature: [Name]
- **Entry point:** `src/routes/auth.ts:12` — POST /api/auth/login
- **Controller:** `src/controllers/auth.controller.ts:25` — `login()`
- **Service:** `src/services/auth.service.ts:18` — `authenticate()`
- **Data access:** `src/repositories/user.repository.ts:10` — `findByEmail()`
- **Dependencies:** bcrypt (password hashing), jsonwebtoken (JWT generation)
- **Key logic:**
  - Validates email format (line 20-22)
  - Hashes password comparison (line 28)
  - Generates JWT with 24h expiry (line 35)
  - Stores refresh token in DB (line 42)

## Feature: [Name]
...
```

Read the actual function bodies. Report what the code does, not what you think
it should do.

### Axis 3: Data Model (`data-model.md`)

Read schema files, migration files, and ORM model definitions:

```markdown
# Data Model — [Project Name]

> Analyzed on YYYY-MM-DD

## Tables / Collections

### users
- **Source:** `prisma/schema.prisma:15-28`
- **Columns:**
  | Column | Type | Constraints | Notes |
  |--------|------|-------------|-------|
  | id | UUID | PK, auto-generated | |
  | email | String | unique, not null | indexed (line 20) |
  | password | String | not null | bcrypt hash |
  | role_id | UUID | FK → roles.id | cascade delete |
  | created_at | DateTime | default: now() | |

- **Relationships:**
  - belongs_to: `roles` via `role_id` (line 25)
  - has_many: `posts` (line 27)

- **Indexes:**
  - `@@index([email])` (line 28)

### [next table]
...

## ER Summary
[Describe relationships between tables as detected from FK constraints and
ORM relation decorators. Only include relationships you found in code.]
```

If no schema files exist, check for:
- Raw SQL in migration files
- ORM model decorators/annotations
- NoSQL collection usage in code

If nothing is found, write: "No database schema detected in source files."

### Axis 4: Code Patterns (`code-patterns.md`)

Read 5-10 representative files across different layers and document actual patterns:

```markdown
# Code Patterns — [Project Name]

> Analyzed on YYYY-MM-DD

## Naming Conventions
| Context | Pattern | Example | Source |
|---------|---------|---------|--------|
| Variables | camelCase | `userName` | src/services/user.ts:15 |
| Classes | PascalCase | `UserService` | src/services/user.ts:3 |
| Files | kebab-case | `user-service.ts` | src/services/ |
| DB columns | snake_case | `created_at` | prisma/schema.prisma:20 |

## Import Patterns
- Path aliases: `@/` maps to `src/` (tsconfig.json:8)
- Style: named imports preferred (`import { X } from '...'`)
- Example: `src/controllers/auth.controller.ts:1-5`

## Error Handling
- Pattern: [describe what you found]
- Example: `src/middleware/error.ts:10-25`
  ```typescript
  [actual code snippet from the file]
  ```

## File Organization
- [describe the actual structure you observed]
- Components: [colocated/separated] — evidence: [path]
- Tests: [colocated/separated] — evidence: [path]

## State Management (if frontend)
- Pattern: [what you found]
- Source: [file:line]

## Logging
- Library: [detected from imports]
- Pattern: [describe]
- Source: [file:line]
```

### Axis 5: Dependencies (`dependencies.md`)

Read package manifests and lock files for exact dependency information:

```markdown
# Dependencies — [Project Name]

> Analyzed on YYYY-MM-DD

## Production Dependencies
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| express | 4.18.2 | HTTP server | src/app.ts:1 |
| prisma | 5.8.0 | ORM | src/db/client.ts:1 |
| ...     | ...     | ...     | ...     |

## Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| jest | 29.7.0 | Unit testing |
| ...     | ...     | ...     |

## Dependency Health
- **Total production deps:** [count]
- **Total dev deps:** [count]
- **Lock file:** [yarn.lock / package-lock.json / pnpm-lock.yaml] present: [yes/no]
- **Outdated indicators:** [any pinned old major versions detected]

## Internal Dependencies (monorepo only)
| Package | Path | Depends On |
|---------|------|-----------|
| @app/core | packages/core | - |
| @app/web | packages/web | @app/core |
```

For the "Purpose" column, check how the package is actually imported and used
in the codebase — don't just guess from the package name.

### Axis 6: Architecture Design Doc (`architecture.md`)

This is the key document. It compresses all 5 category files into a navigable
design overview. Think of it as the blueprint that answers: "How is this project
built and why?"

```markdown
# Architecture Design Doc — [Project Name]

> Analyzed on YYYY-MM-DD
> This document summarizes the detailed analysis in sibling files.

## System Overview

**What it is:** [1-2 sentences based on what the code actually does]
**Stack:** [language] + [framework] + [database] + [key libraries]
**Source:** [project path]

## Architecture Layers

[Describe the actual layers found in the code. Example:]

```
┌─────────────────────────────────┐
│         Routes / Pages          │  src/routes/, src/pages/
├─────────────────────────────────┤
│     Controllers / Handlers      │  src/controllers/
├─────────────────────────────────┤
│       Services / Logic          │  src/services/
├─────────────────────────────────┤
│     Repositories / DAL          │  src/repositories/
├─────────────────────────────────┤
│        Database (PostgreSQL)    │  prisma/schema.prisma
└─────────────────────────────────┘
```

## Key Features Summary
| Feature | Entry Point | Core Logic | Data |
|---------|-------------|------------|------|
| Auth | routes/auth.ts:12 | services/auth.ts:18 | users, sessions |
| ...  | ... | ... | ... |

→ Details: [features.md](features.md)

## Data Flow
[Describe how data flows through the system based on what you read.
Trace 1-2 representative flows end-to-end.]

**Example: User Login**
1. `POST /api/auth/login` → `auth.controller.ts:25`
2. Validates input → `auth.service.ts:20`
3. Queries user → `user.repository.ts:10` → `users` table
4. Compares password hash → `auth.service.ts:28`
5. Generates JWT → `auth.service.ts:35`
6. Returns token → `auth.controller.ts:40`

## Data Model Overview
| Table | Key Columns | Relationships |
|-------|-------------|---------------|
| users | id, email, role_id | → roles, → posts |
| ...   | ... | ... |

→ Details: [data-model.md](data-model.md)

## Technical Decisions
[List architectural decisions you can infer from the code — not opinions,
but observable choices:]
- Monorepo / single repo: [which, based on directory structure]
- API style: REST / GraphQL / gRPC [based on route definitions]
- Auth strategy: JWT / session / OAuth [based on auth code]
- Deployment: [based on Docker/k8s/serverless configs]

→ Stack details: [tech-stack.md](tech-stack.md)
→ Patterns: [code-patterns.md](code-patterns.md)
→ Dependencies: [dependencies.md](dependencies.md)

## File Map
[Top-level directory tree with purpose annotations]
```

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
