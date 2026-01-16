# Code Review: /uw:fix-conflicts Command

## Summary
- P1 Issues: 0
- P2 Issues: 4 (2 correctness, 2 cleanliness)
- P3 Issues: 2

## P1 - Critical Issues

None.

## P2 - Important Issues

### Correctness Issues (Tier 1)

### [BETTER_IMPLEMENTATION_APPROACH] - Severity: P2 - Tier: 1

**Location:** `plugins/unitwork/agents/conflict-resolution/conflict-intent-analyst.md:1` and `conflict-impact-explorer.md:1`

**Issue:** Both new conflict-resolution agents are missing YAML frontmatter that ALL other 14 agents have.

**Why:** BETTER_IMPLEMENTATION_APPROACH - Not following established patterns. Without frontmatter, these agents may not integrate properly with the Task tool invocation pattern.

**Fix:**
```markdown
// Before (conflict-intent-analyst.md)
# Conflict Intent Analyst

Analyze git merge/rebase conflicts...

// After
---
name: conflict-intent-analyst
description: "Use this agent to analyze the intent behind each branch's changes in a merge conflict."
model: inherit
---

# Conflict Intent Analyst

Analyze git merge/rebase conflicts...
```

Same fix needed for `conflict-impact-explorer.md`.

---

### [FILE_ORGANIZATION] - Severity: P2 - Tier: 1

**Location:** `plugins/unitwork/CLAUDE.md:166`

**Issue:** CLAUDE.md "Review Agents" section says "Six parallel specialists" but there are now 7 review agents (missing memory-validation.md from count and list).

**Why:** FILE_ORGANIZATION - Documentation drift causes confusion about actual plugin components. Memory learning confirmed: "CLAUDE.md directory tree tends to drift from reality when files are added."

**Fix:**
```markdown
// Before (line 166)
Six parallel specialists for code review:

// After
Seven parallel specialists for code review:
```

Also add `7. Memory Validation` to the list at lines 167-172.

---

### Cleanliness Issues (Tier 2)

### [FILE_ORGANIZATION] - Severity: P2 - Tier: 2

**Location:** `plugins/unitwork/CLAUDE.md:65-67`

**Issue:** Directory tree shows only 2 files in `skills/unitwork/references/` but there are actually 5 files.

**Why:** FILE_ORGANIZATION - Directory tree doesn't match actual structure.

**Current (lines 65-67):**
```
│       ├── references/
│       │   ├── checkpointing.md
│       │   └── decision-trees.md
```

**Should be:**
```
│       ├── references/
│       │   ├── checkpointing.md
│       │   ├── decision-trees.md
│       │   ├── hindsight-reference.md
│       │   ├── interview-workflow.md
│       │   └── verification-flow.md
```

---

### [FILE_ORGANIZATION] - Severity: P2 - Tier: 2

**Location:** `plugins/unitwork/CLAUDE.md:91-119`

**Issue:** Agent Organization section documents all agent categories except the new `conflict-resolution/` directory.

**Why:** FILE_ORGANIZATION - Missing documentation for new component category.

**Fix:** Add after line 103 (after plan-review section):

```markdown
### conflict-resolution/
Conflict analysis agents for `/uw:fix-conflicts`:
- `conflict-intent-analyst.md` - Analyze intent behind each branch's changes
- `conflict-impact-explorer.md` - Assess downstream impact of resolutions
```

---

## P3 - Nice-to-Have

### [EXISTING_UTILITY_AVAILABLE] - Severity: P3 - Tier: 2

**Location:** `plugins/unitwork/commands/uw-fix-conflicts.md:38` and `:443`

**Issue:** Memory recall/retain commands are missing ANSI stripping that hindsight-reference.md explicitly marks as "CRITICAL".

**Why:** The hindsight-reference.md states: "CRITICAL: Hindsight output contains ANSI color codes that must be stripped before processing."

**Fix:**
```bash
// Before
hindsight memory recall "$BANK" "query" --budget mid --include-chunks

// After
hindsight memory recall "$BANK" "query" --budget mid --include-chunks 2>&1 | sed 's/\x1b\[[0-9;]*m//g'
```

---

### [REDUNDANT_LOGIC] - Severity: P3 - Tier: 2

**Location:** `plugins/unitwork/commands/uw-fix-conflicts.md:269`

**Issue:** Auto-resolve condition checks both `confidence >80%` AND `NOT conflicting_goals`, but `conflicting_goals=true` already applies 20% penalty making confidence <=80%.

**Why:** REDUNDANT_LOGIC - The constraint is already enforced via the penalty calculation.

**Fix:** Consider simplifying to just `confidence >80%`. The second check is defensive but redundant.

---

## Existing Code Issues (Informational)

None - all issues are in code added by this PR.

## What's Good

1. **Agent count verified** - 16 agents matches actual count in agents/*/ directories
2. **Bank name derivation correct** - Uses `git config --get remote.origin.url` pattern, NOT `git rev-parse --show-toplevel`
3. **Memory routing follows patterns** - New agents reference hindsight-reference.md correctly
4. **Checkpoint workflow followed** - Verification document exists at `.unitwork/verify/16-01-2026-1-fix-conflicts-command.md`
5. **Version bump included** - 0.2.4 → 0.7.0 with CHANGELOG entry
6. **Directory tree mostly updated** - New conflict-resolution/ agents appear in CLAUDE.md tree

## Patterns Found

- BETTER_IMPLEMENTATION_APPROACH
- FILE_ORGANIZATION (4 instances)
- EXISTING_UTILITY_AVAILABLE
- REDUNDANT_LOGIC

## Review Status
- [x] All P1s resolved (none found)
- [x] P2s addressed
- [x] P3s documented for future consideration

## P2 Fixes Applied

1. Added YAML frontmatter to `conflict-intent-analyst.md`
2. Added YAML frontmatter to `conflict-impact-explorer.md`
3. Updated CLAUDE.md directory tree to show all 5 reference files
4. Added conflict-resolution section to CLAUDE.md Agent Organization
5. Updated CLAUDE.md review agents count from "Six" to "Seven"
6. Added memory-validation.md to review/ agent list
