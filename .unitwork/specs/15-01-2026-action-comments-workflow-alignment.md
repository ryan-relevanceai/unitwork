# Action Comments Workflow Alignment

## Purpose & Impact
- Align `uw-action-comments` with the standard Unit Work cycle (plan → verify → work → verify → compound)
- Create a single source of truth for checkpoint logic (`checkpointing.md`)
- Ensure PR comment resolution follows the same quality standards as feature implementation

## Requirements

### Functional Requirements
- [ ] FR1: Create `checkpointing.md` reference document consolidating checkpoint logic
- [ ] FR2: Update `uw-action-comments.md` with full checkpoint workflow
- [ ] FR3: Add Memory Recall (STEP 0) to `uw-action-comments.md`
- [ ] FR4: Add self-correcting review to `uw-action-comments.md` fix checkpoints
- [ ] FR5: Add prompted Compound phase trigger at end of `uw-action-comments.md`
- [ ] FR6: Update `uw-work.md` to reference `checkpointing.md` instead of inline definitions
- [ ] FR7: Update `SKILL.md` to reference `checkpointing.md` instead of inline definitions

### Non-Functional Requirements
- [ ] NFR1: No duplication of checkpoint commit format across files
- [ ] NFR2: Reference existing utilities where possible (templates/verify.md, decision-trees.md)

### Out of Scope
- Modifying `uw-review.md` (already uses correct patterns)
- Modifying `uw-plan.md` (different workflow)
- Changing the checkpoint commit message format itself
- "Full vs Light" workflow distinction (removed - just do memory recall and adapt)

## Technical Approach

### Workflow Philosophy (Simplified)
No conditional flow. The workflow is:
1. Memory Recall (always)
2. Work (with context from memory/specs if available)
3. Checkpoint (standard format from checkpointing.md)
4. Self-correcting review (risk-based)
5. Compound (prompted)

The workflow naturally adapts based on available context from memory/specs without explicit branching.

### checkpointing.md Scope
Create new reference file containing:
1. **Checkpoint commit format** (extracted from uw-work.md and SKILL.md)
2. **Reference to templates/verify.md** for verification document format
3. **Reference to decision-trees.md** for "when to checkpoint" logic
4. **Self-correcting review protocol** (extracted from uw-work.md Step 4.5)

This consolidates duplicated content while referencing existing files where they exist.

### Fix Checkpoint Numbering for PR Comments
Since PR comment fixes don't have "units", use this numbering scheme:
- `checkpoint(pr-{PR_NUMBER}-{fix_number}): {fix description}`
- Example: `checkpoint(pr-123-1): handle null email addresses`
- Example: `checkpoint(pr-123-2): add missing error boundary`

### Comment Categories and Checkpoints
Only `VALID_FIX` items get checkpoints. Other categories:
- **ALREADY_HANDLED**: Reply only, no checkpoint
- **QUESTION**: Reply only, no checkpoint
- **DEFER**: Document in report, no checkpoint
- **DISAGREE**: Reply with explanation, no checkpoint

### Compound Phase Behavior
At end of comment resolution, prompt user:
```
All comment fixes complete.

Run /uw:compound to capture learnings from this PR review cycle?
```
Options: Yes / No / Later

### Files Affected
1. **NEW**: `plugins/unitwork/skills/unitwork/references/checkpointing.md`
2. **MODIFY**: `plugins/unitwork/commands/uw-action-comments.md`
3. **MODIFY**: `plugins/unitwork/commands/uw-work.md`
4. **MODIFY**: `plugins/unitwork/skills/unitwork/SKILL.md`

## Implementation Units

### Unit 1: Create checkpointing.md reference
**Depends on:** None

- **Changes:** Create `plugins/unitwork/skills/unitwork/references/checkpointing.md`
- **Content (use section headers to locate source, not line numbers):**
  - From `uw-work.md` section "**Checkpoint Commit Format:**" - extract commit format
  - From `uw-work.md` section "**Verification Document:**" - add reference to `templates/verify.md`
  - From `uw-work.md` section "### Step 4.5: Self-Correcting Review" - extract full section
  - From `decision-trees.md` - add reference to "## When to Checkpoint" section
- **Self-Verification:** Read file, verify all sections present (commit format, verification doc reference, self-correcting review, decision tree reference)
- **Human QA:** Review document structure and completeness
- **Confidence Ceiling:** 95%

### Unit 2: Rewrite uw-action-comments.md
**Depends on:** Unit 1

