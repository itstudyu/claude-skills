---
name: project-analyzer
description: |
  Analyze an existing project's structure, framework, conventions, dependencies, and test
  infrastructure. Generates a standardized project-context.md that other skills consume.
  Use when starting work on an unfamiliar codebase, onboarding to a project, or when
  another skill (plan-orchestrator, figma-to-code) needs project context that doesn't
  exist yet. Trigger on "analyze this project", "what framework is this", "project overview",
  "onboard me", or when a skill requests project-context.md and none is found.
---

# Project Analyzer

Produce a comprehensive, machine-readable project context document so that you — and
every other skill in the system — can work effectively in this codebase without
re-discovering the same facts over and over.

The output file (`project-context.md`) has a fixed structure. Other skills depend on
its section headings, so the format matters.

## When to Run

- First time working in a project
- When `project-context.md` is missing or stale (>30 days since last update)
- When a downstream skill (plan-orchestrator, figma-to-code, brainstorm) asks for
  project context and none exists

If `project-context.md` already exists in the project root or `.claude/`, read it
first. Ask the user whether to regenerate or just update the parts that changed.

## Analysis Phases

Work through these phases in order. Each phase produces a section in the output.

### Phase 1 — Framework & Language Detection

Scan the project root for configuration files. Stop at the first match in each
category — don't exhaustively search nested directories.

| Signal File | Framework / Language |
|---|---|
| `angular.json`, `.angular-cli.json` | Angular |
| `next.config.*` | Next.js |
| `nuxt.config.*` | Nuxt |
| `vite.config.*`, `vue.config.*` | Vue |
| `package.json` (react dep) | React |
| `pom.xml`, `build.gradle*` | Java (Maven / Gradle) |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `requirements.txt`, `pyproject.toml`, `setup.py` | Python |
| `Gemfile` | Ruby |
| `*.csproj`, `*.sln` | .NET |

Read `package.json` (or equivalent) for the exact versions of key dependencies.
Note the package manager (`package-lock.json` → npm, `yarn.lock` → yarn,
`pnpm-lock.yaml` → pnpm, `bun.lockb` → bun).

### Phase 2 — Directory Structure

Run `find . -type d -maxdepth 3` (excluding node_modules, .git, dist, build, __pycache__,
.next, .angular) to get the directory tree. Identify:

- **Source root** — where application code lives (src/, app/, lib/)
- **Component directories** — where UI components are organized
- **Service/API directories** — where business logic or API routes live
- **Config directories** — environment configs, deploy configs
- **Asset directories** — static files, images, fonts

Record the pattern: is it feature-based (`features/login/`), layer-based
(`components/`, `services/`), or domain-based (`modules/auth/`)?

### Phase 3 — Dependency Analysis

Read the dependency manifest and classify dependencies:

- **UI framework** — Angular, React, Vue, etc.
- **Component library** — PrimeNG, Material, Ant Design, etc.
- **State management** — NgRx, Redux, Vuex, Zustand, etc.
- **HTTP client** — HttpClient, Axios, fetch wrapper, etc.
- **CSS approach** — SCSS, Tailwind, CSS Modules, styled-components, etc.
- **Build tool** — Webpack, Vite, esbuild, Angular CLI, etc.
- **Notable utilities** — date libs, validation, i18n, etc.

Don't list every dependency — focus on the ones that shape how code is written.

### Phase 4 — Coding Conventions

Look for these files and summarize what they enforce:

| File | Convention |
|---|---|
| `.eslintrc*`, `eslint.config.*` | Linting rules |
| `.prettierrc*` | Formatting |
| `tsconfig.json` | TypeScript strictness, paths, target |
| `.editorconfig` | Indent style, line endings |
| `stylelint*` | CSS/SCSS rules |
| `.angular/` | Angular-specific config |
| `CLAUDE.md` | AI-specific project instructions |

Also sample 2-3 existing source files to detect unwritten conventions:
- Naming patterns (camelCase, kebab-case for files?)
- Import ordering
- Comment language (English, Japanese, etc.)
- Component patterns (standalone vs NgModule, class vs functional)

### Phase 5 — Component & Service Inventory

For frontend projects, count and list the top-level components:
```bash
find src -name "*.component.ts" -o -name "*.tsx" -o -name "*.vue" | head -30
```

For backend projects, list services/controllers:
```bash
find src -name "*.service.ts" -o -name "*Controller.*" -o -name "*_handler.*" | head -30
```

Don't list every file — list the top 30 and the total count. Group by directory
if there are more than 20.

### Phase 6 — Test Infrastructure

Detect test framework and configuration:

| Signal | Framework |
|---|---|
| `jest.config.*`, `package.json` jest field | Jest |
| `karma.conf.*` | Karma |
| `jasmine.json` | Jasmine |
| `cypress.config.*`, `cypress/` | Cypress |
| `playwright.config.*` | Playwright |
| `pytest.ini`, `conftest.py` | pytest |
| `*_test.go` | Go testing |
| `src/test/` (Java) | JUnit |

Note:
- Test file naming pattern (`*.spec.ts`, `*.test.ts`, `*_test.go`)
- Test directory location (colocated vs separate `test/` directory)
- Coverage configuration if present
- E2E vs unit test separation

## Output Format

Write `project-context.md` to the project root (or `.claude/project-context.md` if
`.claude/` exists). Use this exact structure — downstream skills parse these headings:

```markdown
# Project Context

> Generated by project-analyzer on YYYY-MM-DD

## Framework & Language
- **Primary:** Angular 17 (TypeScript 5.3)
- **Package Manager:** npm (package-lock.json)
- **Node Version:** 20.x (from .nvmrc)

## Directory Structure
- **Source root:** src/
- **Organization:** feature-based (src/app/features/)
- **Components:** src/app/features/*/components/
- **Services:** src/app/core/services/
- **Assets:** src/assets/

## Key Dependencies
- **UI Library:** PrimeNG 17.x
- **State:** NgRx 17.x
- **HTTP:** Angular HttpClient
- **CSS:** SCSS + PrimeNG theme
- **Build:** Angular CLI (@angular-devkit/build-angular)

## Coding Conventions
- **Linter:** ESLint (Angular preset)
- **Formatting:** Prettier (2-space indent, single quotes)
- **TypeScript:** strict mode, path aliases (@app/*, @core/*)
- **Components:** standalone (no NgModules)
- **Comments:** Japanese
- **File naming:** kebab-case

## Component Inventory
- **Total components:** 47
- **By feature:** auth (5), dashboard (8), settings (4), ...
- **Shared/common:** 12 components in src/app/shared/

## Test Infrastructure
- **Framework:** Jest (via @angular-builders/jest)
- **Pattern:** *.spec.ts (colocated)
- **E2E:** Cypress (cypress/)
- **Coverage:** configured (threshold: 80%)
```

The example above is illustrative — adapt the content to what you actually find.
Sections with nothing to report should say "Not detected" rather than being omitted,
because downstream skills check for heading presence.

## Important Principles

1. **Read, don't guess.** Open the actual config files. Don't infer "probably uses
   Jest" from the framework — check.

2. **Be specific about versions.** "Angular" is not useful. "Angular 17.3.2" is.

3. **Note what's absent too.** If there's no linter, no tests, no CI — say so.
   That's valuable context for other skills.

4. **Don't modify anything.** This skill is read-only. It produces one output file
   and touches nothing else.

5. **Keep it scannable.** The output is consumed by both humans and AI. Use bullet
   points, not paragraphs. One fact per line.
