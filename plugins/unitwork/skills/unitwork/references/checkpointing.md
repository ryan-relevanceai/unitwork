# Checkpointing Reference

This document is the single source of truth for checkpoint-related protocols in Unit Work.

## Checkpoint Commit Format

```
checkpoint({unit-number}): {brief description}

Unit: {unit-name from plan}
Confidence: {percentage}%
Verification: {test-runner|api-prober|browser|manual}

See: .unitwork/verify/{DD-MM-YYYY}-{checkpoint-number}-{short-name}.md
```

**For PR comment fixes**, use this numbering:
```
checkpoint(pr-{PR_NUMBER}-{fix_number}): {brief description}
```

Example: `checkpoint(pr-123-1): handle null email addresses`

## When to Checkpoint

See [decision-trees.md](./decision-trees.md#when-to-checkpoint) for the complete decision flow.

**Summary:** A checkpoint is required after ANY code change:
- Completing a unit from the spec
- Fixing an issue found during verification
- Implementing user feedback or corrections
- Any code change, no matter how small

**There is no "minor change" exemption.**

## Verification Document

Create `.unitwork/verify/{DD-MM-YYYY}-{checkpoint-number}-{short-name}.md` using the template at [templates/verify.md](../templates/verify.md).

**CRITICAL: Minimize human review.** If you can verify something with 100% certainty (grep, read, test output), verify it yourself and list in "AI-Verified". Only put items in "Human QA Checklist" that genuinely require human judgment.

## Self-Correcting Review (Fix Checkpoints Only)

**This section ONLY applies to fix checkpoints** (e.g., `checkpoint(2.1)`, `checkpoint(3.2)`, `checkpoint(pr-123-1)`). Skip this for regular unit checkpoints.

When you create a fix checkpoint, the fix itself may introduce new issues. Before continuing, assess whether the fix needs re-review.

### Risk Assessment (Fast - No Agent Spawning)

Analyze the fix diff to determine review intensity:

**No Review Needed** - ALL conditions must be true:
- <=3 lines changed
- File matches low-risk patterns: `*.test.*, *.spec.*, *.md, *.json, *.yaml, *.yml, *.config.*`
- Pure additions (no deletions)

**Light Review** - ANY condition true:
- 4-30 lines changed
- Single file in `src/` or main code directory
- Changes with <5 deletions

**Full Review** - ANY condition true:
- >30 lines changed
- >3 files modified
- >10 lines deleted
- Security-related file patterns (auth, crypto, permissions)

### Selective Agent Invocation

Based on the type of issue being fixed, spawn only the relevant review agent(s):

| Original Issue Type | Re-Review Agent |
|---------------------|-----------------|
| Type safety issue | `type-safety` |
| Pattern/utility issue | `patterns-utilities` |
| Performance issue | `performance-database` |
| Architecture issue | `architecture` |
| Security issue | `security` |
| Simplicity issue | `simplicity` |

**For mixed fix types** (fix addresses multiple categories): Spawn ALL relevant agents.

**Scope-guard for review agents:** When spawning agents to review a fix, include this context:

> "You are reviewing a FIX to a specific issue. DO NOT suggest additional refactoring beyond the fix. DO NOT expand scope. Only verify the fix addresses the original issue without introducing new problems."

### Cycle Handling

**If re-review finds no new issues:** Continue to next unit/step.

**If re-review finds new issues:** Present to user via AskUserQuestion:
- **Fix the new issue** - Implement fix and create another fix checkpoint (triggers another cycle)
- **Accept and continue** - Break cycle, proceed with current state
- **Revert fix** - Execute `git reset --soft HEAD~1` to unstage, let user review

**Hard limit: 3 cycles maximum.** After 3 fix-review cycles on the same original issue:

```
Fix-review cycle limit reached (3 iterations).

**Attempts made:**
1. {first fix attempt and result}
2. {second fix attempt and result}
3. {third fix attempt and result}

**Recommendation:** {continue manually | accept current state | revert to pre-fix}

What would you like to do?
```

Use AskUserQuestion with options:
- **Continue manually** - User takes over fixing
- **Accept current state** - Proceed with existing fixes
- **Revert all fixes** - Execute `git reset --soft HEAD~{n}` to revert fix attempts

## Confidence Calculation

Start at 100%, subtract for uncertainties:
- -5% for each untested edge case
- -20% if UI layout changes
- -10% if complex state management
- -15% if external API integration

### Confidence Thresholds

**Confidence >= 95%:** Continue automatically to next unit.

**Confidence < 95%:** Pause for human review. Present:
- What was verified
- What needs human judgment
- Specific items to check
