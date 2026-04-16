# Implementation-Focused Templates

> **Tag ordering rationale**: `<context>` and long data come first, the core
> query comes last. Anthropic docs confirm queries at the end can improve
> response quality by up to 30%. This ordering is intentional.

The canonical template adapted for implementation planning. Sections are tuned for
code implementation, not generic AI prompts.

## Full Template (Deep Tier)

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
 - Research findings from domain research step (if applicable)
 - Codebase scan findings: detected tech stack, relevant existing files,
   naming conventions, test patterns (auto-populated from project scan)]
</context>

<task>
[Clear, specific implementation instruction.
 - Why this task matters (1 sentence of motivation/background)
 - One primary action verb (build, create, refactor, migrate)
 - What to achieve (goals, not step-by-step procedure)
 - Explicit scope: what to include AND what to exclude
 - Reasoning guidance (Deep tier only): what tradeoffs to evaluate,
   what edge cases to consider, what architectural decisions to justify.
   Frame as outcomes ("evaluate X", "justify Y") not process ("think about X")]
</task>

<constraints>
[Technical constraints with WHY each matters:
 - Framework/library requirements — compatibility reason
 - Performance targets — user experience or SLA reason
 - Testing requirements — quality gate reason
 - Coding standards — team convention reason]
</constraints>

When writing constraints, prefer positive instructions over prohibitions:
- Instead of: "Do not use inline styles"
- Write: "Use CSS modules for all styling"

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

<examples> (optional — include when the task involves complex transformation,
classification, or format conversion that benefits from concrete demonstrations)
<example>
[Input → expected output pair showing the desired transformation]
</example>
</examples>

[Final query restating the core implementation ask]

<recap>
[Re-emphasize the 2-3 most critical constraints and the expected output format.
 Instructions closer to the end of a prompt are followed more strictly.
 Keep to 2-4 lines maximum.]
</recap>
```

## Standard Tier

Omit `<acceptance_criteria>`. Use `<role>` only if domain expertise needed.

```xml
<role>[Only if domain expertise needed]</role>

<context>
[Condensed background — 2-4 sentences covering project state and tech stack.
 Include codebase scan findings when available (tech stack, file layout, patterns).]
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

<recap>
[One-line restatement of the single most important constraint and expected outcome.]
</recap>
```

## Lite Tier

```xml
<task>[Single clear implementation instruction]</task>
<deliverables>[Files and expected outcome]</deliverables>
```
