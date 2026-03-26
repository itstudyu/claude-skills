---
name: figma-common-diff
description: |
  Compare crawled Figma components against the existing angular-web-common registry
  to classify each as NEW, CHANGED, or UNCHANGED. Used by figma-component-writer agent
  as Phase 2. Not typically invoked directly.
---

# Figma Common Diff

Compare crawled component specs against the current `angular-web-common/registry.json`
to determine what needs to be created, updated, or skipped.

## Input

1. `crawled-components.json` — output from figma-common-crawler
2. `angular-web-common/registry.json` — current component registry

## Process

### Step 1 — Load Registry

Read `angular-web-common/registry.json`. If it doesn't exist or is empty, treat
all crawled components as NEW.

### Step 2 — Match & Classify

For each crawled component:

1. **Find match in registry** — Match by name (case-insensitive, with fuzzy matching
   for slight name differences like "TextInput" vs "text-input")
2. **Compare style hash** — If a match exists, compare the crawled style hash against
   `registry.components[name].styleHash`
3. **Classify:**

| Condition | Classification |
|---|---|
| No match in registry | **NEW** |
| Match found, hash differs | **CHANGED** |
| Match found, hash identical | **UNCHANGED** |

### Step 3 — Generate Diff Details

For **CHANGED** components, produce a human-readable diff showing what changed:

```markdown
### Button (CHANGED)
- borderRadius: 4px → 8px
- fill[0]: #2563EB → #1E40AF
- padding.horizontal: 12px → 16px
- Added variant: "text"
```

For **NEW** components, show the full spec summary.

For **UNCHANGED** components, just list the name.

## Output

**`diff-report.json`:**

```json
{
  "timestamp": "2026-03-26T00:00:00Z",
  "summary": {
    "total": 15,
    "new": 3,
    "changed": 2,
    "unchanged": 10
  },
  "components": [
    {
      "name": "Button",
      "status": "CHANGED",
      "category": "buttons",
      "currentHash": "abc123...",
      "newHash": "def456...",
      "changes": [
        {"property": "borderRadius", "old": 4, "new": 8},
        {"property": "fills[0].color", "old": "#2563EB", "new": "#1E40AF"}
      ]
    },
    {
      "name": "DatePicker",
      "status": "NEW",
      "suggestedCategory": "inputs",
      "spec": { ... }
    },
    {
      "name": "TextInput",
      "status": "UNCHANGED",
      "category": "inputs"
    }
  ]
}
```

## Category Suggestion for NEW Components

When a component is NEW, suggest a category based on its name and properties:

| Name Pattern | Suggested Category |
|---|---|
| *Button*, *Btn* | buttons |
| *Input*, *TextField*, *Select*, *Dropdown*, *DatePicker*, *Checkbox*, *Radio* | inputs |
| *Card* | cards |
| *Modal*, *Dialog*, *Drawer* | modals |
| *Form*, *FieldGroup* | forms |
| *Nav*, *Menu*, *Breadcrumb*, *Tab*, *Sidebar* | navigation |
| *Table*, *List*, *Grid*, *DataView* | data-display |
| *Toast*, *Alert*, *Snackbar*, *Message* | feedback |
| *Layout*, *Container*, *Row*, *Col* | layout |
| *Icon* | icons |
| *Badge*, *Tag*, *Chip*, *Label* | tags-badges |
| *Spinner*, *Skeleton*, *Progress* | loading |

If no pattern matches, suggest "uncategorized" and flag for user decision.
