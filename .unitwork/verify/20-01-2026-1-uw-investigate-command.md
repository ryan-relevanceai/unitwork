# Verification: checkpoint(1) - Create uw-investigate.md command

## What Changed
- Created `plugins/unitwork/commands/uw-investigate.md`
- New read-only investigation command for deep codebase exploration

## AI-Verified
- [x] Has YAML frontmatter with name (`uw:investigate`), description, argument-hint
- [x] Has CRITICAL: Read-Only Mode section at top
- [x] Has STEP 0: Memory Recall (mandatory) with hindsight command
- [x] Contains goal transformation logic for write-oriented keywords
- [x] Uses `unitwork:exploration:memory-aware-explore` agent for exploration
- [x] Uses `unitwork:verification:test-runner` agent for hypothesis verification
- [x] Has temporary script handling with `/tmp/uw-investigate-*` pattern
- [x] Cleanup guaranteed via `;` (not `&&`) in bash command chain
- [x] Script constraints documented (50 lines, 30s, read-only, no user input)
- [x] Has memory retention at end via `hindsight memory retain`
- [x] Produces in-conversation summary (no file artifact per spec)
- [x] Structure matches uw-fix-ci.md and uw-plan.md patterns

## Human QA Checklist
- [ ] Review goal transformation logic - does it handle edge cases well?
- [ ] Verify the temporary script cleanup is bulletproof
- [ ] Test with a real investigation scenario

## Confidence
90% - Follows established command patterns from uw-fix-ci.md and uw-plan.md

## Reason for Confidence
- Matches spec confidence ceiling of 90%
- Follows all required structural patterns
- Transformation logic covers documented keywords
- Temp script cleanup uses `;` to ensure cleanup even on failure
