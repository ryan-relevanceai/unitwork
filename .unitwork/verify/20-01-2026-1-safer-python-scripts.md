# Checkpoint: Safer Python Scripts for Investigation

**Date:** 2026-01-20
**Unit:** Replace bash shell scripts with Python-based approach

## Changes Made

Updated `plugins/unitwork/commands/uw-investigate.md` to:
1. Replace bash heredoc script creation with `uv run python -c` for ephemeral scripts
2. Add `.unitwork/tmp/` as alternative for persistent/complex scripts
3. Updated allowed/forbidden operations to reflect the new approach
4. Added explicit prohibition on creating shell scripts via bash heredocs

## Verification

### AI-Verified
- [x] Allowed operations updated to include `uv run python -c` and `.unitwork/tmp/`
- [x] Forbidden operations now explicitly prohibit bash heredoc shell scripts
- [x] Script Lifecycle section replaced with two Python-based approaches
- [x] Constraints updated to reference Python stdlib and `uv run`
- [x] Removed cleanup guarantee section (no longer needed - inline scripts are ephemeral)

### Human QA Checklist
- [ ] Confirm `uv run python -c` approach aligns with team preferences

## Confidence: 98%

High confidence because:
- Direct replacement of dangerous bash pattern with safer Python alternative
- `uv run python -c` is ephemeral by design, no cleanup needed
- `.unitwork/tmp/` for persistent scripts is explicit and trackable
- Memory recall confirmed shell script safety is a known concern

## Notes

The user explicitly requested this change due to safety concerns with creating shell scripts directly via bash.
