---
name: uw:action-comments
description: Bulk resolve GitHub PR comments using checkpoint-based verification flow
argument-hint: "<PR number>"
---

# Resolve PR review comments

## Introduction

**Note: The current year is 2026.**

This command fetches PR comments, independently verifies each one, and implements confirmed fixes with full checkpoint workflow. Each VALID_FIX gets its own checkpoint commit with verification.

## PR Detection

<pr_number> #$ARGUMENTS </pr_number>

**If empty or not a number:** Auto-detect PR by current branch:

```bash
CURRENT_BRANCH=$(git branch --show-current)
gh pr list --head "$CURRENT_BRANCH" --json number,title,url
```

**If single PR found:** Confirm with user: "Found PR #{number}: {title}. Use this?"
- If user confirms: Use this PR
- If user declines: Ask for PR number manually

**If multiple PRs found:** Present list and ask user to select

**If no PR found:** Ask for PR number manually

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before fetching comments. Before reading any code. Before anything else.**

Memory recall is the foundation of compounding. Without it, you lose all accumulated learnings from past sessions and will repeat mistakes that have already been documented.

> **If you skip this:** You may miss review patterns the team learned, make the same fix mistakes twice, or forget cross-cutting concerns documented in memory.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall PR review patterns and gotchas BEFORE any other work (handles worktrees)
hindsight memory recall "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "PR review patterns, comment resolution gotchas, code review learnings" --budget mid --include-chunks
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

**DO NOT PROCEED to fetching comments until memory recall is complete and learnings are surfaced.**

---

## Step 1: Fetch PR Comments

```bash
gh pr view $PR_NUMBER --json comments,reviews
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments
```

Parse comments to extract:
- File and line references
- Comment content
- Author
- Whether it's a question, suggestion, or request

## Step 2: Find Related Spec

Check `.unitwork/specs/` for the spec that corresponds to this PR's changes:

```bash
# Get files changed in PR
gh pr diff $PR_NUMBER --name-only

# Match to spec based on feature name or files
ls .unitwork/specs/
```

Read the spec to understand original requirements.

## Step 3: Independently Verify Each Comment

For each comment, perform independent verification:

### Comment Types

**Request for change:**
```
Comment: "This should handle null emails"

Verification:
1. Read the code at the specified location
2. Check if the concern is valid
3. If valid: Create fix plan
4. If already handled: Prepare clarification reply
```

**Question:**
```
Comment: "Why did you use this pattern?"

Verification:
1. Read the code and context
2. Check spec for rationale
3. Prepare explanation reply
```

**Suggestion:**
```
Comment: "Consider using bcrypt here"

Verification:
1. Check what's currently used
2. If already using it: Prepare clarification
3. If different approach: Evaluate and decide
```

### Verification Categories

For each comment, categorize:

- **VALID_FIX**: Concern is valid, needs fix → Gets checkpoint
- **ALREADY_HANDLED**: Code already addresses this → Reply only
- **QUESTION**: Needs explanation, no fix → Reply only
- **DEFER**: Valid but out of scope for this PR → Document only
- **DISAGREE**: Reviewer concern is incorrect → Reply with explanation

## Step 4: Present Findings

```
PR #{PR_NUMBER} - {X} comments analyzed

**Will Fix ({count}):**
1. {file}:{line} - {summary of fix}
2. {file}:{line} - {summary of fix}

**Already Handled ({count}):**
1. {file}:{line} - Will reply with clarification
   Current code: {brief explanation}

**Need to Reply ({count}):**
1. {file}:{line} - Question about {topic}

**Defer ({count}):**
1. {file}:{line} - Out of scope: {reason}

Proceed with fixes?
```

Use AskUserQuestion:
- **Fix all** - Implement all fixes with checkpoints
- **Review each** - Go through fixes one by one
- **Skip fixes, just reply** - Only post clarifications

## Step 4.5: Plan-Verify Before Fixes

Before implementing any VALID_FIX items, run gap-detector once for all fixes collectively:

```
Task tool with subagent_type="unitwork:plan-review:gap-detector"
prompt: "Review these PR comment fixes for information gaps:

VALID_FIX items:
<list of VALID_FIX items from Step 4>

For each fix, check for:
- Missing context (what exactly needs to change?)
- Unclear scope (which files/functions?)
- Edge cases not addressed in the comment

Report any P1 or P2 gaps that would block implementation."
```

