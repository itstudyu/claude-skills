---
name: project-scan
description: |
  Fast codebase overview for onboarding. Produces docs/project-overview.md covering
  structure, tech stack, features, database tables, and code patterns so humans and
  AI can get productive quickly. Use this skill whenever the user says "scan project",
  "project overview", "quick overview", "onboard me", "onboarding scan",
  "understand this codebase", "what does this project do", "プロジェクト把握",
  "プロジェクト概要", "프로젝트 파악", "프로젝트 빠른 파악", "신규 프로젝트 온보딩",
  "이 프로젝트 뭐야". Proactively suggest when docs/project-overview.md is missing
  and the user is about to start working on an unfamiliar codebase.
  For deep multi-axis analysis use /project-analyzer instead.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Write
---

# Project Scan

> **vs /project-analyzer**: project-scan is for a FAST overview + onboarding document. Use `/project-analyzer` for deep 6-axis analysis (tech/features/data/patterns/deps/architecture).

Analyze a codebase and produce a structured project overview document. The goal is
to give both humans and AI enough context to work productively in the project without
reading every file.

## When to Run

- First time opening a project
- Onboarding to an unfamiliar codebase
- Before making architectural decisions
- When docs/project-overview.md is missing or stale

## Step 0: Freshness Check

If `docs/project-overview.md` already exists:

```bash
# Count files changed since last scan
git diff --name-only $(git log -1 --format=%H -- docs/project-overview.md)..HEAD | wc -l
```

| Changed files | Action |
|---------------|--------|
| 0 | Up to date — skip scan, tell user |
| 1-10 | Offer incremental update (append changes only) |
| 11+ or 30+ days old | Recommend full rescan |

If the file doesn't exist, proceed to Step 1.

## Step 1: Project Detection

Determine whether this is an existing project or empty/new:

```bash
# Count source code files
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" \
  -o -name "*.go" -o -name "*.rb" -o -name "*.kt" -o -name "*.swift" \
  -o -name "*.rs" -o -name "*.php" -o -name "*.vue" -o -name "*.tsx" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" \
  -not -path "*/build/*" -not -path "*/__pycache__/*" | wc -l
```

- **1+ code files** → Existing project, proceed to Step 2
- **0 code files** → New project. Ask the user what they're building and what
  tech stack they plan to use. Create a starter overview with proposed structure.

## Step 2: Tech Stack Detection

Identify the primary technologies by checking for framework indicators:

| Check | Indicates |
|-------|-----------|
| `angular.json` or `@angular/core` in package.json | Angular |
| `next.config.*` or `next` in package.json | Next.js |
| `nuxt.config.*` | Nuxt.js |
| `vite.config.*` + `vue` in package.json | Vue + Vite |
| `manage.py` + `django` in requirements | Django |
| `app.py` or `main.py` + `flask` in requirements | Flask |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `build.gradle` or `pom.xml` | Java/Kotlin |
| `Gemfile` + `rails` | Ruby on Rails |
| `prisma/schema.prisma` | Prisma ORM |
| `typeorm` or `sequelize` in package.json | TypeORM / Sequelize |
| `docker-compose.yml` | Docker |
| `supabase/` directory | Supabase |

Also check: database type (PostgreSQL, MySQL, SQLite, MongoDB), CSS framework
(Tailwind, Bootstrap, SCSS), test framework, CI/CD config.

## Step 3: Directory Structure

Generate a tree of the main directories (skip node_modules, dist, build, .git):

```bash
find . -type d -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/__pycache__/*" \
  -maxdepth 3 | sort
```

For each major directory, note its purpose based on contents and naming.

## Step 4: Feature Detection

Identify features/modules by scanning:

- **Routes/pages:** Check router configs, page directories, URL patterns
- **API endpoints:** Check controller/route files for HTTP method handlers
- **Modules:** Check for feature modules, service files, domain directories
- **Database models:** Check ORM model files, migration files, schema files

Build a feature list with brief descriptions of what each does.

## Step 5: Data Model

If database schemas are found (Prisma schema, migrations, ORM models, SQL files):

- List all tables/collections
- Note columns/fields and types
- Identify relationships (FK, references)
- Note indexes if visible

If no schema files exist, note "No database schema detected" rather than guessing.

## Step 6: Code Patterns

Sample 3-5 representative files and identify:

- **Naming convention:** camelCase, PascalCase, snake_case
- **Import style:** named imports, default imports, path aliases
- **Error handling:** try/catch patterns, error boundary patterns
- **File organization:** colocated vs separated, barrel exports
- **Comment language:** English, Japanese, Korean, etc.

## Step 7: Generate Document

Create `docs/project-overview.md` using this template:

```markdown
# Project Overview

> Auto-generated by /project-scan on YYYY-MM-DD
> Re-run /project-scan to refresh after major changes

## Project Summary
- **Name:** [from package.json/go.mod/Cargo.toml or directory name]
- **Tech Stack:** [framework] + [language] + [database] + [ORM]
- **Description:** [from README or inferred from code]

## Directory Structure
[tree output with purpose annotations]

## Features
| Feature | Description | Key Files |
|---------|-------------|-----------|
| Login | User authentication with JWT | src/auth/ |
| Dashboard | Admin dashboard with charts | src/pages/dashboard/ |
| ... | ... | ... |

## Data Model
| Table | Key Columns | Relationships |
|-------|-------------|---------------|
| users | id, name, email, role_id | FK → roles |
| roles | id, name | |
| ... | ... | ... |

## Code Patterns
- **Naming:** camelCase for variables, PascalCase for components
- **Imports:** Path aliases (@/), named imports preferred
- **Error handling:** try/catch with custom error classes
- **Comments:** Japanese
- **Test files:** Colocated (*.spec.ts)

## Key Dependencies
| Package | Purpose | Version |
|---------|---------|---------|
| @angular/core | UI framework | 17.x |
| prisma | ORM | 5.x |
| ... | ... | ... |
```

## Step 8: Suggest Next Steps

After generating the document, suggest:

> "Project overview saved to `docs/project-overview.md`. Want me to create
> detailed design docs for each feature? I can generate them one at a time
> with `/design-doc`."

This is a suggestion only — don't auto-invoke design-doc.

## Important Notes

- Read files, don't guess. If something isn't detectable, say "not detected" rather
  than making assumptions.
- Keep the overview concise — it should be scannable in under 2 minutes.
- Commit the generated file so it's available to the whole team.
- The overview is a living document — suggest re-running after major changes.
