---
name: figma-to-code
description: |
  Convert a Figma design URL into production-ready Angular frontend code. Always checks
  angular-web-common for reusable components first — maps common components and only
  styles individually what isn't already shared. Shows the user a mapping preview before
  generating code. Use when the user provides a Figma URL and wants to build a page or
  screen. Trigger on "Figma URL + implement", "build this page from Figma", "피그마 구현",
  "Figmaから実装". This is for PAGE/SCREEN code, not shared components — use
  figma-component-writer for the shared library.
---

# Figma to Code

Convert a Figma design into Angular code, maximizing reuse of shared components from
`angular-web-common`.

## Trigger

User provides a Figma URL with intent to build a page, screen, or feature UI.
Distinct from figma-component-writer which updates the shared library.

## Prerequisites

- Figma MCP must be connected
- `project-context.md` should exist (run `/project-analyzer` first if missing)
- `angular-web-common/registry.json` should be accessible for component mapping

### angular-web-common Detection

Check for `angular-web-common/registry.json` in this order:
1. Current directory: `./angular-web-common/registry.json`
2. Parent directory: `../angular-web-common/registry.json`
3. Home: `~/Documents/GitHub/angular-web-common/registry.json`

If NOT found:
- **Skip Phase 2 (Common Component Mapping) entirely.**
- Treat ALL components as CUSTOM_NEEDED.
- Inform the user: "angular-web-common not found — skipping common component mapping. All components will be generated as custom. Run /figma-component-writer to set up the shared library."
- Continue with Phase 1 → Phase 3 (skip mapping preview) → Phase 4 (all custom).

## Pipeline

### Phase 1: Analyze Figma Design

Use Figma MCP to:
1. Take screenshots of each screen/section in the design
2. Break down the page structure into a component tree
3. Identify all UI elements: buttons, inputs, cards, tables, navigation, etc.
4. Note layout patterns: grid, flex, sidebar + main, header + content + footer
5. Extract design tokens used: colors, spacing, typography, shadows

Output: `implementation-blueprint.md` describing the page structure and components.

### Phase 2: Common Component Mapping

Load `angular-web-common/registry.json` and map each design element:

1. For each UI element in the blueprint:
   - Search registry for a matching common component
   - Score match based on: name similarity, variant availability, style compatibility
2. Classify each element:

| Classification | Meaning | Code Gen Approach |
|---|---|---|
| **COMMON_MATCH** | Exact or near-exact match in common library | Import from angular-web-common, apply layout only |
| **PARTIAL_MATCH** | Base component exists but needs customization | Import base, extend with custom styles |
| **CUSTOM_NEEDED** | No common component available | Generate full component with design tokens |

### Phase 3: Mapping Preview (User Confirmation)

Present the mapping to the user before generating any code:

```
┌──────────────────────────────────────────────────────────────┐
│ Common Component Mapping                                      │
├────────────────────┬────────────────────┬────────────────────┤
│ Figma Element      │ Common Match       │ Action             │
├────────────────────┼────────────────────┼────────────────────┤
│ Primary Button     │ buttons/button     │ ✅ Use common      │
│ Text Input         │ inputs/text-input  │ ✅ Use common      │
│ Status Badge       │ tags-badges/badge  │ ✅ Use common      │
│ Date Range Picker  │ inputs/date-picker │ 🔄 Partial (extend)│
│ KPI Gauge          │ (none)             │ ⚠️ Custom needed   │
│ Activity Timeline  │ (none)             │ ⚠️ Custom needed   │
└────────────────────┴────────────────────┴────────────────────┘

Common reuse: 8/12 components (67%)
Partial match: 1/12 (extend with custom styles)
Custom styling needed: 3/12

Proceed? [Y/n]
```

**HARD GATE:** Wait for user approval before Phase 4.

Allow the user to:
- Override any mapping ("use common for KPI Gauge too, we have something similar")
- Force custom ("don't use the common button, I want a custom one here")
- Ask questions about specific mappings

### Phase 4: Code Generation

Generate Angular code following these rules per classification:

#### COMMON_MATCH — Import and position only

```typescript
import { ButtonComponent } from '@angular-web-common/buttons';
import { TextInputComponent } from '@angular-web-common/inputs';

@Component({
  standalone: true,
  imports: [ButtonComponent, TextInputComponent],
  // Only layout/positioning styles — NO component styling
})
```

In SCSS: only layout rules (margin, position, grid-area, flex). Never duplicate
the common component's internal styles.

#### PARTIAL_MATCH — Import base + extend

```typescript
import { DatePickerComponent } from '@angular-web-common/inputs';

@Component({
  standalone: true,
  imports: [DatePickerComponent],
  // Custom wrapper with extended styling
})
```

In SCSS: use `::ng-deep` sparingly or component-level CSS vars to override
only the differences. Document what's customized and why.

#### CUSTOM_NEEDED — Full generation

Generate complete Angular component:
- Standalone component, OnPush change detection
- SCSS using design tokens (never hardcode colors/spacing)
- Responsive layout
- Accessibility attributes

### Phase 5: Validation

After code generation:

1. Verify all COMMON_MATCH imports resolve to actual components
2. Check no common component styles were duplicated
3. Verify design tokens are used (no hardcoded values)
4. Check responsive behavior if the design has multiple breakpoints

### Phase 6: Report

```
Code Generation Complete ✓

Page: Login Screen
Components generated: 1 file (login.component.ts/html/scss)

Common components used (8):
  ✅ ButtonComponent ← @angular-web-common/buttons
  ✅ TextInputComponent ← @angular-web-common/inputs
  ✅ BadgeComponent ← @angular-web-common/tags-badges
  ...

Custom components (3):
  ⚠️ KPI Gauge — full custom (no common match)
  ⚠️ Activity Timeline — full custom (no common match)
  ⚠️ Date Range Extended — partial (extended from common DatePicker)

Files created:
  src/app/features/login/login.component.ts
  src/app/features/login/login.component.html
  src/app/features/login/login.component.scss
  src/app/features/login/components/kpi-gauge/...
  src/app/features/login/components/activity-timeline/...
```

## Key Rules

1. **Common first.** Always check angular-web-common before creating custom components.
2. **No style duplication.** If a common component handles a style, don't repeat it.
3. **Design tokens only.** Never hardcode colors, spacing, or typography values.
4. **Show before doing.** Always present the mapping preview and get approval.
5. **Report what's custom.** User should know exactly what's not covered by common.
