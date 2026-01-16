# Plan/Work Flow Modifications

## Purpose & Impact
- **Why:** Reduce friction and improve consistency across Unit Work commands
- **Who:** Users running `/uw:plan`, `/uw:work`, `/uw:action-comments`, `/uw:review`
- **Success:** Commands share verification flows, conditional agent spawning based on scope, auto-detect PR by branch

## Requirements

### Functional Requirements
- [ ] FR1: Plan-review agents spawn conditionally based on unit count (>3 = full, <=3 = gap-detector only)
- [ ] FR2: uw:work supports inline feature descriptions with minimal plan-verify step
- [ ] FR3: uw:action-comments aligns with plan→plan-verify→work→work-verify flow
- [ ] FR4: PR-related commands auto-detect PR by branch and confirm with user
- [ ] FR5: Verification flow consolidated into single reference document

### Non-Functional Requirements
- [ ] NFR1: Plan-review agents use proper subagent_types instead of general-purpose with inline prompts
- [ ] NFR2: Cross-references updated when content is moved

### Out of Scope
- Creating a separate pr-detection.md reference file (pattern is 2 lines, too trivial)
- Modifying uw-pr.md for auto-detect (already implemented)

## Technical Approach

### Key Decisions
1. **Consolidation = MOVE**: Content moves from source files to verification-flow.md; sources updated with references
2. **Gap-detector scope**: Runs ONCE before any fixes/implementation, not per-fix
3. **Unit threshold rationale**: >3 units chosen because small plans don't benefit from full review overhead
4. **Subagent types**: Use `unitwork:plan-review:gap-detector`, `unitwork:plan-review:feasibility-validator`, `unitwork:plan-review:utility-pattern-auditor`

### Files Affected
- `plugins/unitwork/skills/unitwork/references/verification-flow.md` (NEW)
- `plugins/unitwork/skills/unitwork/references/decision-trees.md` (update cross-references)
- `plugins/unitwork/skills/unitwork/references/checkpointing.md` (move content out)
- `plugins/unitwork/commands/uw-plan.md` (conditional spawning, subagent_types)
- `plugins/unitwork/commands/uw-work.md` (add minimal plan-verify)
- `plugins/unitwork/commands/uw-action-comments.md` (align with flow, add auto-detect PR)
- `plugins/unitwork/commands/uw-review.md` (add auto-detect PR for PR mode)

## Implementation Units

### Unit 1: Create references/verification-flow.md
**Changes:**
- Create new file `plugins/unitwork/skills/unitwork/references/verification-flow.md`
- MOVE "Which Verification Subagent to Use" from decision-trees.md (lines 118-156)
- MOVE "Self-Correcting Review (Fix Checkpoints Only)" from checkpointing.md (lines 42-115)
- MOVE "Confidence Calculation" from checkpointing.md (lines 116-131)
- Update decision-trees.md with cross-reference to verification-flow.md
- Update checkpointing.md with cross-reference to verification-flow.md

**Self-Verification:**
- Grep for "Which Verification Subagent" in decision-trees.md (should be reference only)
- Grep for "Self-Correcting Review" in checkpointing.md (should be reference only)
- Read verification-flow.md to confirm all sections present

**Human QA:**
- [ ] Verify verification-flow.md is coherent and well-organized
- [ ] Verify cross-references in source files are correct

**Confidence Ceiling:** 95% (documentation consolidation)

---

### Unit 2: Update uw-plan.md (conditional plan-review)
**Depends on:** None

**Changes:**
- Add unit count check before Phase 3.5
- Replace `subagent_type="general-purpose"` with proper types:
  - `unitwork:plan-review:gap-detector`
  - `unitwork:plan-review:feasibility-validator`
  - `unitwork:plan-review:utility-pattern-auditor`
- Add conditional logic:
  - If >3 units: spawn all 3 agents
  - If <=3 units: spawn only gap-detector
- Add inline rationale comment explaining threshold choice

**Location:** Phase 3.5 section (around lines 238-320)

**Self-Verification:**
- Grep for `general-purpose` in uw-plan.md (should be 0 occurrences in Phase 3.5)
- Grep for `unitwork:plan-review:` in uw-plan.md (should be 3 occurrences)
- Read Phase 3.5 to confirm conditional logic is present

**Human QA:**
- [ ] Verify conditional threshold logic is clear
- [ ] Verify rationale comment is helpful

**Confidence Ceiling:** 95% (straightforward text replacement + conditional)

---

### Unit 3: Update uw-work.md (add minimal plan-verify)
**Depends on:** None

