---
name: figma-common-mapper
description: |
  Present a pre-execution mapping preview to the user showing what will be updated,
  newly added, or skipped in angular-web-common. Waits for user confirmation before
  any code generation proceeds. Used by figma-component-writer agent as Phase 3.
  Not typically invoked directly.
---

# Figma Common Mapper

Present a clear, actionable preview of what the component sync will do, and get
explicit user confirmation before proceeding.

This is the human checkpoint — nothing gets generated without approval here.

## Input

`diff-report.json` — output from figma-common-diff

## Process

### Step 1 — Build Preview Table

Read the diff report and construct a visual summary:

```
┌──────────────────────────────────────────────────────────┐
│ Component Sync Preview                                   │
├──────────────────┬───────────┬───────────────────────────┤
│ Component        │ Status    │ Category → Action          │
├──────────────────┼───────────┼───────────────────────────┤
│ Button           │ ✏️ CHANGED │ buttons/ → Update styles  │
│ IconButton       │ ✏️ CHANGED │ buttons/ → Update styles  │
│ DatePicker       │ ✨ NEW     │ inputs/ → Create          │
│ StatusBadge      │ ✨ NEW     │ tags-badges/ → Create     │
│ TextInput        │ ⬜ SKIP   │ inputs/ → No changes      │
│ Checkbox         │ ⬜ SKIP   │ inputs/ → No changes      │
│ ... (8 more)     │ ⬜ SKIP   │ (unchanged)               │
└──────────────────┴───────────┴───────────────────────────┘

Summary:
  ✨ New:       2 components (DatePicker, StatusBadge)
  ✏️ Changed:   2 components (Button, IconButton)
  ⬜ Unchanged: 10 components (skipped)
  📁 New categories to create: tags-badges/
```

### Step 2 — Show Change Details

For each CHANGED component, show what specifically changed:

```
Button (CHANGED):
  - borderRadius: 4px → 8px
  - fill color: #2563EB → #1E40AF
  - Added variant: "text"

IconButton (CHANGED):
  - padding: 8px all → 12px all
```

### Step 3 — Show New Component Summary

For each NEW component, show what will be generated:

```
DatePicker (NEW → inputs/):
  - Variants: 2 sizes × 4 states
  - Files: date-picker.component.ts, .html, .scss, .spec.ts
  - Category: inputs/ (auto-detected from name)

StatusBadge (NEW → tags-badges/):
  - Variants: 5 colors × 2 sizes
  - Files: status-badge.component.ts, .html, .scss, .spec.ts
  - Category: tags-badges/ (NEW category, will be created)
```

### Step 4 — Ask for Confirmation

Present the summary and wait for user approval:

```
Proceed with sync?
  - 2 components will be UPDATED
  - 2 components will be CREATED
  - 10 components will be SKIPPED
  - 1 new category directory will be created

[Y/n]
```

Allow the user to:
- **Approve all** — proceed with everything
- **Exclude specific items** — "skip the Button update, only do new ones"
- **Change categories** — "put DatePicker in forms/ instead of inputs/"
- **Cancel** — abort entirely

### Step 5 — Generate Execution Plan

After approval, produce the confirmed execution plan:

```json
{
  "approved": true,
  "timestamp": "2026-03-26T00:00:00Z",
  "actions": [
    {"type": "UPDATE", "component": "Button", "category": "buttons", "changes": [...]},
    {"type": "CREATE", "component": "DatePicker", "category": "inputs", "spec": {...}},
    {"type": "CREATE", "component": "StatusBadge", "category": "tags-badges", "spec": {...}},
    {"type": "CREATE_CATEGORY", "category": "tags-badges"}
  ],
  "skipped": ["TextInput", "Checkbox", ...]
}
```

## Output

The execution plan JSON, which is consumed by the figma-component-writer agent's
Phase 4 (Code Generation).

## Important: No Silent Actions

- Never skip the preview. Even if there's only 1 change, show it.
- Never auto-approve. Always wait for explicit user confirmation.
- If the user modifies the plan (excludes items, changes categories), update the
  execution plan accordingly before proceeding.