- **Changes:** Complete rewrite of `plugins/unitwork/commands/uw-action-comments.md`
- **New Structure:**
  1. STEP 0: Memory Recall (use pattern from uw-work.md verbatim, query "PR review patterns and gotchas")
  2. Fetch PR Comments (existing Step 1)
  3. Find Related Spec (existing Step 2, keep as-is)
  4. Independently Verify Each Comment (existing Step 3)
  5. Present Findings (existing Step 4)
  6. For Each VALID_FIX:
     - Implement fix
     - Launch verification subagents (per decision-trees.md "Which Verification Subagent")
     - Calculate confidence
     - Create checkpoint: `checkpoint(pr-{PR}-{n}): {description}`
     - Self-correcting review (reference checkpointing.md)
  7. Single commit for non-fix clarifications (ALREADY_HANDLED, QUESTION replies)
  8. Compound Phase Prompt: "Run /uw:compound to capture learnings?"
  9. Report and Push (existing Step 8)
- **Self-Verification:** Read file, verify sections present: Memory Recall, checkpoint format per fix, compound prompt
- **Human QA:** Test with actual PR
- **Confidence Ceiling:** 90% (workflow logic is complex)

### Unit 3: Update uw-work.md references
**Depends on:** Unit 1

- **Changes:** Modify `plugins/unitwork/commands/uw-work.md`
  - Replace inline checkpoint format section with: "See [checkpointing.md](../skills/unitwork/references/checkpointing.md#checkpoint-commit-format)"
  - Replace inline verification doc template with: "See [templates/verify.md](../skills/unitwork/templates/verify.md)"
  - Replace inline self-correcting review with: "See [checkpointing.md](../skills/unitwork/references/checkpointing.md#self-correcting-review)"
- **Self-Verification:**
  - Grep for "checkpoint({unit-number})" format - should only find references, not inline definitions
  - Verify reference paths are valid relative paths
- **Human QA:** Run /uw:work and verify checkpoint creation works
- **Confidence Ceiling:** 95%

### Unit 4: Update SKILL.md references
**Depends on:** Unit 1

- **Changes:** Modify `plugins/unitwork/skills/unitwork/SKILL.md`
  - Replace inline "## Checkpoint Commit Format" section with reference to checkpointing.md
- **Self-Verification:** Read file, verify reference added, no duplicate checkpoint format
- **Human QA:** N/A (simple reference change)
- **Confidence Ceiling:** 98%

### Unit 5: Version bump and changelog
**Depends on:** Units 1-4

- **Changes:**
  - MINOR bump version in `plugins/unitwork/.claude-plugin/plugin.json` (new reference file = new component)
  - Update `plugins/unitwork/CHANGELOG.md` with:
    - Created checkpointing.md reference
    - Aligned uw-action-comments with full checkpoint workflow
    - Reduced duplication across command files
- **Self-Verification:** Read files, verify version bumped and changelog updated
- **Human QA:** N/A
- **Confidence Ceiling:** 98%

## Verification Plan

### Agent Self-Verification
- Read all modified files to confirm changes
- Grep for duplicate checkpoint commit format definitions (should find only in checkpointing.md)
- Verify all markdown reference links are valid relative paths
- Run `/uw:work` style checkpoint creation mentally to verify flow

### Human QA Checklist
- [ ] Run `/uw:action-comments {PR_NUMBER}` on a test PR with at least 2 comments
- [ ] Verify Memory Recall executes BEFORE fetching comments
- [ ] Verify each VALID_FIX gets its own checkpoint commit with format `checkpoint(pr-{PR}-{n})`
- [ ] Verify self-correcting review triggers based on risk assessment
- [ ] Verify Compound prompt appears at end
- [ ] Run `/uw:work` on a test spec and verify checkpoints still work with references

## Important Notes (from Memory)
- ALWAYS update CHANGELOG.md and bump version BEFORE committing (per CLAUDE.md)
- Follow-up fixes require full checkpoint workflow (verify → document → commit)
- Memory recall must be STEP 0 in all workflow commands
- Use 'CRITICAL' callouts and 'DO NOT PROCEED' language for mandatory steps
- Self-correcting review stays inline in checkpointing.md (context-specific logic)

## Spec Changelog
- 15-01-2026: Initial spec from interview
- 15-01-2026: Revised after plan review - removed Full/Light distinction, clarified checkpointing.md scope, added unit dependencies, clarified compound behavior as prompted
