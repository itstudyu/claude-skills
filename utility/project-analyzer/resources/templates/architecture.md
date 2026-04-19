# Template — architecture.md

Output schema for **Axis 6: Architecture Design Doc**.

This is the key document. It compresses all 5 category files into a
navigable design overview. Think of it as the blueprint that answers:
"How is this project built and why?"

## Output template

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

## Key Features Summary
| Feature | Entry Point | Core Logic | Data |
|---------|-------------|------------|------|
| Auth | routes/auth.ts:12 | services/auth.ts:18 | users, sessions |
| ...  | ... | ... | ... |

→ Details: features.md (sibling)

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

→ Details: data-model.md (sibling)

## Technical Decisions
[List architectural decisions you can infer from the code — not opinions,
but observable choices:]
- Monorepo / single repo: [which, based on directory structure]
- API style: REST / GraphQL / gRPC [based on route definitions]
- Auth strategy: JWT / session / OAuth [based on auth code]
- Deployment: [based on Docker/k8s/serverless configs]

→ Stack details: tech-stack.md (sibling)
→ Patterns: code-patterns.md (sibling)
→ Dependencies: dependencies.md (sibling)

## File Map
[Top-level directory tree with purpose annotations]
```
