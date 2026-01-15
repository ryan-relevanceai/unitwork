# Self-Correcting Review Cycles

## Purpose & Impact
- **Why:** After review findings are fixed, the AI currently assumes its fixes are correct without verification. This leads to bugs introduced by fixes (e.g., unnecessary abstractions, scope creep) going unnoticed.
- **Who:** Users who run `/uw:work` to fix review findings and want confidence the fixes are correct.
- **Success:** Fixes to review findings are automatically re-reviewed with selective agents, cycling until the fix is verified correct and in-scope.

## Requirements

### Functional Requirements

#### Part 1: Self-Correcting Review in /uw:work

- [ ] FR1: After implementing a fix checkpoint (checkpoint N.1, N.2, etc.), automatically trigger selective re-review
- [ ] FR2: Risk assessment determines review intensity using concrete thresholds:
  - **No review needed:** ALL of: <=3 lines changed AND file matches `*.test.*, *.spec.*, *.md, *.json, *.yaml, *.yml, *.config.*` AND pure additions (no deletions)
  - **Light review:** ANY of: 4-30 lines changed OR single file in src/ OR changes with <5 deletions
  - **Full review:** ANY of: >30 lines changed OR >3 files modified OR deletions >10 lines OR security-related file patterns
- [ ] FR3: Re-review uses the existing Re-Review Protocol from uw-review.md (reference, don't duplicate):
  - Type issue fixed → type-safety agent
  - Pattern issue fixed → patterns-utilities agent
  - Performance issue fixed → performance-database agent
  - Architecture issue fixed → architecture agent
  - Security issue fixed → security agent
  - Simplicity issue fixed → simplicity agent
- [ ] FR4: Simplicity agent receives explicit scope-guard context: "You are reviewing a FIX to a specific issue. DO NOT suggest additional refactoring beyond the fix. DO NOT expand scope. Only verify the fix addresses the original issue without introducing new problems."
- [ ] FR5: Cycle has a hard limit of 3 iterations. After 3 cycles, MUST present to user with:
  - Summary of all fix attempts
  - Recurring issues (if any)
  - Recommendation: continue manually, accept state, or revert
- [ ] FR6: If re-review finds new issues, present using AskUserQuestion:
  - **Fix the new issue** - Triggers another cycle (if under limit)
  - **Accept and continue** - Break cycle, proceed with current state
  - **Revert fix** - Execute `git reset --soft HEAD~1` to unstage, let user review
- [ ] FR7: For mixed fix types (fix addresses multiple issue categories), spawn ALL relevant agents (union, not primary)

#### Part 2: /uw:fix-ci Command

**Prerequisite:** This command requires an existing PR on the current branch. If no PR exists, the command should fail with a clear message directing the user to create a PR first (via `/uw:pr` or `gh pr create`).

- [ ] FR8: New command `/uw:fix-ci` that:
  - First verifies a PR exists for the current branch (fail fast if not)
  - Then autonomously cycles: analyze failure → fix → commit → push → wait for CI → repeat
- [ ] FR9: Parse `.github/workflows/*.yml` to extract `run:` commands (LIMITED SCOPE: only extract literal `run:` steps, skip matrix/reusable workflows/conditionals)
- [ ] FR10: Run indicative local checks before pushing IF the CI command is a standard package manager command (npm/yarn/pnpm/pip/cargo/go test). Skip local verification for Docker, actions/, or custom scripts.
- [ ] FR11: Monitor CI using polling pattern (NOT blocking `gh run watch`):
  ```bash
  gh run list --workflow={name} --branch={branch} --limit 1 --json status,conclusion
  ```
  Poll every 30 seconds with 15-minute timeout per run
- [ ] FR12: Parse CI failure output to extract: failing step name, error message, file:line if available
- [ ] FR13: Commit after each fix attempt with message: `fix(ci): {what was fixed}`
- [ ] FR14: Collect all gaps during analysis (missing info, unclear errors, needs user input) and present together using AskUserQuestion before proceeding
- [ ] FR15: Hard limit of 5 cycles. After 5 cycles without success, MUST stop and present:
  - All fix attempts made
  - Failure patterns observed
  - Recommendation for user intervention
- [ ] FR16: If same error appears 3 times consecutively, stop immediately and ask user (likely unfixable by code changes)

### Non-Functional Requirements

- [ ] NFR1: Risk assessment must be fast (<2s) - regex/glob matching only, no agent spawning for the assessment itself
- [ ] NFR2: Re-review should only spawn agents relevant to the fix, not all 6
- [ ] NFR3: CI polling updates should be one-line status (not verbose output)
- [ ] NFR4: Total context usage should stay reasonable - scope re-review to fix diff + immediate context, not full PR

### Out of Scope

- Support for CI systems other than GitHub Actions (defer to future)
- Automatic PR creation after CI passes (user should decide)
- Parallel fix attempts for multiple CI failures (fix sequentially)
- Complex workflow parsing (matrix, reusable workflows, conditionals)
- Service container handling in CI workflows

## Technical Approach

### Part 1: Modifications to uw-work.md

**Integration Point:** Add new "Step 4.5: Self-Correcting Review" between Step 4 (Create Checkpoint) and Step 5 (Continue or Pause). This step ONLY triggers for fix checkpoints (checkpoint N.1, N.2, etc.).

**Implementation:**
1. **Risk Assessment** - Quick heuristic using glob patterns and line counts (no agent spawning)
2. **Selective Agent Invocation** - Spawn individual review agents based on fix type, passing only the fix diff
3. **Cycle Logic** - Track iteration count, handle user choice, enforce hard limit

**Architecture Decision:** Inline the agent spawning in uw-work.md (not invoke uw-review.md as sub-command). Reasoning: uw-review.md does full PR review with all 6 agents; we need targeted single-agent review with limited scope.

### Part 2: New Command uw-fix-ci.md

Structure:
- STEP 0: Memory recall (mandatory)
- Step 1: Verify PR exists for current branch (fail fast if not)
- Step 2: Check for existing CI failures via `gh run list`
- Step 3: Parse CI workflow files (limited scope)
- Step 4: Analyze failure output
- Step 5: Plan fix (single issue at a time)
- Step 6: Implement fix
- Step 7: Local verification (if applicable)
- Step 8: Commit and push
- Step 9: Poll for CI completion (30s intervals, 15min timeout)
- Step 10: Check result → loop to Step 4 OR complete OR escalate

### Key Files to Modify/Create

1. `plugins/unitwork/commands/uw-work.md` - Add Step 4.5 self-correcting review
2. `plugins/unitwork/commands/uw-fix-ci.md` - New command (create)
3. `plugins/unitwork/.claude-plugin/plugin.json` - Update command count to 8

## Implementation Units

### Unit 1: Add risk assessment to uw-work.md
- **Changes:** `plugins/unitwork/commands/uw-work.md` - Add "Step 4.5: Self-Correcting Review (Fix Checkpoints Only)" with risk assessment heuristics
- **Self-Verification:** Read file, verify thresholds match spec exactly (<=3 lines, specific file patterns, etc.)
- **Human QA:** Review if thresholds feel right for your codebase
- **Confidence Ceiling:** 95%

### Unit 2: Add selective re-review trigger to uw-work.md
- **Changes:** `plugins/unitwork/commands/uw-work.md` - Add agent spawning based on fix type with scope-limited context
- **Self-Verification:** Verify agent mapping matches uw-review.md Re-Review Protocol; verify scope-guard language is present
- **Human QA:** Review the cycle logic flow
- **Confidence Ceiling:** 90%

### Unit 3: Add cycle limits and user interaction to uw-work.md
- **Changes:** `plugins/unitwork/commands/uw-work.md` - Add 3-cycle hard limit with AskUserQuestion options
- **Self-Verification:** Grep for "3 iterations" limit, verify AskUserQuestion options match spec
- **Human QA:** None needed
- **Confidence Ceiling:** 95%

### Unit 4: Create uw-fix-ci.md command structure with PR prerequisite
- **Changes:** Create `plugins/unitwork/commands/uw-fix-ci.md` with frontmatter, memory recall, PR verification step, and basic structure
- **Self-Verification:** Verify file exists with correct frontmatter format; verify PR check uses `gh pr list --head "$CURRENT_BRANCH"`
- **Human QA:** Review command description and PR prerequisite messaging
- **Confidence Ceiling:** 95%

### Unit 5: Add CI workflow parsing to uw-fix-ci.md
- **Changes:** `plugins/unitwork/commands/uw-fix-ci.md` - Add limited YAML parsing (extract `run:` steps only)
- **Self-Verification:** Verify parsing only targets `run:` keys, explicitly skips complex patterns
- **Human QA:** Test against your `.github/workflows/*.yml` files
- **Confidence Ceiling:** 80% (YAML structure can vary)

### Unit 6: Add CI monitoring and polling to uw-fix-ci.md
- **Changes:** `plugins/unitwork/commands/uw-fix-ci.md` - Add `gh run list` polling with 30s interval, 15min timeout
- **Self-Verification:** Verify gh CLI commands are correct syntax; verify timeout values match spec
- **Human QA:** Test against a real repo with CI
- **Confidence Ceiling:** 90%

### Unit 7: Add fix cycle logic with limits to uw-fix-ci.md
- **Changes:** `plugins/unitwork/commands/uw-fix-ci.md` - Add main loop with 5-cycle limit, same-error detection, gap collection
- **Self-Verification:** Verify loop has explicit exit conditions at 5 cycles and 3 same-errors
- **Human QA:** Review the cycle logic for edge cases
- **Confidence Ceiling:** 85%

### Unit 8: Update plugin.json
- **Changes:** `plugins/unitwork/.claude-plugin/plugin.json` - Update description to "8 commands"
- **Self-Verification:** Count files in commands/ directory (should be 8), verify matches description
- **Human QA:** None needed
- **Confidence Ceiling:** 100%

## Verification Plan

### Agent Self-Verification
- Verify all file references exist
- Verify risk thresholds match spec exactly
- Verify agent mapping matches existing Re-Review Protocol
- Verify gh CLI command syntax is correct
- Verify hard limits are present (3 cycles for Part 1, 5 cycles for Part 2)
- Count commands directory to verify plugin.json accuracy

### Human QA Checklist

- [ ] Risk assessment thresholds: Do <=3 lines and the file patterns feel right for your codebase?
- [ ] Scope-guard language: Will the simplicity agent actually respect these constraints?
- [ ] CI workflow parsing: Does the limited parsing work for your `.github/workflows/*.yml` files?
- [ ] Polling interval: Is 30 seconds appropriate for your CI speed?
- [ ] Cycle limits: Are 3 (Part 1) and 5 (Part 2) appropriate limits?

## Spec Changelog
- 15-01-2026: Initial spec from interview
- 15-01-2026: Updated after plan review - added concrete thresholds, hard limits, scope reductions, clarified integration points
- 15-01-2026: Added PR prerequisite for /uw:fix-ci - command requires existing PR, fails fast if not present
