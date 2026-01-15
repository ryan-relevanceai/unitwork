# Checkpoint: uw-fix-ci.md command

## Verification Strategy
Code inspection and grep to verify all spec requirements are present.

## Subagents Launched
- None required (new command file creation)

## AI-Verified (100% Confidence)
Items verified by agent with certainty:
- [x] PR prerequisite check at Step 1 with fail-fast message - Confirmed via grep line 68
- [x] 5-cycle hard limit - Confirmed via grep lines 313, 318
- [x] Same error detection (3 consecutive) - Confirmed via grep lines 339, 341
- [x] Polling interval 30 seconds - Confirmed via grep line 254
- [x] Timeout 15 minutes - Confirmed via grep line 267
- [x] Memory recall as STEP 0 - Confirmed via read
- [x] Limited workflow parsing scope (only run: steps) - Confirmed via read Step 3
- [x] Local verification mapping (npm/yarn/pnpm/pip/cargo/go) - Confirmed via read Step 7
- [x] Gap collection before proceeding - Confirmed via read Gap Collection section
- [x] Commit message format `fix(ci):` - Confirmed via read Step 8
- [x] AskUserQuestion for user decisions - Confirmed via read multiple sections
- [x] Learnings retention at completion - Confirmed via read Completion section

## Confidence Assessment
- Confidence level: 90%
- Rationale: All spec requirements implemented. Lower confidence because CI interaction varies significantly by project and hasn't been tested against real CI.

## Learnings
- Implemented Units 4-7 together as they form a cohesive command
- The command structure follows existing patterns (uw-pr.md)
- Polling approach chosen over blocking `gh run watch` for better UX

## Human QA Checklist (only if needed)

### Prerequisites
- A repo with GitHub Actions CI
- A PR with failing CI

### Verification Steps
- [ ] Run `/uw:fix-ci` on a branch without a PR -> Should fail fast with clear message
- [ ] Workflow parsing -> Does it correctly extract run: commands from your workflows?
- [ ] Local verification -> Are the package manager commands correct for your setup?
- [ ] Polling timeout -> Is 15 minutes appropriate for your CI duration?