**If P1/P2 gaps found:** Present to user via AskUserQuestion:
- **Address gaps now** - Clarify before implementing
- **Proceed anyway** - May need to ask during implementation

**If no gaps or only P3:** Proceed to Step 5.

## Step 5: Implement Fixes (Checkpoint Per Fix)

For each VALID_FIX item:

### 5.1 Implement the Fix

1. Read the file
2. Implement the change

### 5.2 Verify

Launch appropriate verification subagents based on what changed. See [verification-flow.md](../skills/unitwork/references/verification-flow.md#which-verification-subagent-to-use) for guidance:

- **Changed test files?** → Launch `test-runner`
- **Changed API endpoints?** → Launch `test-runner` + `api-prober`
- **Changed UI components?** → Launch `test-runner` + invoke `agent-browser` skill

### 5.3 Calculate Confidence

Start at 100%, subtract for uncertainties:
- -5% for each untested edge case
- -20% if UI layout changes
- -10% if complex state management
- -15% if external API integration

### 5.4 Create Checkpoint

**Checkpoint format for PR comment fixes:**

```
checkpoint(pr-{PR_NUMBER}-{fix_number}): {brief description}

PR: #{PR_NUMBER}
Comment: {comment summary}
Confidence: {percentage}%
Verification: {test-runner|api-prober|browser|manual}

See: .unitwork/verify/{DD-MM-YYYY}-pr-{PR}-{fix_number}-{short-name}.md
```

Create verification document at `.unitwork/verify/{DD-MM-YYYY}-pr-{PR}-{fix_number}-{short-name}.md` using [templates/verify.md](../skills/unitwork/templates/verify.md).

### 5.5 Self-Correcting Review

Apply the self-correcting review protocol from [verification-flow.md](../skills/unitwork/references/verification-flow.md#self-correcting-review-fix-checkpoints-only):

1. **Risk Assessment** - Determine if review is needed based on change size
2. **Selective Agent Invocation** - Spawn relevant review agent(s) if needed
3. **Cycle Handling** - If new issues found, fix and checkpoint again (max 3 cycles)

### 5.6 Continue or Pause

**Confidence >= 95%:** Continue to next fix.

**Confidence < 95%:** Present for review, then continue.

## Step 6: Commit Clarifications

After all VALID_FIX items are checkpointed, create a single commit for non-fix clarifications:

```
docs: clarifications for PR #{PR_NUMBER} review comments

- {ALREADY_HANDLED item 1}
- {QUESTION reply 1}
- {DISAGREE explanation 1}
```

This commit contains no code changes, only documentation of responses.

## Step 7: Post Replies

For comments that need clarification (not fixes):

```bash
# Reply to already-handled concerns
gh pr comment $PR_NUMBER --body "Thanks for the review! This is already handled because..."

# Reply to questions
gh pr comment $PR_NUMBER --body "Good question! The reason for this pattern is..."

# Reply to disagreements
gh pr comment $PR_NUMBER --body "I considered this, but decided against it because..."
```

## Step 8: Compound Phase Prompt

After all fixes are complete:

```
All comment fixes complete.

**Checkpoints created:**
- checkpoint(pr-{PR}-1): {description}
- checkpoint(pr-{PR}-2): {description}
...

Run /uw:compound to capture learnings from this PR review cycle?
```

Use AskUserQuestion:
- **Yes** - Run /uw:compound now
- **No** - Skip compound phase
- **Later** - Remind me after push

## Step 9: Report and Push

```
Addressed {X}/{Y} comments on PR #{PR_NUMBER}

**Fixed ({count} checkpoints):**
- checkpoint(pr-{PR}-1): {summary}
- checkpoint(pr-{PR}-2): {summary}

**Clarified ({count}):**
- {count} replies posted explaining existing code

**Deferred ({count}):**
- {count} noted for future work

Push changes and request re-review?
```

Use AskUserQuestion:
- **Push and request review** - `git push && gh pr ready`
- **Push only** - Just push changes
- **Review changes first** - Show diff before pushing
