# Audit Report — {{skill_name}}

> Generated {{date}} by `skill-auditor`.
> Rubric version: {{rubric_version}}
> Source: {{skill_path}}

## Frontmatter Excerpt

```yaml
{{frontmatter_verbatim}}
```

## Score

**{{score}}** ({{classification}}) — {{pass_count}} Pass / {{warn_count}} Warn / {{fail_count}} Fail / {{skip_count}} Skip

| Axis | Items | Pass | Warn | Fail | Skip |
|------|-------|------|------|------|------|
| A — Frontmatter | 4 | {{A_pass}} | {{A_warn}} | {{A_fail}} | {{A_skip}} |
| B — Description | 4 | {{B_pass}} | {{B_warn}} | {{B_fail}} | {{B_skip}} |
| C — Body Structure | 5 | {{C_pass}} | {{C_warn}} | {{C_fail}} | {{C_skip}} |
| D — Project Conventions | 4 | {{D_pass}} | {{D_warn}} | {{D_fail}} | {{D_skip}} |

## Per-Item Findings

Findings are grouped by axis. Each entry shows the rubric id, verdict,
evidence (file:line snippet), and the canonical source quote the rule
derives from.

### Axis A — Frontmatter Compliance

{{#each axis_A_findings}}
#### {{id}}. {{name}} — **{{verdict}}**

- **Evidence:** `{{file}}:{{line}}` — {{excerpt}}
- **Source:** {{source_url}} — "{{source_quote}}"
- **Risk:** {{risk}}
{{#if recommendation}}
- **Recommendation:** {{recommendation}}
{{/if}}

{{/each}}

### Axis B — Description Quality

{{#each axis_B_findings}}
#### {{id}}. {{name}} — **{{verdict}}**

- **Evidence:** `{{file}}:{{line}}` — {{excerpt}}
- **Source:** {{source_url}} — "{{source_quote}}"
- **Risk:** {{risk}}
{{#if recommendation}}
- **Recommendation:** {{recommendation}}
{{/if}}

{{/each}}

### Axis C — Body Structure

{{#each axis_C_findings}}
#### {{id}}. {{name}} — **{{verdict}}**

- **Evidence:** `{{file}}:{{line}}` — {{excerpt}}
- **Source:** {{source_url}} — "{{source_quote}}"
- **Risk:** {{risk}}
{{#if recommendation}}
- **Recommendation:** {{recommendation}}
{{/if}}

{{/each}}

### Axis D — Project Conventions

{{#each axis_D_findings}}
#### {{id}}. {{name}} — **{{verdict}}**

- **Evidence:** `{{file}}:{{line}}` — {{excerpt}}
- **Source:** {{source_url}} — "{{source_quote}}"
- **Risk:** {{risk}}
{{#if recommendation}}
- **Recommendation:** {{recommendation}}
{{/if}}

{{/each}}

## Top-3 Upgrade Recommendations

Sorted by risk (high → low), then axis (A → D). Fails first, then Warns.

1. **{{rec_1_id}}** ({{rec_1_risk}}) — {{rec_1_summary}} → See `upgrade-playbook.md#{{rec_1_id}}`
2. **{{rec_2_id}}** ({{rec_2_risk}}) — {{rec_2_summary}} → See `upgrade-playbook.md#{{rec_2_id}}`
3. **{{rec_3_id}}** ({{rec_3_risk}}) — {{rec_3_summary}} → See `upgrade-playbook.md#{{rec_3_id}}`

## Next Steps

To apply these recommendations, invoke `skill-auditor` in **UPGRADE** mode:

> "Upgrade {{skill_name}}"

UPGRADE will walk through each finding with a before/after diff and
request per-item approval before editing.
