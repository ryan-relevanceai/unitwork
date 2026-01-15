# Checkpoint: Update uw-bootstrap.md to use memory-aware-explore

## Verification Strategy
Grep for subagent_type references to verify replacement.

## AI-Verified (100% Confidence)
- [x] Agent 1 uses `unitwork:exploration:memory-aware-explore` (line 98)
- [x] Agent 2 uses `unitwork:exploration:memory-aware-explore` (line 114)
- [x] No remaining `subagent_type="Explore"` references (grep confirms 0 matches)
- [x] Feature context added to each prompt ("codebase architecture", "testing and utilities")
- [x] Section text updated to "memory-aware exploration agents" (lines 90, 92, 94)

## Confidence Assessment
- Confidence level: 95%
- Rationale: All replacements verified via grep. Prompts include feature context. No functional testing possible.

## Learnings
- Bootstrap context labels should be general ("codebase architecture") not specific
