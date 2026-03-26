# Frontend Standards

> Additional rules for frontend development. Applied on top of common standards.

## Angular Conventions

### Components
- Standalone components (no NgModules)
- OnPush change detection strategy
- Selector prefix: project-specific (e.g., `app-`, `awc-`)
- One component per file

### Styling
- SCSS (not CSS or Less)
- Use design tokens from angular-web-common when available
- No inline styles
- BEM naming for custom classes
- Responsive: mobile-first approach

### Templates
- No complex logic in templates (move to component class)
- Use `@if` / `@for` (new control flow syntax for Angular 17+)
- Accessibility: always include `aria-*` attributes on interactive elements

### State Management
- Simple state: signals or component-level
- Complex state: NgRx or similar
- No global mutable state outside of stores

### File Naming
- kebab-case for all files: `user-profile.component.ts`
- Colocate related files: `.ts`, `.html`, `.scss`, `.spec.ts` together

### Testing
- Unit tests for all components (`.spec.ts` colocated)
- Test behavior, not implementation details
- Mock HTTP calls, not services
