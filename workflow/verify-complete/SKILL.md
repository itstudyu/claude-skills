---
name: verify-complete
description: |
  Run verification commands and confirm output before making any success claims.
  Evidence before assertions, always. Use this skill whenever the user asks to
  "verify", "check if done", "confirm it works", "make sure tests pass", "確認して",
  "検証して", "테스트 확인", "검증해줘", or before any commit, PR, or task completion.
  Proactively suggest this skill whenever you're about to claim work is complete —
  no completion claim is valid without fresh verification evidence.
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# Verification Before Completion

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim
it passes. Previous runs don't count — state can change between messages.

## The Gate Function

Before claiming any status or expressing satisfaction:

1. **IDENTIFY:** What command proves this claim?
2. **RUN:** Execute the full command (fresh, complete)
3. **READ:** Full output — check exit code, count failures
4. **VERIFY:** Does output confirm the claim?
   - If NO → state actual status with evidence
   - If YES → state claim with evidence
5. **ONLY THEN:** Make the claim

Skip any step = lying, not verifying.

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags — STOP

If you notice any of these, you're about to make an unverified claim:

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!")
- About to commit/push/PR without verification
- Trusting agent success reports without checking
- Relying on partial verification
- Thinking "just this once"
- Any wording implying success without having run verification

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | Run the verification |
| "I'm confident" | Confidence is not evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter is not the compiler |
| "Agent said success" | Verify independently |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |

## Key Patterns

**Tests:**
```
OK: [Run test command] → [See: 34/34 pass] → "All tests pass"
BAD: "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
OK: Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
BAD: "I've written a regression test" (without red-green verification)
```

**Build:**
```
OK: [Run build] → [See: exit 0] → "Build passes"
BAD: "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
OK: Re-read plan → Create checklist → Verify each → Report gaps or completion
BAD: "Tests pass, phase complete"
```

**Agent delegation:**
```
OK: Agent reports success → Check VCS diff → Verify changes → Report actual state
BAD: Trust agent report
```

## Why This Matters

From real failure memories:
- Trust broken by unverified claims
- Undefined functions shipped — would crash at runtime
- Missing requirements shipped — incomplete features
- Time wasted on false completion → redirect → rework

## When To Apply

Always before:
- Any success or completion claim
- Any expression of satisfaction about work state
- Committing, PR creation, task completion
- Moving to the next task
- Delegating to agents

## The Bottom Line

No shortcuts for verification.

Run the command. Read the output. Then claim the result.

This is non-negotiable.
