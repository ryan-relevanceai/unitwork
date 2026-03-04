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
**If no PR:** Check if this is a Plan PR (see Plan PR Flow below), otherwise continue to Step 3 (Create flow)

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

Write a detailed PR description following this format:

```markdown
## Context
{Why this change exists — the problem, bug, or need. Link to Linear ticket if exists.}

## Changes Summary
{File-level breakdown with PURPOSE per file, not just names}
- `src/auth/session.ts` — Added refresh logic with 5-min buffer before expiry
- `src/api/middleware.ts` — Extended timeout handling for external calls

## The Approach
{WHY this approach over alternatives. What was considered and why this was best.}

## Key Decisions
{Trade-offs, assumptions, non-obvious choices made during implementation.}

## Verification
- Automated: {test results — N tests passing, N new tests for specific scenarios}
- Manual: {specific scenarios tested end-to-end, if any}
- Edge cases: {edge cases verified}

## Risks & Dependencies
{Known risks with mitigations, or "None identified."}

## Future Work
{Deferred items or known limitations, or omit if none.}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**Important guidelines for description:**
- AI-generated PRs should be MORE detailed than human PRs — explain the "why" not just "what"
- The Approach section is REQUIRED — always explain why this approach over alternatives
- Call out assumptions explicitly (e.g., "Assumed existing auth middleware pattern is correct")
- Note codebase conventions followed (e.g., "Followed pattern from src/hooks/useQuery.ts")
- Note what was NOT changed and why ("Did not refactor adjacent code to keep scope focused")
- Keep Changes Summary focused on purpose per file, not just listing filenames

**If user provided extra context:** Incorporate it into the Context section.

Create the PR:

```bash
GH_USER=$(gh api user -q .login)
gh pr create --base "$BASE_BRANCH" --draft --assignee "$GH_USER" --fill-first --body "$PR_DESCRIPTION"
```

Get the new PR URL and go to Step 7.

---

## Plan PR Flow (Auto-Detected)

**When to trigger:** Before Step 3, check if this is a plan-only change:

```bash
BASE_BRANCH=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
CHANGED_FILES=$(git diff --name-only "origin/${BASE_BRANCH}...HEAD")

# Check if ALL changed files are in .unitwork/specs/
PLAN_ONLY=true
while IFS= read -r file; do
  case "$file" in
    .unitwork/specs/*) ;; # spec file, still plan-only
    *) PLAN_ONLY=false; break ;;
  esac
done <<< "$CHANGED_FILES"
```

**If `PLAN_ONLY=true`:** Use the Plan PR flow below instead of the standard Create Flow.

### Plan PR Title

```
[PLAN] {Feature Name from spec}
```

Extract the feature name from the first `# ` heading in the spec file.

### Plan PR Description

Generate from the spec content:

```markdown
## Overview
{Purpose & Impact section from spec — why this feature exists}

## Scope
**Implementation Units:**
{Numbered list of units from spec with confidence ceilings}

**Out of Scope:**
{Out of Scope section from spec}

## Key Decisions
{Technical Approach section — architectural choices, integration points}

## Risks
{Any assumptions, unknowns, or high-risk units (confidence < 80%)}

## Review Focus
Help the reviewer by calling out:
- Requirements that need domain expertise to validate
- Architectural decisions that affect long-term maintenance
- Scope boundaries that might be too narrow or too wide

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Create Plan PR

```bash
GH_USER=$(gh api user -q .login)
SPEC_FILE=$(echo "$CHANGED_FILES" | grep '.unitwork/specs/' | head -1)
FEATURE_NAME=$(head -5 "$SPEC_FILE" | grep '^# ' | sed 's/^# //')
gh pr create --base "$BASE_BRANCH" --draft --assignee "$GH_USER" \
  --title "[PLAN] $FEATURE_NAME" \
  --body "$PLAN_PR_DESCRIPTION"
```

After creation, go to Step 7.

### Implementation PRs Reference Plan PRs

When creating a standard (non-plan) PR and a `[PLAN]` PR exists for the same feature:

```bash
# Check for related plan PRs
gh pr list --state all --search "[PLAN]" --json number,title,url
```

If a matching plan PR is found, add to the Context section of the implementation PR:

```markdown
## Context
**Plan PR:** #{plan_pr_number} — {plan_pr_title}
{rest of context...}
```

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
- Update the "## Context", "## Changes Summary", "## The Approach", and "## Verification" sections to reflect current changes
- Keep "## Key Decisions" and "## Risks & Dependencies" and any additional sections
- Keep the overall structure

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
