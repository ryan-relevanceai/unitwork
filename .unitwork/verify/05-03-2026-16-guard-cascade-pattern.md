# Checkpoint: add GUARD_CASCADE and MIXED_CONCERNS patterns to simplicity agent

## Verification Strategy
Read the updated file, confirm new sections exist with correct examples and severity guidance.

## AI-Verified (100% Confidence)
- [x] GUARD_CASCADE pattern added (section 7) with React useEffect examples
- [x] MIXED_CONCERNS pattern added (section 8) with separate-effects refactor
- [x] Both new patterns added to taxonomy reference list at top
- [x] Output format updated to include new pattern names
- [x] Hidden side effect in bail-out branches explicitly called out as red flag
- [x] Severity guidance: P2 when guards hide side effects or are duplicated, P3 for pure readability

## Confidence Assessment
- Confidence level: 98%
- Rationale: Agent prompt changes based on real review finding. The examples directly mirror the useGtmTaskNotifications.ts pattern that was missed.

## Human QA Checklist
- [ ] Run /uw:review on a PR with guard cascade patterns, verify the simplicity agent catches them
