---
name: figma-component-writer
description: |
  Orchestrates the full Figma → angular-web-common component sync pipeline. Given a
  Figma component URL, crawls styles, compares against existing components, shows a
  preview to the user, and generates/updates Angular components after approval.
  Use when the user says "update common components from Figma", "sync Figma components",
  "create shared components from this Figma URL", or provides a Figma URL with intent
  to update the shared component library. This is for the SHARED LIBRARY (angular-web-common),
  not for page-specific code — use figma-to-code for that.
---

# Figma Component Writer

End-to-end orchestrator: Figma URL → crawl → diff → preview → user approval → code gen → registry update.

## Trigger

User provides a Figma component URL and wants to update the shared component library
(`angular-web-common`). Key phrases: "update common components", "sync Figma", "add
this to shared components", "공통 컴포넌트 업데이트".

## Prerequisites

- Figma MCP must be connected
- `angular-web-common/` repo must be accessible (check for `registry.json`)

If `angular-web-common/` is not found in the current directory or a known location,
ask the user for the path.

## Pipeline

### Phase 1: Crawl (figma-common-crawler)

Invoke figma-common-crawler with the provided Figma URL.
Output: `crawled-components.json`, `crawled-components.md`

### Phase 2: Diff (figma-common-diff)

Invoke figma-common-diff with crawled data + registry.
Output: `diff-report.json`

### Phase 3: Preview & Approval (figma-common-mapper)

Invoke figma-common-mapper to present the sync preview.
Output: confirmed execution plan (or user cancels)

**HARD GATE:** Do not proceed to Phase 4 without explicit user approval.

### Phase 4: Code Generation

For each approved action in the execution plan:

#### CREATE (New Component)

Generate a full Angular component in the target category:

```
angular-web-common/categories/{category}/
├── {component-name}.component.ts     ← standalone component, OnPush
├── {component-name}.component.html   ← template with variant support
├── {component-name}.component.scss   ← styles from Figma spec (design tokens)
└── {component-name}.component.spec.ts ← basic test
```

**Angular conventions:**
- Standalone components (no NgModules)
- OnPush change detection
- Input properties for variants (`@Input() size: 'sm' | 'md' | 'lg'`)
- SCSS using design tokens from `angular-web-common/categories/tokens/`
- Selector prefix: `awc-` (angular-web-common)

#### CREATE_CATEGORY (New Category Directory)

```
angular-web-common/categories/{category}/
└── _index.md   ← category metadata
```

#### UPDATE (Changed Component)

- Read the existing component files
- Apply only the changed style properties
- Do not touch component logic that wasn't affected
- Update the SCSS to reflect new Figma values

### Phase 5: Registry Update

After all code generation is complete:

1. **Update `registry.json`:**
   - Add new components with their style hashes
   - Update changed components with new hashes
   - Update `lastUpdated` timestamp

2. **Update `_index.md`** for each affected category:
   - Add new components to the component list
   - Update descriptions if changed

3. **Update `CLAUDE.md`** routing table if new categories were created

### Phase 6: Summary

Present the final summary to the user:

```
Component Sync Complete ✓

Created:
  ✨ DatePicker → inputs/date-picker.component.ts
  ✨ StatusBadge → tags-badges/status-badge.component.ts

Updated:
  ✏️ Button → buttons/button.component.scss (borderRadius, fills, new variant)
  ✏️ IconButton → buttons/icon-button.component.scss (padding)

New categories:
  📁 tags-badges/ (created with _index.md)

Registry: updated (4 components, 2 new hashes)
```

## Error Recovery

- If code generation fails for one component, continue with others and report the failure
- Never leave registry.json in an inconsistent state — update it only after successful generation
- If the user cancels mid-generation, report what was completed vs what was skipped
