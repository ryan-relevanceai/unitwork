---
name: uw:review
description: Run exhaustive multi-agent parallel code review with taxonomy-based findings
argument-hint: "[origin: branch|pr <number>|area <path>] [base: main]"
---

# Exhaustive code review with parallel specialist agents

## Introduction

**Note: The current year is 2026.**

Unit Work review spawns 7 parallel specialist agents to perform exhaustive code review. Reviews are taxonomy-based, mapping findings to 47 known issue patterns with tier-based severity ranking.

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before loading skills. Before reviewing any code. Before anything else.**

Memory recall is the foundation of compounding. Without it, you lose all accumulated learnings from past reviews and will miss patterns your team has already learned.

> **If you skip this:** You will miss reviewing for issues that caused bugs in past PRs. The review-standards skill has patterns, but memory has which ones your team actually hit.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall review-related learnings BEFORE any other work (handles worktrees)
hindsight memory recall "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "code review learnings, past mistakes, type safety issues, security issues, pattern violations" --budget mid --include-chunks
```

### Display Learnings

After recall, display relevant learnings:

```
**Relevant Learnings from Memory:**
- {past review finding or gotcha}
- {pattern violation discovered before}
```

If no relevant learnings found: "Memory recall complete - no relevant learnings found for this review."

### Route Learnings to Agents

Include recalled memories in each review agent's context based on domain:

| Memory Topic | Route To Agent |
|--------------|----------------|
| Type safety, casting, null handling | type-safety |
| Security vulnerabilities, auth issues | security |
| Patterns, utilities, duplication | patterns-utilities |
| Performance, database, queries | performance-database |
| Architecture, file organization | architecture |
| Complexity, over-engineering | simplicity |
| General gotchas | All agents |

This ensures past mistakes inform current reviews without relying on agent knowledge alone.

**DO NOT PROCEED to Required Reading until memory recall is complete.**

---

## Required Reading

**Before reviewing, load the `review-standards` skill which contains:**

- 47 issue patterns with detection criteria and severity tiers
- Team standards to enforce
- Implementation checklists

The skill provides the taxonomy reference needed for categorizing findings.

## Determine Review Origin

Parse the arguments to determine what to review:

**Branch Diff (default):**
```bash
# uw:review [base-branch]
BASE_BRANCH="${1:-main}"
git diff $BASE_BRANCH...HEAD --stat
git diff $BASE_BRANCH...HEAD
```

When using branch diff mode, check if a PR exists for the current branch:
```bash
CURRENT_BRANCH=$(git branch --show-current)
gh pr list --head "$CURRENT_BRANCH" --json number,title,url
```

**If PR exists:** Prompt user: "Found PR #{number}: {title}. Review PR or branch diff?"
- **Review PR** - Switch to PR Review mode
- **Review branch diff** - Continue with branch diff

**PR Review:**
```bash
# uw:review pr <number>
# OR
# uw:review pr (auto-detect)
```

**If `pr` is specified WITHOUT a number:** Auto-detect PR by current branch:
```bash
CURRENT_BRANCH=$(git branch --show-current)
gh pr list --head "$CURRENT_BRANCH" --json number,title,url
```

- **If single PR found:** Confirm: "Found PR #{number}: {title}. Review this?"
  - If user confirms: Proceed with PR review
  - If user declines: Ask for PR number manually
- **If multiple PRs found:** Present list and ask user to select
- **If no PR found:** Ask for PR number manually

**If PR number is provided:**
```bash
gh pr view $PR_NUMBER --json title,body,files,additions,deletions
gh pr diff $PR_NUMBER
```

**Codebase Area Audit:**
```bash
# uw:review area <dir_path>
# Review all files in a directory/pattern
find "$AREA_PATH" -type f \( -name "*.ts" -o -name "*.py" -o -name "*.rb" \)
```

## Severity Tiers

Issues are categorized into two tiers that affect priority ranking:

### Tier 1 - Correctness (Always Higher Priority)
Issues affecting whether code works correctly:
- Security vulnerabilities
- Architecture problems (wrong boundaries, circular deps)
- Implementation bugs (incorrect logic, runtime errors)
- Type safety violations (casting that hides bugs)
- Functionality gaps (missing error handling, edge cases)

### Tier 2 - Cleanliness (Lower Priority)
Issues affecting maintainability but not correctness:
- Naming clarity
- File organization
- Code duplication (when not causing bugs)
- Comment quality
- Import/style consistency

**At the same P-level, Tier 1 issues must be addressed before Tier 2 issues.**

## Severity Definitions

| Level | Tier 1 (Correctness) | Tier 2 (Cleanliness) |
|-------|---------------------|---------------------|
| P1 CRITICAL | Security vuln, arch causing bugs, runtime errors | (Rare) Cleanliness issue causing production confusion |
| P2 IMPORTANT | Type casting, incomplete guards, boundary violations | Significant duplication, wrong file location |
| P3 NICE-TO-HAVE | Minor edge cases, defensive improvements | Naming nits, comment additions, style consistency |

## Spawn Parallel Review Agents

Launch all 7 review agents in parallel with the diff context. Each agent should reference the issue patterns taxonomy.

1. **type-safety** - TYPE_SAFETY_IMPROVEMENT, UNNECESSARY_CAST, NULL_HANDLING
2. **patterns-utilities** - EXISTING_UTILITY_AVAILABLE, CODE_DUPLICATION, BETTER_IMPLEMENTATION_APPROACH
3. **performance-database** - DATABASE_INDEX_MISSING, PARALLELIZATION_OPPORTUNITY, PERFORMANCE_OPTIMIZATION
4. **architecture** - ARCHITECTURAL_CONCERN, FILE_ORGANIZATION, WRONG_LOCATION
5. **security** - INJECTION_VULNERABILITY, AUTHENTICATION_BYPASS, AUTHORIZATION_BYPASS, SENSITIVE_DATA_EXPOSURE
6. **simplicity** - REDUNDANT_LOGIC, REMOVE_UNUSED_CODE, CONSOLIDATE_LOGIC
7. **memory-validation** - MEMORY_LEARNING_VIOLATION (receives ALL learnings, not domain-filtered)

**Include recalled context in agent prompts:**

When spawning agents, include any relevant memories from Context Recall:

```markdown
**Past Learnings (from team memory):**
- {learning 1 relevant to this agent's domain}
- {learning 2}

Watch for these patterns based on past issues.
```

This ensures agents are informed by past mistakes. For example, if there's a memory about "type guard examples must not use casting", the type-safety agent receives it and can catch similar issues.

Each agent returns findings in this format:

```markdown
### [PATTERN_NAME] - Severity: P1/P2/P3 - Tier: 1/2

**Location:** `file:line`

**Issue:** What's wrong

**Why:** Link to pattern from issue-patterns.md

**Fix:**
// Before
problematic code

// After
fixed code
```

## Finding Verification (Critical)

**Agents are not oracles.** Their findings are hypotheses that must be verified before presenting to the user.

For each finding from the review agents:

1. **Check factual accuracy**: Does the claim hold up?
   - "Utility exists at X" → Actually read the file, confirm it exists and does what's claimed
   - "Pattern violation" → Verify the pattern actually applies to this context
   - "Security issue" → Confirm the vulnerability is real and exploitable

2. **Check scope relevance**: Is this finding in-scope for the current review?
   - A real issue but unrelated to this change → Dismiss (note for existing code section)
   - A stylistic preference vs actual problem → Dismiss
   - Pre-existing issue not introduced by this change → Move to "Existing Code Issues"

3. **Classify the finding**:
   - **VERIFIED**: Factually correct and in-scope → Include in review
   - **DISMISSED**: False positive or out of scope → Document rationale, don't include in main review

**Only VERIFIED findings are presented to the user for action.**

Document verification decisions internally:
```markdown
### Finding: {original finding summary}
**Agent:** {type-safety|patterns-utilities|etc.}
**Original Severity:** P1/P2/P3
**Verification Status:** VERIFIED | DISMISSED
**Rationale:** {why this was verified or dismissed}
**Action:** {what will be done, or "none - dismissed"}
```

This verification step prevents wasting user time on false positives and ensures all presented findings are actionable.

## Classify Findings by Scope

Cross-reference each finding with the diff to classify scope:

- **PR Change** - Issue is in code added/modified by this change (appears in diff with `+` prefix)
- **Existing Code** - Issue predates this change (context lines, surrounding code)

PR authors must address issues in their changes. Existing code issues are informational.

## Generate Review Document

Create `.unitwork/review/{DD-MM-YYYY}-{feature-name}.md`:

```markdown
# Code Review: {Feature Name}

## Summary
- P1 Issues: {count} ({tier1_count} correctness, {tier2_count} cleanliness)
- P2 Issues: {count}
- P3 Issues: {count}

## P1 - Critical Issues (Tier 1 first, then Tier 2)

### Correctness Issues
{List all P1 Tier 1 findings}

### Cleanliness Issues
{List all P1 Tier 2 findings}

## P2 - Important Issues

### Correctness Issues
{List all P2 Tier 1 findings}

### Cleanliness Issues
{List all P2 Tier 2 findings}

## P3 - Nice-to-Have

{List all P3 findings}

## Existing Code Issues (Informational)
Issues found in code that predates this change. Not blocking, but worth noting:
{List with file:line and brief description}

## What's Good
{Positive observations - following patterns, good structure, etc.}

## Review Status
- [ ] All P1s resolved
- [ ] P2s addressed or explicitly deferred
- [ ] P3s documented for future consideration
```

## Fix Loop

### For P1 Issues (Ordered by Tier)

Fix Tier 1 (correctness) P1 issues first, then Tier 2 (cleanliness) P1 issues:

1. Present each P1 issue to user, starting with Tier 1
2. **Research the correct fix** - If unsure about best practice, query Context7:
   ```
   mcp__unitwork_context7__resolve-library-id
     query: "<issue type, e.g., 'secure password hashing'>"
     libraryName: "<relevant framework>"

   mcp__unitwork_context7__query-docs
     libraryId: "<from above>"
     query: "<specific fix pattern>"
   ```
3. **If fix approach is unclear after research:** Trigger interview loop.

   See [interview-workflow.md](../skills/unitwork/references/interview-workflow.md) for question patterns.

   Present to user via AskUserQuestion:
   - **Clarify fix approach** - Answer questions about expected behavior
   - **Skip this issue** - Defer to manual fix later
   - **Accept current implementation** - Issue is acceptable as-is

   After interview, re-run gap-detector to validate fix approach is clear before implementing.

4. Implement the fix
5. Create new checkpoint: `checkpoint({n}+1): fix {issue}`
6. Re-run affected review agents on fixed code
7. Repeat until no P1s remain

### For P2/P3 Issues

After P1s are resolved, present remaining issues:

```
P1 issues resolved.

Remaining issues:

**P2 - IMPORTANT (Correctness):**
1. {issue description}

**P2 - IMPORTANT (Cleanliness):**
1. {issue description}

**P3 - NICE-TO-HAVE:**
1. {issue description}

What would you like to do?
```

Use AskUserQuestion:
- **Fix P2s now** - Implement P2 fixes
- **Defer P2s** - Document and continue
- **Fix specific issues** - Select which to fix
- **Continue to PR** - Accept current state

## Re-Review Protocol

After fixes, re-run only the affected review agents:

- If type issue fixed -> re-run type-safety
- If pattern issue fixed -> re-run patterns-utilities
- If performance issue fixed -> re-run performance-database
- If architecture issue fixed -> re-run architecture
- If security issue fixed -> re-run security
- If simplicity issue fixed -> re-run simplicity
- If memory learning violation fixed -> re-run memory-validation

Continue until review is clean or user accepts state.

## Completion

When review is complete:

```
Code review complete.

**Final Status:**
- P1: 0 remaining (all fixed)
- P2: {X} fixed, {Y} deferred
- P3: {Z} noted for future

Patterns found: {list of PATTERN_NAMEs}

Review document: .unitwork/review/{date}-{feature}.md

Ready for PR creation. The /uw:compound phase will run automatically to capture learnings.
```

## Trigger Compound Phase

After review completion, automatically invoke `/uw:compound` to capture learnings before creating PR.

## Quick Pattern Reference

**Most common issues to watch for:**
1. BETTER_IMPLEMENTATION_APPROACH (18%) - Search first
2. TYPE_SAFETY_IMPROVEMENT (12%) - No casting
3. EXISTING_UTILITY_AVAILABLE (10%) - Check utilities
4. CODE_DUPLICATION (8%) - Look for existing
5. NULL_HANDLING (6%) - Use null, not ""

**Always P1 (Security):**
- INJECTION_VULNERABILITY
- AUTHENTICATION_BYPASS
- AUTHORIZATION_BYPASS
- XSS_VULNERABILITY
