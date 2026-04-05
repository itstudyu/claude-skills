# Project Analyzer -- Phase 0: Clarification Required

## Received Request

> "analyze the backend"

## Phase 0-1: Project Path -- MISSING

I need a project path to analyze. You said "the backend" but I don't know which project you're referring to. Please provide:

- The absolute path to the project (e.g., `/Users/yu_s/projects/my-app`)
- Or say "this project" / "current directory" if you want me to use the working directory

**Which project should I analyze?**

---

## Phase 0-3: Clarifying Ambiguity (Flipped Interaction)

Your request: "analyze the backend"

**My interpretation:**

1. **Project path:** Unknown -- you have not specified which project contains the backend. I need an explicit path before I can proceed.

2. **Scope:** Server-side code only (excluding frontend, tests, build scripts, and tooling). If your project is a monorepo, I would look for directories like `server/`, `backend/`, `api/`, `src/` (if it contains only server code), or similar.

3. **Depth:** Function-level analysis with call chains -- tracing each endpoint from route definition through controller, service, and data access layers.

4. **Focus:** All 6 axes within the backend scope:
   - **Tech Stack** -- language, framework, database, ORM, build tools, CI/CD
   - **Features** -- API endpoints, background jobs, integrations, traced end-to-end
   - **Data Model** -- tables/collections, relationships, indexes, migrations
   - **Code Patterns** -- naming, imports, error handling, file organization, logging
   - **Dependencies** -- production and dev packages, their actual usage in code
   - **Architecture** -- design doc summarizing all of the above

**Does this match your intent? Specifically, I need answers to these questions before proceeding:**

1. **Which project?** Please provide the full path to the codebase.
2. **What counts as "backend"?** Is it a standalone backend repo, or part of a monorepo? If monorepo, which directory contains the backend code?
3. **Any particular focus area?** Should I give equal weight to all 6 axes, or is there something specific you care about most (e.g., "how does auth work?", "what's the data model?", "what patterns does the code follow?")?

---

*I will not proceed until these questions are answered. Maximum 3 rounds of clarification, then analysis begins.*
