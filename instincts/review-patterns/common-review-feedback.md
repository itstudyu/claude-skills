# Common Code Review Feedback
confidence: 0.8

## Unused Imports
- **Pattern:** Import statement exists but symbol is never used
- **Fix:** Remove unused imports
- **Tool:** IDE auto-organize imports

## Hardcoded Values
- **Pattern:** Magic numbers, color hex codes, pixel values in component SCSS
- **Fix:** Use design tokens or constants
- **Scope:** Colors, spacing, typography, breakpoints

## Missing Error Handling
- **Pattern:** HTTP calls without catchError, async without try/catch
- **Fix:** Add error handling at service boundary
- **Scope:** All external API calls, file operations

## Console.log Left in Code
- **Pattern:** Debug logging committed to source
- **Fix:** Remove or replace with proper logger
- **Exception:** Intentional diagnostic logging with log level
