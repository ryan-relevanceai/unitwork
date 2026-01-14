---
name: uw:work
description: Execute the plan with checkpoint-based verification at every verifiable boundary
argument-hint: "[spec file path or empty to auto-detect]"
---

# Execute implementation with Unit Work checkpoints

## Introduction

**Note: The current year is 2026.**

Unit Work execution implements the plan with checkpoints at every verifiable boundary. Checkpoints are commits with verification documents that invite human review when confidence is below 95%.

## When to Checkpoint (Mandatory)

A checkpoint is required after ANY of these events:
- Completing a unit from the spec
- Fixing an issue found during verification
- Implementing user feedback or corrections
- Any code change, no matter how small

**There is no "minor change" exemption.** If code was modified, it gets checkpointed.

## Spec Location

<spec_path> #$ARGUMENTS </spec_path>

**If empty:** Check `.unitwork/specs/` for in-progress specs, read the most recent one.

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before resume detection. Before reading the spec in detail. Before anything else.**

Memory recall is the foundation of compounding. Without it, you lose all accumulated learnings from past sessions and will repeat mistakes that have already been documented.

> **If you skip this:** You may recreate bugs that were already fixed, miss patterns the team learned to avoid, or ignore cross-cutting concerns (like versioning rules) that are documented in memory.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall gotchas and learnings BEFORE any other work (handles worktrees)
hindsight memory recall "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "gotchas and learnings for <feature-type>" --budget mid --include-chunks
```

### Display Learnings

After recall, ALWAYS display relevant learnings before proceeding:

```
**Relevant Learnings from Memory:**
- {gotcha or pattern from memory}
- {another relevant learning}
- {any cross-cutting concerns like versioning, changelog, etc.}
```

If no relevant learnings are found, explicitly state: "Memory recall complete - no relevant learnings found for this task type."

**DO NOT PROCEED to resume detection or implementation until memory recall is complete and learnings are surfaced.**

---

## Resume Detection

Before starting, check for existing work:

```bash
# Check for existing checkpoints
git log --oneline | grep "checkpoint(" | head -5

# Check verification docs
ls -la .unitwork/verify/ 2>/dev/null
```

If checkpoints exist, query Hindsight for progress:

```bash
hindsight memory recall "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "progress on <feature>" --budget low
```

Report resume status:
- Which units are complete
- Which is next
- Any pending human feedback

## Implementation Rules

1. **Follow the spec** - The spec is the contract, don't add features not in spec
2. **Minimal changes** - Smallest diff that satisfies the requirement
3. **No drive-by refactoring** - Note tech debt, don't fix it
4. **No drive-by bug fixes** - Unless critical and blocking
5. **Checkpoint at boundaries** - Every verifiable unit gets a checkpoint
6. **Document uncertainty** - If unsure, say so in checkpoint
7. **Never skip verification** - Even if confident, run subagents
8. **Never ask permission to checkpoint** - Checkpoints are mandatory, not optional

**CRITICAL: Checkpoints are git commits, not suggestions.**
- NEVER say "would you like me to commit?" - just commit
- NEVER treat follow-up fixes as casual changes - they get checkpoints too
- ALL code changes during a work session get checkpointed
- The checkpoint process (verify → document → commit) is non-negotiable

## For Each Unit

### Step 1: Implement

Work through the unit's changes as specified in the spec.

**If you encounter unfamiliar framework APIs**, query Context7 before guessing:

```
mcp__unitwork_context7__resolve-library-id
  query: "<what you're trying to implement>"
  libraryName: "<framework>"

mcp__unitwork_context7__query-docs
  libraryId: "<id from above>"
  query: "<specific API or pattern>"
```

This ensures implementations follow official patterns rather than guessed approaches.

### Step 2: Verify

Launch appropriate verification subagents based on what changed:

**Changed test files?**
- Launch `test-runner` agent

**Changed API endpoints?**
- Launch `test-runner` agent
- Launch `api-prober` agent (read-only without permission, mutating requires confirmation)

**Changed UI components?**
- Launch `test-runner` agent
- Launch `browser-automation` agent (screenshots + element verification)

**Changed database schema/migrations?**
- Launch `test-runner` only
- NEVER run migrations automatically
- Flag for human verification

### Step 3: Calculate Confidence

Start at 100%, subtract for uncertainties:
- -5% for each untested edge case
- -20% if UI layout changes
- -10% if complex state management
- -15% if external API integration

### Step 4: Create Checkpoint

**Checkpoint Commit Format:**

```
checkpoint({unit-number}): {brief description}

Unit: {unit-name from plan}
Confidence: {percentage}%
Verification: {test-runner|api-prober|browser|manual}

See: .unitwork/verify/{DD-MM-YYYY}-{checkpoint-number}-{short-name}.md
```

**Verification Document:**

Create `.unitwork/verify/{DD-MM-YYYY}-{checkpoint-number}-{short-name}.md`:

```markdown
# Checkpoint: {checkpoint-name}

## Verification Strategy
What approach was used to verify this work

## Subagents Launched
- List of verification subagents and their findings

## Confidence Assessment
- Confidence level: {percentage}%
- Rationale: Why this confidence level

## Learnings
- What was discovered during implementation
- Any patterns worth remembering

## Human QA Checklist

### Prerequisites
How to get the app into the required state for testing

### Verification Steps
- [ ] Step 1: {action} -> Expected: {outcome}
- [ ] Step 2: {action} -> Expected: {outcome}

### Notes
Any special considerations or areas of uncertainty
```

### Step 5: Continue or Pause

**Confidence >= 95%:**
```
Checkpoint {n}: {description}

Verification:
- Tests: {X} passed
- {other verification results}

Confidence: {X}%
Continuing to next unit...
```

**Confidence < 95%:**
```
Checkpoint {n}: {description}

Verification:
- Tests: {X} passed
- {other verification results}
- Screenshots saved to .unitwork/verify/{date}-{n}-{name}.md

Confidence: {X}%
Reason: {why confidence is lower}

**Please review:**
- [ ] {specific item to verify}
- [ ] {specific item to verify}

I can continue working while you review, but will incorporate any feedback.
```

## Handling Feedback

**CRITICAL: User feedback during a work session is NOT a casual request - it triggers the full checkpoint workflow.**

When user provides feedback on a checkpoint:

1. **Acknowledge the gap**: "You're right - [description of issue]"
2. **Document the blind spot**: What verification missed and why
3. **Fix the issue**: Implement the correction
4. **Create fix checkpoint** (MANDATORY): `checkpoint({n}.1): {fix description}`
   - Create verification document at `.unitwork/verify/{date}-{n}.1-{name}.md`
   - Commit with checkpoint format
   - Do NOT ask "would you like me to commit?" - just do it
5. **Retain learning**:

```bash
hindsight memory retain "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "Verification blind spot: <what was missed>. Similar patterns need <specific check>." \
  --context "verification learning" \
  --doc-id "learn-<feature-name>" \
  --async
```

## Decision Making During Implementation

**Is this decision covered by the spec?**
- YES -> Follow spec, decide autonomously

**Is this a pure implementation detail?**
- YES -> Decide autonomously, follow codebase conventions

**Does this affect architecture or UX?**
- YES -> STOP and ask user

**Could this decision be wrong and hard to reverse?**
- YES -> STOP and ask user
- NO -> Decide autonomously, note in checkpoint

## Completion

After all units complete:

```
All units implemented and verified.

**Checkpoints:**
- checkpoint(1): {description} - {confidence}%
- checkpoint(2): {description} - {confidence}%
...

Ready for code review with /uw:review
```
