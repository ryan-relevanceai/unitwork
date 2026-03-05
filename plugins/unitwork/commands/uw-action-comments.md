---
name: uw:action-comments
description: Resolve PR review comments with feedback classification, checkpoint-based fixes, and PR description updates
argument-hint: "<PR number>"
---

# Resolve PR review comments

## Introduction

**Note: The current year is 2026.**

This command fetches PR comments, independently verifies each one, and implements confirmed fixes with full checkpoint workflow. Each SIMPLE_FIX gets its own checkpoint commit with verification.

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
# MANDATORY: Recall PR review patterns and gotchas BEFORE any other work (config override → git remote → worktree → pwd)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "PR review patterns, comment resolution gotchas, code review learnings" --budget mid --include-chunks
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

- **SIMPLE_FIX**: Concern is valid, contained to 1-2 files, no API changes → Gets checkpoint
- **REARCHITECTURE**: Valid but requires design-level changes or multi-file refactor → Escalate to user
- **ALREADY_HANDLED**: Code already addresses this → Reply only
- **QUESTION**: Needs explanation, no fix → Reply only
- **SCOPE_CREEP**: Valid request but outside this PR's scope → Offer to create issue
- **DEFER**: Valid but out of scope for this PR → Document only
- **DISAGREE**: Reviewer concern is incorrect → Reply with explanation

### SIMPLE_FIX vs REARCHITECTURE

**SIMPLE_FIX criteria** (ALL must be true):
- Change is contained to 1-2 files
- No public API/interface changes
- No new dependencies
- Doesn't contradict the original spec/plan
- You understand exactly what to change

**REARCHITECTURE signals** (ANY triggers escalation):
- Requires different design pattern
- Touches 3+ files
- Changes public interfaces
- Contradicts the spec
- Reviewer says "different approach" or "reconsider"

**If unsure → treat as REARCHITECTURE and escalate.**

### Scope Creep Detection

Watch for comments that expand scope beyond the PR's original intent:

**Triggers:**
- "While you're here, could you also..."
- Requests touching files unrelated to the PR's purpose
- Suggestions for "improvements" not in the original plan
- New features disguised as "polish"

Categorize these as **SCOPE_CREEP** and handle in Step 4.

### Conflicting Feedback

When two reviewers give contradictory feedback on the same code:

```
Conflicting feedback detected:

**Reviewer A ({username}):** "{quote}"
**Reviewer B ({username}):** "{opposite quote}"

These need human resolution before I can proceed.
```

Present via AskUserQuestion:
- **Follow Reviewer A** - Implement A's suggestion
- **Follow Reviewer B** - Implement B's suggestion
- **Ask reviewers to align** - Post a comment asking them to discuss

## Step 4: Present Findings

```
PR #{PR_NUMBER} - {X} comments analyzed

**SIMPLE_FIX ({count}):**
1. {file}:{line} - {summary of fix}
2. {file}:{line} - {summary of fix}

**REARCHITECTURE ({count}) — Needs your decision:**
1. {file}:{line} - "{reviewer feedback}"
   Impact: {files affected, scope of change}

**SCOPE_CREEP ({count}) — Out of PR scope:**
1. {file}:{line} - "{request}"
   Recommendation: Create issue to track separately

**Already Handled ({count}):**
1. {file}:{line} - Will reply with clarification

**Need to Reply ({count}):**
1. {file}:{line} - Question about {topic}

**Defer ({count}):**
1. {file}:{line} - Out of scope: {reason}
```

### Handle REARCHITECTURE Items

For each REARCHITECTURE item, present via AskUserQuestion:
- **Raise as separate issue** - Create Linear/GitHub issue, continue with PR as-is
- **Update plan and implement** - Expand PR scope (may delay)
- **Discuss with reviewer** - Post reply asking for clarification

### Handle SCOPE_CREEP Items

For each SCOPE_CREEP item:

```bash
# Offer to create a tracking issue
gh issue create --title "{scope creep summary}" --body "Raised during review of PR #{PR_NUMBER}.

**Original request:** {reviewer comment}
**Reason for deferral:** Out of scope for this PR's purpose: {PR purpose}"
```

Present via AskUserQuestion:
- **Create issues for all** - Create tracking issues for each scope creep item
- **Include in this PR** - Expand scope (not recommended)
- **Just reply** - Explain deferral to reviewer without creating issues

### Proceed with SIMPLE_FIX Items

Use AskUserQuestion:
- **Fix all** - Implement all SIMPLE_FIX items with checkpoints
- **Review each** - Go through fixes one by one
- **Skip fixes, just reply** - Only post clarifications

## Step 4.5: Plan-Verify Before Fixes

Before implementing any SIMPLE_FIX items, run gap-detector once for all fixes collectively:

