#!/bin/bash
# run-with-profile.sh — Hook profile gate inspired by Everything Claude Code's ECC_HOOK_PROFILE
# Usage: run-with-profile.sh <hook-id> <allowed-profiles-csv> <actual-script> [args...]
#
# Environment variables:
#   HOOK_PROFILE    — minimal|standard|strict (default: standard)
#   DISABLED_HOOKS  — comma-separated hook IDs to disable (e.g., "code-quality-check,secret-scanner")
#
# Profile definitions:
#   minimal  — Only lifecycle essentials (inject-instructions, session-summary, learn-from-errors)
#   standard — minimal + security + quality (secret-scanner, code-quality-check)
#   strict   — standard + future strict-only hooks
#
# Exit code semantics (passed through from actual script):
#   0 — clean / no issues
#   1 — error (graceful continue)
#   2 — block / feedback (PreToolUse: hard block; PostToolUse: feedback to Claude)

HOOK_ID="$1"
ALLOWED_PROFILES="$2"
ACTUAL_SCRIPT="$3"
shift 3

# Default profile
CURRENT_PROFILE="${HOOK_PROFILE:-standard}"

# Check if hook is explicitly disabled
if [ -n "$DISABLED_HOOKS" ]; then
  IFS=',' read -ra DISABLED_ARRAY <<< "$DISABLED_HOOKS"
  for disabled in "${DISABLED_ARRAY[@]}"; do
    disabled=$(echo "$disabled" | xargs)  # trim whitespace
    if [ "$disabled" = "$HOOK_ID" ]; then
      # Pass stdin through and exit clean (no-op)
      cat > /dev/null
      exit 0
    fi
  done
fi

# Check if current profile is in allowed profiles
IFS=',' read -ra PROFILE_ARRAY <<< "$ALLOWED_PROFILES"
ALLOWED=false
for profile in "${PROFILE_ARRAY[@]}"; do
  profile=$(echo "$profile" | xargs)  # trim whitespace
  if [ "$profile" = "$CURRENT_PROFILE" ]; then
    ALLOWED=true
    break
  fi
done

if [ "$ALLOWED" = false ]; then
  # Profile not allowed — pass stdin through and exit clean
  cat > /dev/null
  exit 0
fi

# Profile allowed — execute the actual hook script
exec "$ACTUAL_SCRIPT" "$@"
