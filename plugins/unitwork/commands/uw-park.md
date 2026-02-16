---
name: uw:park
description: Park current work session with full context to a GitHub PR comment for multi-device handoff
argument-hint: "[brief description of current state]"
---

# Park Work Session

## Introduction

**Note: The current year is 2026.**

This command parks your current work session by:
1. Committing any uncommitted changes with a "park: WIP" prefix
2. Pushing to remote and creating a draft PR if none exists
3. Adding a structured parking comment to the PR with full context

Use this when you need to switch devices or pause work with intent to resume later.

## Arguments

<arguments> #$ARGUMENTS </arguments>

Parse naturally - any text provided becomes the brief description of current state.

## Step 1: Verify Git Environment

```bash
# Check we're in a git repo and get branch name
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Check gh auth
gh auth status
```

If not authenticated, tell user to run `gh auth login`.

If on main/master branch, warn user and suggest creating a feature branch first.

## Step 2: Check for Uncommitted Changes

```bash
# Check for any changes (staged or unstaged)
git status --porcelain
```

**If changes exist:**
```bash
# Stage all changes
git add -A

# Create WIP commit with park prefix
git commit -m "park: WIP - {brief description from args or 'work in progress'}"
```

**If no changes:** Continue without committing.

## Step 3: Push Current Branch

```bash
# Push to remote (create upstream if needed)
git push -u origin "$CURRENT_BRANCH"
```

## Step 4: Check for Existing PR

```bash
gh pr list --head "$CURRENT_BRANCH" --json number,title,url
```

**If no PR exists:**
```bash
# Create a draft PR
gh pr create --draft --fill-first
```

Get the PR number from the output.

**If PR exists:** Use the existing PR number.

## Step 5: Gather Context from .unitwork/ Artifacts

Read available artifacts to build context:

```bash
# Find most recent spec
ls -t .unitwork/specs/*.md 2>/dev/null | head -1

# Find verification docs
ls -t .unitwork/verify/*.md 2>/dev/null

# Find review findings
ls -t .unitwork/review/*.md 2>/dev/null
```

For each artifact found, read and extract:
- From spec: Feature name, implementation units, which are marked complete
- From verify docs: Latest checkpoint status
- From review docs: Any pending findings

If `.unitwork/` directory doesn't exist or has no artifacts, note "No local artifacts found."

## Step 6: Get Last Checkpoint

```bash
# Get most recent checkpoint commit
git log --oneline | grep "checkpoint(" | head -1
```

Extract the checkpoint commit hash and message.

## Step 7: Build and Post Parking Comment

Build the parking comment using this template:

```markdown
<!-- uw:park -->
# Parked Work Session

## Summary
{Brief description from args, or extracted from spec, or "Work in progress"}

## Progress
### Completed
{List completed units from spec, or completed checkpoints}

### In Progress
{Current unit being worked on, if detectable}

### Pending
{Remaining units from spec}

## Next Steps
1. {First logical next action based on progress}
2. {Following action}

## Blockers
{Any blockers mentioned in artifacts, or "None"}

## Context
- **Spec:** `{spec file path if exists}`
- **Last checkpoint:** {commit hash} - {message}
- **Parked at:** {ISO timestamp}
```

Post the comment:
```bash
gh pr comment "$PR_NUMBER" --body "$PARKING_COMMENT"
```

## Step 8: Self-Verification

```bash
# Verify comment was added
gh pr view "$PR_NUMBER" --json comments --jq '.comments[-1].body' | head -5
```

Check that the output starts with `<!-- uw:park -->`.

## Output

```
Parked work session to PR #{number}

**Branch:** {branch_name}
**PR:** {pr_url}
**Last checkpoint:** {checkpoint info}

To resume on another device:
1. Clone/fetch the repo
2. Checkout branch: git checkout {branch_name}
3. Run: /uw:resume

The parking comment contains full context for resuming.
```
