---
name: uw:resume
description: Resume a parked work session by reading PR parking comments and local artifacts
argument-hint: "[--force to allow dirty working directory]"
---

# Resume Parked Work Session

## Introduction

**Note: The current year is 2026.**

This command resumes a previously parked work session by:
1. Finding the PR for the current branch
2. Reading the latest parking comment from the PR
3. Reading local `.unitwork/` artifacts (specs, verify docs, review findings)
4. Presenting a synthesized context summary
5. Suggesting next steps

Use this after switching devices or returning to previously parked work.

## Arguments

<arguments> #$ARGUMENTS </arguments>

Parse naturally:
- **--force**: Allow resume even with dirty working directory

## Step 1: Verify Git Environment

```bash
# Check we're in a git repo and get branch name
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Check gh auth
gh auth status
```

If not authenticated, tell user to run `gh auth login`.

## Step 2: Check Working Directory Status

```bash
# Check for uncommitted changes
git status --porcelain
```

**If changes exist AND --force not provided:**
```
Warning: Working directory has uncommitted changes.

Options:
1. Stash changes: git stash
2. Commit changes: git add -A && git commit -m "WIP"
3. Continue anyway with --force

Aborting resume to protect local work.
```

Use AskUserQuestion:
- **Stash changes** - Run `git stash` and continue
- **Continue anyway** - Proceed despite dirty state
- **Abort** - Stop here

**If clean or --force:** Continue.

## Step 3: Find PR for Current Branch

```bash
gh pr list --head "$CURRENT_BRANCH" --json number,title,url,body
```

**If no PR found:**
```
No PR found for branch: {branch_name}

This branch may not have been parked, or the PR was closed.
Check for:
- Correct branch? Run: git branch -a
- PR exists? Run: gh pr list

If starting fresh, use /uw:plan or /uw:work instead.
```

Stop here with helpful guidance.

**If PR found:** Continue with PR number.

## Step 4: Find and Parse Parking Comment

```bash
# Get current user
GH_USER=$(gh api user -q .login)

# Get all comments from the PR
gh pr view "$PR_NUMBER" --json comments --jq '.comments[] | select(.author.login == "'"$GH_USER"'") | {body: .body, createdAt: .createdAt}'
```

Filter comments:
1. Must contain `<!-- uw:park -->` marker at the start of body
2. Must be from current GitHub user
3. Take most recent matching comment

**If no parking comment found:**
```
No parking comment found on PR #{number}.

This PR may not have been parked with /uw:park.
You can still see local artifacts below, or start fresh with /uw:work.
```

Continue to show local artifacts anyway.

**If parking comment found:**
Parse the markdown to extract:
- Summary
- Completed units
- In-progress units
- Pending units
- Next steps
- Blockers
- Context (spec path, last checkpoint, parked timestamp)

## Step 5: Read Local .unitwork/ Artifacts

```bash
# Find specs
ls -t .unitwork/specs/*.md 2>/dev/null | head -3

# Find verification docs
ls -t .unitwork/verify/*.md 2>/dev/null | head -5

# Find review findings
ls -t .unitwork/review/*.md 2>/dev/null | head -3
```

For each artifact type found, read and summarize:
- **Spec:** Feature name, total units, completion status
- **Verify docs:** Latest checkpoints, confidence levels
- **Review findings:** Any pending issues or findings

If `.unitwork/` directory doesn't exist or is empty, note "No local artifacts found."

## Step 6: Present Context Summary

Build and display a comprehensive summary:

```
# Resume: {feature name or branch name}

## Parked State (from PR comment)
{If parking comment found, show parsed summary, progress, and blockers}
{If no parking comment, show "No parking comment found"}

## Local Artifacts
### Spec
{Spec summary if found, or "No spec found"}

### Checkpoints
{List recent verification docs if found, or "No checkpoints found"}

### Review
{Review status if found, or "No review findings"}

## Last Checkpoint
{Commit hash and message from parsing comment or git log}

## Discrepancies
{Note any differences between PR comment state and local artifacts}
{For example: "PR comment mentions 3 completed units, but local spec shows 2 checked"}
```

## Step 7: Suggest Next Action

Based on the context, suggest appropriate next steps:

Use AskUserQuestion with options:
- **Continue implementation** - "I'll run /uw:work to continue from where you left off"
- **Review code** - "The implementation looks complete. Run /uw:review?"
- **Check CI status** - "Let me check if CI is passing first"
- **Just show context** - "I've shown the context. You decide what's next."

For each option, explain why it might be appropriate based on the parked state:
- If pending units exist: Suggest continuing implementation
- If all units complete but no review: Suggest review
- If blockers noted: Surface them and ask how to proceed

## Output

After user selects an action:

**If "Continue implementation":**
```
Resuming implementation from {last checkpoint or current state}...

Next unit: {unit name if detectable from spec}
```
Then invoke /uw:work behavior or tell user to run /uw:work.

**If "Review code":**
```
Ready for code review.
Run /uw:review to start parallel review.
```

**If "Check CI status":**
```bash
gh pr checks "$PR_NUMBER"
```
Then report status.

**If "Just show context":**
```
Context loaded. You're ready to continue.
Run /uw:work when ready to implement.
```
