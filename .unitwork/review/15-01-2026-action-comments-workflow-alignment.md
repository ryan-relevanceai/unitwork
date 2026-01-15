# Code Review: Action Comments Workflow Alignment

## Summary
- P1 Issues: 1 (1 correctness/cleanliness - documentation drift)
- P2 Issues: 1 (0 correctness, 1 cleanliness)
- P3 Issues: 5 (0 correctness, 5 cleanliness)

## P1 - Critical Issues

### Correctness Issues
None

### Cleanliness Issues (Tier 2)

### [FILE_ORGANIZATION] - P1 - Tier 2

**Location:** `plugins/unitwork/CLAUDE.md:60-62`

**Issue:** CLAUDE.md directory tree is outdated - missing the new `checkpointing.md` file in `references/` directory

**Why:** Team memory learning: "Documentation drift: CLAUDE.md directory tree can drift from reality when files are added... After adding new directories, always verify CLAUDE.md includes the new path"

**Verification:**
- CLAUDE.md shows only `decision-trees.md` in references/
- Actual directory contains: `checkpointing.md`, `decision-trees.md`

**Fix:**
```markdown
// Before (line 60-62)
│       ├── references/
│       │   └── decision-trees.md

// After
│       ├── references/
│       │   ├── checkpointing.md
│       │   └── decision-trees.md
```

## P2 - Important Issues

### Cleanliness Issues (Tier 2)

### [CODE_DUPLICATION] - P2 - Tier 2

**Location:** Multiple files

**Issue:** Confidence calculation rules are duplicated in 4 files:
- `uw-action-comments.md:160-165`
- `uw-work.md:147-151`
- `checkpointing.md:118-122`
- `SKILL.md:195-199`

**Why:** CODE_DUPLICATION - the consolidation goal was to have "single source of truth" but confidence calculation wasn't consolidated.

**Verification:** Confirmed via grep - 4 files contain "Start at 100%, subtract"

**Fix:** This is out-of-scope for the current PR as the confidence calculation existed in multiple places before this change. The new `checkpointing.md` has it as a reference, which is appropriate for a "checkpointing reference" document. Future work could consolidate further.

**Status:** DEFERRED - pre-existing duplication, not introduced by this PR.

## P3 - Nice-to-Have

### [CODE_DUPLICATION] - P3 - Tier 2
Memory Recall boilerplate duplicated across 5 command files. Intentionally verbose for emphasis. Could consolidate in future.

### [EXISTING_UTILITY_AVAILABLE] - P3 - Tier 2
`uw-action-comments.md:167-171` has inline verification subagent summary when decision-trees.md already has full guidance.

### [INJECTION_VULNERABILITY] - P3 - Tier 1 (Security)
Documented bash commands use shell substitution that could theoretically be vulnerable to command injection via malicious repo names. Mitigated by: documentation (not executable), git sanitization, rarity of shell metacharacters in repo names.

### [INJECTION_VULNERABILITY] - P3 - Tier 1 (Security)
`gh pr comment $PR_NUMBER` without numeric validation. Mitigated by: documentation, gh CLI validation.

### [REDUNDANT_LOGIC] - P3 - Tier 2
`uw-action-comments.md:186-195` includes inline checkpoint format example when checkpointing.md is the source of truth.

## Existing Code Issues (Informational)
None - all issues are related to changes in this PR.

## What's Good
- Consolidation goal achieved: checkpoint commit format now single-sourced in checkpointing.md
- uw-work.md reduced from ~250 lines to ~130 lines by referencing checkpointing.md
- uw-action-comments now follows full checkpoint workflow matching uw-work
- Relative paths are all correct and functional
- Good separation of concerns between references/ and templates/
- Memory Recall STEP 0 properly emphasizes mandatory nature

## Review Status
- [x] All P1s identified
- [ ] All P1s resolved (CLAUDE.md needs update)
- [x] P2s addressed or explicitly deferred
- [x] P3s documented for future consideration
