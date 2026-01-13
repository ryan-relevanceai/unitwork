---
name: uw:pr
description: Create or update GitHub PRs with AI-generated descriptions
argument-hint: "[target branch] [extra context]"
---

# Create or Update Pull Request

## Introduction

**Note: The current year is 2026.**

This command creates draft PRs with well-formatted descriptions or updates existing PR descriptions when new commits are pushed. Arguments are parsed naturally - specify target branch and/or extra context in plain language.

## Arguments

<arguments> #$ARGUMENTS </arguments>

Parse these naturally:
- **Target branch**: Look for branch names like "main", "staging", "develop", or phrases like "to main", "against staging"
- **Extra context**: Any additional description the user provides about the changes

If no target branch specified, use the repository's default branch.

## Step 1: Verify Git Environment

```bash
# Check we're in a git repo
git branch --show-current

# Check gh auth
gh auth status
```

If not authenticated, tell user to run `gh auth login`.

## Step 2: Check for Existing PR

```bash
CURRENT_BRANCH=$(git branch --show-current)
gh pr list --head "$CURRENT_BRANCH" --json number,title,url
```

**If PR exists:** Go to Step 5 (Update flow)
**If no PR:** Continue to Step 3 (Create flow)

---

## Create Flow (Steps 3-4)

### Step 3: Gather Git Context

```bash
# Get base branch (from args or default)
BASE_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)

# Get changed files
git diff --name-status "origin/${BASE_BRANCH}...HEAD"

# Get commit messages
git log "origin/${BASE_BRANCH}..HEAD" --pretty=format:"%h - %s"

# Get diff (excluding generated files)
git diff "origin/${BASE_BRANCH}...HEAD" -- ':(exclude)*codegen*' ':(exclude)*generated*'

# Count lines for size check
git diff "origin/${BASE_BRANCH}...HEAD" -- ':(exclude)*codegen*' ':(exclude)*generated*' | wc -l
```

### Step 4: Confirm and Create PR

Present to user:

```
**Target:** {base_branch}
**Diff:** {line_count} lines

**Commits:**
{commit list}

**Files:**
{changed files}
```

Use AskUserQuestion:
- **Create PR** - Proceed with creation
- **Cancel** - Abort

**If diff > 2000 lines:** Warn user the PR is large and suggest breaking it up. Still allow creation but use a basic template instead of generating description.

**Generate PR description** (if diff <= 2000 lines):

Write a concise PR description following this format:
```
# Context
{Brief context - what bug/issue existed or what need this addresses}

# What's in this PR?
{High-level bullet points - NO file/class names unless essential}

# Notes
{Optional section for additional notes}
```

**Important guidelines for description:**
- Be CONCISE - avoid verbose explanations
- Keep bullet points HIGH-LEVEL focused on WHAT changed, not listing every file modified
- Focus on user-facing changes, functionality, or behavior modifications
- Don't mention specific file names or class names unless critical to understanding

**If user provided extra context:** Incorporate it into the Context section.

Create the PR:

```bash
GH_USER=$(gh api user -q .login)
gh pr create --base "$BASE_BRANCH" --draft --assignee "$GH_USER" --fill-first --body "$PR_DESCRIPTION"
```

Get the new PR URL and go to Step 7.

---

## Update Flow (Steps 5-6)

### Step 5: Check for New Changes

```bash
PR_NUMBER={from step 2}
PR_UPDATED_AT=$(gh pr view "$PR_NUMBER" --json updatedAt -q .updatedAt)
LATEST_COMMIT_DATE=$(git log -1 --format=%cI HEAD)
```

Compare timestamps. If no new commits since last PR update:
- Tell user "No new changes since last PR update"
- Go to Step 7

### Step 6: Update PR Description

Get current description:
```bash
gh pr view "$PR_NUMBER" --json body -q .body
```

Gather git context (same as Step 3).

**If diff > 2000 lines:** Skip description update, keep existing description with a note that it wasn't updated due to size.

**Generate updated description:**
- Preserve any custom headers or sections that exist (like "# PR TRAIN" headers or other custom content)
- Update the "# Context" and "# What's in this PR?" sections to reflect current changes
- Keep the overall structure and any additional sections

Update via API:
```bash
REPO_INFO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api "repos/$REPO_INFO/pulls/$PR_NUMBER" --method PATCH --input - <<< '{"body": "..."}'
```

---

## Step 7: Open in Browser

Get PR URL:
```bash
gh pr list --head "$CURRENT_BRANCH" --json url -q '.[0].url'
```

Use AskUserQuestion:
- **Open in browser** - Open the PR URL
- **Just show URL** - Print URL without opening

If user chooses to open:
```bash
open "$PR_URL"
```

## Output

```
{Created|Updated} PR #{number}: {title}
URL: {pr_url}

**Description:**
{generated description preview}
```