**Changes:**
- Add new section after memory recall, before resume detection: "Step 0.5: Minimal Plan Verification"
- Trigger: When `#$ARGUMENTS` is a text description (not a file path) AND no matching spec exists in `.unitwork/specs/`
- Behavior:
  1. Spawn `unitwork:plan-review:gap-detector` with the feature description
  2. Single round, no convergence loop
  3. If P1/P2 gaps found: Present to user via AskUserQuestion
     - "Address gaps now" - answer questions before proceeding
     - "Proceed anyway" - acknowledge gaps and continue
     - "Create full spec first" - suggest running /uw:plan
  4. If no gaps or only P3: proceed automatically

**Self-Verification:**
- Read uw-work.md to confirm new section exists
- Verify gap-detector subagent_type is used correctly
- Confirm AskUserQuestion options are present

**Human QA:**
- [ ] Verify trigger logic makes sense (text vs file path detection)
- [ ] Verify user options are appropriate

**Confidence Ceiling:** 90% (new control flow, edge cases possible)

---

### Unit 4: Update uw-action-comments.md (align with flow)
**Depends on:** Unit 1 (verification-flow.md references)

**Changes:**
1. **Add auto-detect PR by branch** (replace hardcoded PR number requirement):
   - At start: `gh pr list --head $(git branch --show-current) --json number,title,url`
   - If single PR: Confirm with user "Found PR #X: {title}. Use this?"
   - If user says no: Ask for PR number manually
   - If multiple PRs: Present list and ask user to select
   - If no PR: Ask for PR number manually

2. **Update verification references**:
   - Replace `decision-trees.md#which-verification-subagent-to-use` with `verification-flow.md`
   - Replace `checkpointing.md#self-correcting-review` with `verification-flow.md`

3. **Add gap-detector plan-verify step**:
   - After Step 4 (Present Findings), before Step 5 (Implement Fixes)
   - Run gap-detector ONCE for all VALID_FIX items collectively
   - If gaps found: Present to user via AskUserQuestion before implementing

**Self-Verification:**
- Grep for `<pr_number> #$ARGUMENTS` (should be replaced with auto-detect)
- Grep for `decision-trees.md` (should be 0 in verification sections)
- Grep for `checkpointing.md#self-correcting` (should be 0)
- Read to confirm gap-detector step exists between Step 4 and Step 5

**Human QA:**
- [ ] Verify PR auto-detection flow handles edge cases
- [ ] Verify gap-detector placement makes sense

**Confidence Ceiling:** 90% (multiple changes, integration points)

---

### Unit 5: Update uw-review.md (add auto-detect PR)
**Depends on:** None

**Changes:**
- Modify "Determine Review Origin" section (lines 77-98)
- When user runs `uw:review pr` WITHOUT a number:
  1. Auto-detect PR: `gh pr list --head $(git branch --show-current) --json number,title,url`
  2. If single PR: Confirm "Found PR #X: {title}. Review this PR?"
  3. If user says no: Ask for PR number manually
  4. If multiple PRs: Present list and ask user to select
  5. If no PR: Ask for PR number manually
- When user runs `uw:review` (branch mode) and a PR exists for the branch:
  - Prompt: "Found PR #X for this branch. Review PR or branch diff?"

**Self-Verification:**
- Read Determine Review Origin section to confirm auto-detect logic
- Verify both flows (explicit `pr` mode and branch mode suggestion) are present

**Human QA:**
- [ ] Verify PR auto-detection UX is intuitive
- [ ] Verify branch mode suggestion doesn't interrupt workflow

**Confidence Ceiling:** 90% (UX changes, user interaction)

## Verification Plan

### Agent Self-Verification
- Test: Run `/uw:plan` with a 2-unit feature (should spawn only gap-detector)
- Test: Run `/uw:plan` with a 5-unit feature (should spawn all 3 agents)
- Test: Run `/uw:work "simple fix"` (should trigger minimal plan-verify)
- Test: Run `/uw:action-comments` on branch with open PR (should auto-detect)
- Grep: Verify all cross-references updated

### Human QA Checklist
- [ ] Verify conditional plan-review makes sense for different spec sizes
- [ ] Verify minimal plan-verify doesn't block simple changes unnecessarily
- [ ] Verify auto-detect PR UX is smooth and non-intrusive
- [ ] Verify verification-flow.md is well-organized and complete

## Spec Changelog
- 16-01-2026: Initial spec from interview
  - Removed Unit 2 (pr-detection.md) - too trivial for own file
  - Removed Unit 6 (uw-pr.md) - auto-detect already implemented
  - Added explicit unit dependencies
  - Clarified gap-detector scope (once per PR/spec, not per-fix)
  - Added rationale for >3 units threshold
