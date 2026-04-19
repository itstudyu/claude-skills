# Workflow Blueprint — Edge Cases and Anti-patterns

Reference loaded by `workflow-blueprint` SKILL.md. Covers corner cases
encountered during tracing and the drift patterns to refuse.

## Contents

- Edge cases table
- Anti-patterns

## Edge cases

| Case | Handling |
|------|---------|
| No entry points found | Report "No entry points detected" with list of files scanned |
| Dynamic routing (e.g., `app.use(router)`) | Trace router file imports to find actual routes |
| Decorator-based routing | Read decorator metadata to extract paths and methods |
| Abstract/interface services | Follow to concrete implementation, document both |
| Multiple DB connections | Note which connection each query uses |
| ORM query builders | Read the builder chain to determine the actual query |
| No DB (pure computation) | Omit "Data Touched" section, note "No database interaction" |
| Monorepo with multiple services | Ask user which service to analyze, or analyze each separately |
| Frontend-only project | Trace: Component → Hook/Store → API Client → External API |
| Very large codebase (100+ endpoints) | Discover all, ask user to select subset, analyze in batches |

## Anti-patterns

Long analyses drift toward plausible-but-unfounded claims. Refuse these:

- **Do NOT invent participants you did not read.** Every diagram box must
  trace to a file:line you opened. Mark untraced dispatch as
  `(not traced — indirect dispatch)` rather than drawing the arrow — a
  hallucinated shape misleads more than an incomplete one.
- **Do NOT infer call order from framework conventions.** Read the actual
  calling function; conventions drift per project (e.g. Express
  middleware order follows `app.use` sequence, not defaults).
- **Do NOT collapse conditional branches into a single arrow.** If the
  controller dispatches differently for authenticated vs anonymous users,
  draw two arrows. Collapsing loses the decision the diagram exists to
  show.
