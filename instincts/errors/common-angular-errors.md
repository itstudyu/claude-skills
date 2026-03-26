# Common Angular Error Patterns
confidence: 0.8

## NG0100: ExpressionChangedAfterItHasBeenCheckedError
- **Cause:** Modifying state in ngAfterViewInit or lifecycle hooks
- **Fix:** Use ChangeDetectorRef.detectChanges() or move logic to ngOnInit
- **Prevention:** Prefer OnPush change detection + signals

## NG0200: Circular Dependency
- **Cause:** Service A imports Service B which imports Service A
- **Fix:** Extract shared logic into a third service, or use injection tokens
- **Prevention:** Keep dependency tree shallow

## NG0300: Can't bind to 'X' since it isn't a known property
- **Cause:** Component/directive not imported in standalone component's imports[]
- **Fix:** Add missing import to @Component({ imports: [...] })
- **Prevention:** Always check imports[] when using standalone components

## Build Error: Module not found
- **Cause:** Missing export in barrel file, wrong import path
- **Fix:** Check tsconfig paths, verify barrel exports
- **Prevention:** Use IDE auto-imports, avoid manual path typing
