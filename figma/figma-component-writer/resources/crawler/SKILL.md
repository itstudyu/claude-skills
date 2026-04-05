---
name: figma-common-crawler
description: |
  Crawl a Figma component URL via Figma MCP and extract all styles, variants, and
  properties into a standardized component spec. Used by figma-component-writer agent
  as Phase 1. Not typically invoked directly — called as part of the component writer pipeline.
---

# Figma Common Crawler

Extract all design data from a Figma component URL and normalize it into a standard
component spec format that downstream skills can consume.

## Input

A Figma URL pointing to a component, component set, or page containing components.

## Process

### Step 1 — Resolve the Figma URL

Use Figma MCP to access the file. Extract the file key and node IDs from the URL.

### Step 2 — Extract Component Data

For each component (or component set) found at the URL:

1. **Name & hierarchy** — Component name, parent frame, page
2. **Properties / Variants** — All variant properties and their values
   (e.g., `size: [sm, md, lg]`, `state: [default, hover, active, disabled, focus]`)
3. **Visual properties:**
   - Fill colors (hex + opacity)
   - Stroke colors, widths, styles
   - Border radius values
   - Shadow effects (x, y, blur, spread, color)
   - Typography (font family, size, weight, line height, letter spacing)
   - Padding / spacing (auto-layout properties)
   - Width/height constraints
4. **Auto-layout rules** — Direction, gap, padding, alignment, sizing behavior
5. **Children** — Nested layers and their properties (recursive, max depth 3)

### Step 3 — Normalize to Standard Format

Output each component as a JSON object:

```json
{
  "name": "Button",
  "figmaId": "1234:5678",
  "figmaUrl": "https://...",
  "variants": {
    "size": ["sm", "md", "lg"],
    "variant": ["primary", "secondary", "text"],
    "state": ["default", "hover", "active", "disabled", "focus"]
  },
  "styles": {
    "fills": [{"color": "#1E40AF", "opacity": 1}],
    "strokes": [],
    "borderRadius": 8,
    "shadows": [],
    "typography": {
      "fontFamily": "Noto Sans JP",
      "fontSize": 14,
      "fontWeight": 500,
      "lineHeight": 1.5,
      "letterSpacing": 0
    },
    "padding": {"top": 8, "right": 16, "bottom": 8, "left": 16},
    "gap": 8
  },
  "children": []
}
```

### Step 4 — Generate Style Hash

For each component, compute a deterministic hash of its style properties (fills,
strokes, borderRadius, shadows, typography, padding). This hash is used by
`figma-common-diff` to detect changes without reading full component files.

Hash algorithm: sort all style keys, serialize to JSON, SHA-256 first 12 chars.

## Output

Two files written to a temp directory or the current working directory:

1. **`crawled-components.json`** — Machine-readable array of all component specs
2. **`crawled-components.md`** — Human-readable summary table:

```markdown
# Crawled Components

| # | Component | Variants | Colors | Typography | Has Shadow |
|---|-----------|----------|--------|-----------|------------|
| 1 | Button | 3 sizes × 3 variants × 5 states | #1E40AF, #FFF | Noto Sans JP 14/500 | No |
| 2 | TextInput | 2 sizes × 4 states | #374151, #E5E7EB | Noto Sans JP 14/400 | Yes |

Total: 15 components, 47 unique variants
```

## Error Handling

- If Figma MCP is not available → tell the user to connect the Figma MCP server
- If URL is invalid or node not found → report which part failed, ask user to verify URL
- If a component has no style data → include it with empty styles, note in the summary