```
Task tool with subagent_type="unitwork:plan-review:gap-detector"
prompt: "Review these PR comment fixes for information gaps:

SIMPLE_FIX items:
<list of SIMPLE_FIX items from Step 4>

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

For each SIMPLE_FIX item:

### 5.1 Implement the Fix

1. Read the file
2. Implement the change

### 5.2 Verify

Launch appropriate verification subagents based on what changed. See [verification-flow.md](../skills/unitwork/references/verification-flow.md#which-verification-subagent-to-use) for guidance:

- **Changed test files?** → Launch `test-runner`
- **Changed API endpoints?** → Launch `test-runner` + `api-prober`
- **Changed UI components?** → Launch `test-runner` + invoke `/uw:browser-test` command

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

After all SIMPLE_FIX items are checkpointed, create a single commit for non-fix clarifications:

```
docs: clarifications for PR #{PR_NUMBER} review comments

- {ALREADY_HANDLED item 1}
- {QUESTION reply 1}
- {DISAGREE explanation 1}
```

This commit contains no code changes, only documentation of responses.

## Step 7: Post In-Thread Replies

Reply directly in the review thread, not as top-level comments. **Always prefix with 🤖** to show it's Claude responding.

### Find Comment IDs

```bash
# Get all review comments with IDs, file paths, and content
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/comments \
  --jq '.[] | {id, path, line, body: .body[0:100], user: .user.login}'
```

Match feedback to the correct `id` by file path and content.

### Reply In-Thread

```bash
# Reply to specific comment by ID
gh api --method POST \
  repos/{owner}/{repo}/pulls/$PR_NUMBER/comments/{comment_id}/replies \
  -f body="🤖 Fixed in latest push."
```

**Reply templates:**
- SIMPLE_FIX (done): "🤖 Fixed in latest push."
- ALREADY_HANDLED: "🤖 This is already handled — {brief explanation of where/how}."
- QUESTION: "🤖 {concise answer}."
- DISAGREE: "🤖 Intentional — {brief reason}."
- SCOPE_CREEP: "🤖 Good idea — raised as {issue link} to keep this PR focused."
- DEFER: "🤖 Noted — will address in a follow-up."

**Keep replies brief.** Put details in code comments if needed.

### Resolve Addressed Threads

After replying, resolve threads for items that are done:

```bash
# Get thread IDs
gh api graphql -f query='
  query {
    repository(owner: "{owner}", name: "{repo}") {
      pullRequest(number: '$PR_NUMBER') {
        reviewThreads(first: 50) {
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes { body }
            }
          }
        }
      }
    }
  }
'

# Resolve a thread
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_NODE_ID"}) {
      thread { isResolved }
    }
  }
'
```

**When to resolve:**
- Fix pushed for the issue
- Explained why no change needed (and reviewer hasn't objected)

**When NOT to resolve:**
- Still working on it
- Ongoing discussion
- REARCHITECTURE items awaiting alignment

## Step 8: Update PR Description

After implementing fixes, check if the PR description is stale:

```bash
gh pr view $PR_NUMBER --json body -q .body
```

**Description is stale if any of these are true:**
- Description says "adds X" but X was removed during fixes
- Verification section references old test approach
- Approach section describes superseded design
- Changes Summary doesn't reflect post-review state

**If stale:** Regenerate using the format from `/uw:pr` Step 4, preserving any custom sections. Update via:

```bash
REPO_INFO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api "repos/$REPO_INFO/pulls/$PR_NUMBER" --method PATCH --input - <<< '{"body": "..."}'
```

**If still accurate:** Skip this step.

---

## Step 9: Compound Phase Prompt

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

## Step 10: Report and Push

```
Addressed {X}/{Y} comments on PR #{PR_NUMBER}

**Fixed ({count} checkpoints):**
- checkpoint(pr-{PR}-1): {summary}
- checkpoint(pr-{PR}-2): {summary}

**Escalated ({count}):**
- {count} REARCHITECTURE items — {resolved/pending}

**Scope Creep ({count}):**
- {count} issues created to track separately

**Clarified ({count}):**
- {count} in-thread replies posted

**Deferred ({count}):**
- {count} noted for future work

**PR Description:** {Updated / No changes needed}

Push changes and request re-review?
```

### Pre-Push Checklist

Before pushing, verify:
- [ ] All SIMPLE_FIX items checkpointed
- [ ] All threads replied to (in-thread, not top-level)
- [ ] Addressed threads resolved
- [ ] PR description updated if stale
- [ ] No unresolved REARCHITECTURE items blocking

Use AskUserQuestion:
- **Push and re-request review** - Push, then re-request from original reviewers
- **Push only** - Just push changes
- **Review changes first** - Show diff before pushing

### Re-Request Review

```bash
# Push changes
git push

# Re-request review from original reviewers
gh api repos/{owner}/{repo}/pulls/$PR_NUMBER/reviews \
  --jq '.[].user.login' | sort -u | while read reviewer; do
  gh pr edit $PR_NUMBER --add-reviewer "$reviewer"
done
```
