# Angular Component Best Practices
confidence: 0.8

## Standalone Components (preferred)
- Always use `standalone: true`
- Import dependencies in `imports: []` array
- No NgModules unless wrapping legacy code

## OnPush Change Detection
- Default to `changeDetection: ChangeDetectionStrategy.OnPush`
- Use signals or async pipe for reactive data
- Avoid direct property mutation

## Component Structure
- Selector prefix: project-specific (e.g., `app-`, `awc-`)
- One component per file
- Template: inline for <5 lines, separate file otherwise
- SCSS: always separate file, use design tokens
