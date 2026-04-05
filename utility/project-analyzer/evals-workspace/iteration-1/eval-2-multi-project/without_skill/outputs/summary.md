# Summary: claude-skills vs superpowers

## One-line verdict
superpowers is the upstream general-purpose skill library; claude-skills is a project-specific extension layer built on top of it.

## Top 5 structural differences

1. **Platform scope**: superpowers supports 5+ platforms (Claude Code, Cursor, Codex, OpenCode, Gemini CLI); claude-skills is Claude Code only.

2. **Dependency model**: superpowers is self-contained; claude-skills requires gstack for core capabilities (browse, review, QA, ship, security).

3. **Automation depth**: claude-skills has 8 hook scripts with a profile system (minimal/standard/strict), auto-learning instincts, and 4 behavioral modes; superpowers has 1 session-start hook.

4. **Domain specificity**: claude-skills includes 5 Figma-to-Angular skills, Japanese comment enforcement, and Angular-specific coding standards; superpowers is framework-agnostic.

5. **Testing approach**: claude-skills bundles evals/evals.json inside each skill directory; superpowers has a separate tests/ directory with integration test scripts and prompt-based tests.

## Top 5 commonalities

1. Same SKILL.md format (frontmatter + markdown body + HARD-GATE tags + graphviz diagrams).
2. Same core workflow cycle: brainstorm -> plan -> execute (subagents) -> verify.
3. Same "fresh subagent per task + two-stage review" execution pattern.
4. Same TDD emphasis (RED-GREEN-REFACTOR as non-negotiable).
5. Same evidence-based verification requirement before declaring completion.

## Quantitative comparison

| Metric | claude-skills | superpowers |
|--------|--------------|-------------|
| Version | 1.0.0 | 5.0.6 |
| Total files | 67 | 138 |
| Skills (own) | 19 | 14 |
| Hook scripts | 8 | 1 |
| Test files | 0 (evals in skill dirs) | 30+ |
| Platform configs | 1 | 5 |
| Eval definitions | 19 evals.json | 0 |
| Agents | 0 | 1 |
| Pipeline skills | 7 | 0 |
| Figma skills | 5 | 0 |
