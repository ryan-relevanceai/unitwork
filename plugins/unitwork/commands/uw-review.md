---
name: uw:review
description: Run exhaustive multi-agent parallel code review before finalizing work
argument-hint: "[base branch, default: main]"
---

# Exhaustive code review with parallel specialist agents

## Introduction

**Note: The current year is 2026.**

Unit Work review spawns 6 parallel specialist agents to perform exhaustive code review. The review iterates until all critical issues are resolved.

## Gather Changes

```bash
BASE_BRANCH="${1:-main}"
git diff $BASE_BRANCH...HEAD --stat
git diff $BASE_BRANCH...HEAD
```

## Spawn Parallel Review Agents

Launch all 6 review agents in parallel with the diff context:

1. **type-safety** - Casting, guards, nullability, `as` usage, `any` types
2. **patterns-utilities** - Reimplementing existing code, missing patterns
3. **performance-database** - N+1 queries, missing indexes, sequential operations
4. **architecture** - Wrong locations, tight coupling, bad boundaries
5. **security** - Injection, auth bypasses, data exposure, OWASP top 10
6. **simplicity** - Over-engineering, premature abstraction, unnecessary complexity

Each agent returns findings in this format:

```markdown
### [PATTERN_NAME] - Severity: P1/P2/P3

**Location:** `file:line`

**Issue:** What's wrong

**Why:** Why this matters

**Fix:**
// Before
problematic code

// After
fixed code
```

## Severity Definitions

| Level | Definition | Action |
|-------|------------|--------|
| P1 CRITICAL | Blocks merge, breaks production | MUST fix before PR |
| P2 IMPORTANT | High potential for issues later | SHOULD fix before PR |
| P3 NICE-TO-HAVE | Code smell, not blocking | CAN defer to future |

## Generate Review Document

Create `.unitwork/review/{DD-MM-YYYY}-{feature-name}.md`:

```markdown
# Code Review: {Feature Name}

## Summary
- P1 Issues: {count}
- P2 Issues: {count}
- P3 Issues: {count}

## P1 - Critical Issues

{List all P1 findings}

## P2 - Important Issues

{List all P2 findings}

## P3 - Nice-to-Have

{List all P3 findings}

## Review Status
- [ ] All P1s resolved
- [ ] P2s addressed or explicitly deferred
- [ ] P3s documented for future consideration
```

## Fix Loop

### For P1 Issues (Auto-fix)

1. Present each P1 issue to user
2. **Research the correct fix** - If unsure about best practice, query Context7:
   ```
   mcp__unitwork_context7__resolve-library-id
     query: "<issue type, e.g., 'secure password hashing'>"
     libraryName: "<relevant framework>"

   mcp__unitwork_context7__query-docs
     libraryId: "<from above>"
     query: "<specific fix pattern>"
   ```
3. Implement the fix
4. Create new checkpoint: `checkpoint({n}+1): fix {issue}`
5. Re-run affected review agents on fixed code
6. Repeat until no P1s remain

### For P2/P3 Issues

After P1s are resolved, present remaining issues:

```
P1 issues resolved.

Remaining issues:

**P2 - IMPORTANT:**
1. {issue description}
2. {issue description}

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

Continue until review is clean or user accepts state.

## Completion

When review is complete:

```
Code review complete.

**Final Status:**
- P1: 0 remaining (all fixed)
- P2: {X} fixed, {Y} deferred
- P3: {Z} noted for future

Review document: .unitwork/review/{date}-{feature}.md

Ready for PR creation. The /uw:compound phase will run automatically to capture learnings.
```

## Trigger Compound Phase

After review completion, automatically invoke `/uw:compound` to capture learnings before creating PR.
