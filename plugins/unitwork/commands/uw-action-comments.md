---
name: uw:action-comments
description: Bulk resolve GitHub PR comments using lightweight verification flow
argument-hint: "<PR number>"
---

# Resolve PR review comments

## Introduction

**Note: The current year is 2026.**

This command fetches PR comments, independently verifies each one, and implements confirmed fixes with lightweight verification (no full checkpoint cycle).

## PR Number

<pr_number> #$ARGUMENTS </pr_number>

**If empty:** Ask user for PR number.

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

- **VALID_FIX**: Concern is valid, needs fix
- **ALREADY_HANDLED**: Code already addresses this
- **QUESTION**: Needs explanation, no fix
- **DEFER**: Valid but out of scope for this PR
- **DISAGREE**: Reviewer concern is incorrect (explain why)

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
- **Fix all** - Implement all fixes
- **Review each** - Go through fixes one by one
- **Skip fixes, just reply** - Only post clarifications

## Step 5: Implement Fixes

For each fix:

1. Read the file
2. Implement the change
3. Run relevant tests (lightweight verification)
4. Stage the change

**NO full checkpoint cycle** - these are minor fixes, not new units of work.

## Step 6: Commit Fixes

Single commit for all PR comment fixes:

```
fix: address PR #$PR_NUMBER review comments

- {fix 1 summary}
- {fix 2 summary}
- {clarification 1 summary}
```

## Step 7: Post Replies (Optional)

For comments that need clarification (not fixes):

```bash
# Reply to already-handled concerns
gh pr comment $PR_NUMBER --body "Thanks for the review! This is already handled because..."

# Reply to questions
gh pr comment $PR_NUMBER --body "Good question! The reason for this pattern is..."
```

## Step 8: Report

```
Addressed {X}/{Y} comments on PR #{PR_NUMBER}

**Fixed:**
- {count} issues fixed

**Clarified:**
- {count} replies posted explaining existing code

**Deferred:**
- {count} noted for future work

Push changes and request re-review?
```

Use AskUserQuestion:
- **Push and request review** - `git push && gh pr ready`
- **Push only** - Just push changes
- **Review changes first** - Show diff before pushing
