---
name: uw:fix-conflicts
description: Autonomously rebase onto default branch with intelligent conflict resolution using multi-agent analysis
argument-hint: "[--continue | --abort]"
---

# Fix Conflicts with Intelligent Rebase

## Introduction

**Note: The current year is 2026.**

This command autonomously rebases the current branch onto the default branch and uses multi-agent analysis (intent + impact) to resolve conflicts intelligently. When agent confidence is low or goals conflict, it interviews the user for decisions.

## Arguments

<arguments> #$ARGUMENTS </arguments>

Parse naturally:
- **--continue**: Continue an in-progress rebase after manual resolution
- **--abort**: Abort an in-progress rebase
- If neither specified, start a fresh rebase

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before checking rebase state. Before detecting conflicts. Before anything else.**

Memory recall ensures you don't repeat failed resolution approaches from previous sessions and understand the context of conflicted files.

> **If you skip this:** You may resolve conflicts in ways that were already tried and reverted, or miss important context about file history.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall conflict resolution learnings (handles worktrees)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "conflict resolution, rebase, merge conflicts, file history" --budget mid --include-chunks
```

### Display Learnings

After recall, ALWAYS display relevant learnings:

```
**Relevant Learnings from Memory:**
- {past conflict resolution that worked}
- {context about conflicted files}
- {patterns to avoid}
```

If no relevant learnings found: "Memory recall complete - no relevant conflict resolution learnings found."

**DO NOT PROCEED until memory recall is complete.**

---

## Step 1: Detect Default Branch

```bash
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef -q '.defaultBranchRef.name')
echo "Default branch: $DEFAULT_BRANCH"
```

If `gh` fails (not a GitHub repo or not authenticated), fall back:

```bash
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d: -f2 | xargs)
```

If both fail, ask user:

```
❓ Could not detect default branch.

What is the default branch for this repository?
```

Use AskUserQuestion with common options:
- **main** - Most common default
- **master** - Legacy default
- **develop** - GitFlow default

---

## Step 2: Fetch Latest Changes

```bash
git fetch origin
echo "Fetched latest changes from origin"
```

**Important:** Do NOT `git pull`. Use `origin/{DEFAULT_BRANCH}` directly for the rebase.

---

## Step 3: Check Pre-Rebase State

### 3a: Handle Arguments First

If `--continue` was passed:
```bash
if [ ! -d .git/rebase-merge ] && [ ! -d .git/rebase-apply ]; then
  echo "❌ No rebase in progress. Nothing to continue."
  exit 1
fi
# Skip to Step 5 (rebase loop continuation)
```

If `--abort` was passed:
```bash
git rebase --abort
echo "✅ Rebase aborted successfully."
exit 0
```

### 3b: Check for Existing Rebase

```bash
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  echo "⚠️ A rebase is already in progress."
fi
```

If existing rebase detected, use AskUserQuestion:

```
⚠️ A rebase is already in progress.

What would you like to do?
```

Options:
- **Abort and start fresh** - Run `git rebase --abort` then start new rebase
- **Continue existing rebase** - Continue where the previous rebase left off
- **Stop** - Exit without making changes

### 3c: Check for Dirty Working Tree

```bash
DIRTY=$(git status --porcelain)
if [ -n "$DIRTY" ]; then
  echo "⚠️ Working tree has uncommitted changes"
fi
```

If dirty tree detected, use AskUserQuestion:

```
⚠️ Working tree has uncommitted changes:

{list of changed files}

What would you like to do?
```

Options:
- **Stash changes** - Run `git stash` before rebasing, `git stash pop` after
- **Commit changes first** - Stop and let user commit
- **Discard changes** - Run `git checkout -- .` (WARN: destructive)
- **Stop** - Exit without making changes

---

## Step 4: Start Rebase

```bash
CURRENT_BRANCH=$(git branch --show-current)
echo "Rebasing $CURRENT_BRANCH onto origin/$DEFAULT_BRANCH..."

git rebase origin/$DEFAULT_BRANCH
```

If rebase succeeds with no conflicts:

```
✅ Rebase completed successfully!

No conflicts encountered. Branch $CURRENT_BRANCH is now up-to-date with origin/$DEFAULT_BRANCH.
```

Exit successfully.

If rebase stops due to conflicts, continue to Step 5.

---

## Step 5: Conflict Resolution Loop

While in rebase state with conflicts:

### 5a: List Conflicted Files

```bash
# List files with conflicts
CONFLICTED=$(git diff --name-only --diff-filter=U)
echo "Conflicted files:"
echo "$CONFLICTED"
```

### 5b: Spawn Analysis Agents (Parallel)

For each conflicted file (or batch if >5 files), spawn both agents in parallel:

```
Launching conflict analysis agents for: {file}

Agents will analyze:
1. Intent Analyst: What was each branch trying to achieve?
2. Impact Explorer: What tests and dependencies are affected?
```

**Intent Analyst** (Task tool with `unitwork:conflict-resolution:conflict-intent-analyst`):
```
Analyze the conflict in {file}:

Our branch: {commits from origin/$DEFAULT_BRANCH..HEAD touching this file}
Their branch: {commits from HEAD..origin/$DEFAULT_BRANCH touching this file}

Return:
- ours_intent: What our changes were trying to achieve
- theirs_intent: What their changes were trying to achieve
- conflicting_goals: Boolean - do the intents fundamentally conflict?
- confidence: 0-100
```

**Impact Explorer** (Task tool with `unitwork:conflict-resolution:conflict-impact-explorer`):
```
Analyze impact of resolving {file}:

Return:
- affected_tests: Tests that cover this file
- downstream_files: Files that import/depend on this file
- behavior_changes: How each resolution option affects behavior
- resolution_recommendations: Suggested resolution approaches
```

### 5c: Synthesize Findings and Calculate Confidence

Collect outputs from both agents and calculate confidence:

```
**Conflict Analysis for {file}:**

Our Intent: {ours_intent}
Their Intent: {theirs_intent}
Conflicting Goals: {yes/no}

Affected Tests: {count} tests
Downstream Files: {count} files

Agent Confidence: {intent_confidence}%
Impact Assessment: {impact_summary}
```

**Confidence Calculation:**
- Start at 100%
- Subtract 20% if `conflicting_goals` is true
- Subtract 15% if `downstream_files` > 5
- Subtract 10% if no tests cover the file
- Subtract 10% for each unresolved behavioral question

Threshold:
- **>80%**: Auto-resolve
- **≤80%**: Interview user

### 5d: Route to Auto-Resolve or Interview

**If confidence >80% AND NOT conflicting_goals:**

Auto-resolve the conflict:

```
**Auto-resolving {file}** (Confidence: {n}%)

Resolution: {description of resolution approach}
```

Apply the resolution by editing the file to remove conflict markers and merge changes appropriately.

```bash
git add {file}
```

**If confidence ≤80% OR conflicting_goals:**

See Step 6 (Interview Flow).

### 5e: Run Test Verification

After resolving each file, run affected tests:

```bash
# Spawn test-runner agent for affected files
```

Task tool with `unitwork:verification:test-runner`:
```
Run tests for: {affected_tests}
Report pass/fail status
```

**If tests pass:** Continue with rebase.

**If tests fail:** Use AskUserQuestion (1 attempt limit per conflict):

```
⚠️ Tests failing after resolving {file}

Failing tests:
- {test1}: {error}
- {test2}: {error}

What would you like to do?
```

Options:
- **Let me fix manually** - User resolves, then run `/uw:fix-conflicts --continue`
- **Try different resolution** - Re-analyze with user guidance
- **Skip tests and continue** - Accept risk, continue rebase
- **Abort rebase** - Run `git rebase --abort`

### 5f: Continue Rebase

```bash
git rebase --continue
```

If more conflicts, loop back to 5a.

If rebase completes:

```
✅ Rebase completed!

All conflicts resolved. Branch is now up-to-date with origin/$DEFAULT_BRANCH.
```

Create verification document and proceed to Step 7.

---

## Step 6: Interview Flow (Low Confidence)

When confidence ≤80% or goals conflict, present the analysis and ask for user decision.

### 6a: Present Conflict Analysis

```
**Conflict requires manual decision** (Confidence: {n}%)

File: {filename}

**Our Changes (current branch):**
{summary of our changes}

Intent: {ours_intent}

**Their Changes (default branch):**
{summary of their changes}

Intent: {theirs_intent}

{if conflicting_goals}
⚠️ **These changes have conflicting goals.** The branches were trying to achieve different things with this code.
{/if}

**Impact Analysis:**
- Tests affected: {count}
- Downstream dependencies: {list}
- Behavioral implications: {summary}
```

### 6b: Ask User for Resolution

Use AskUserQuestion:

```
How would you like to resolve this conflict?
```

Options:
- **Keep ours** - Keep our branch's changes, discard theirs
- **Keep theirs** - Keep their changes, discard ours
- **Merge both** - Combine both changes (provide guidance on how)
- **Let me resolve manually** - User edits file, then run `/uw:fix-conflicts --continue`

### 6c: Apply User's Choice

Apply the selected resolution, then return to Step 5e (test verification).

---

## Step 7: Create Verification Document

After successful rebase completion, create a verification document:

```bash
DATE=$(date +%d-%m-%Y)
mkdir -p .unitwork/verify
```

Create `.unitwork/verify/{DATE}-conflict-resolution.md`:

```markdown
# Conflict Resolution Verification

Date: {DATE}
Branch: {current_branch} rebased onto origin/{default_branch}

## Conflicts Resolved

| File | Resolution | Confidence | Method |
|------|------------|------------|--------|
| {file1} | {approach} | {n}% | {auto/interview} |
| {file2} | {approach} | {n}% | {auto/interview} |

## Test Verification

- Tests run: {count}
- Passed: {count}
- Failed: {count}

## AI-Verified (100% Confidence)

- [ ] All conflict markers removed (`grep -r '<<<<<<<' .` returns empty)
- [ ] Rebase completed successfully (`git status` shows clean state)
- [ ] Current branch ahead of origin/{default_branch}

## Human QA Checklist

- [ ] Verify merged logic is semantically correct
- [ ] {any file-specific items}
```

---

## Step 8: Memory Retain

After successful completion, retain learnings:

```bash
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory retain "$BANK" "Conflict resolution: {summary of what worked}. Files: {list}. Approach: {auto/interview mix}." \
  --context "conflict resolution learning" \
  --doc-id "learn-conflict-$(date +%d%m%Y)" \
  --async
```

---

## Cycle Limits and Safety

### Hard Limit: 10 Conflicts

If the rebase involves more than 10 conflicted commits:

```
⚠️ Large rebase detected ({n} commits with conflicts)

This rebase has many conflicts and may be complex. Consider:
- Breaking into smaller rebases
- Using `git rebase -i` for selective rebasing
- Manual conflict resolution

What would you like to do?
```

Use AskUserQuestion:
- **Continue anyway** - Proceed with all conflicts
- **Abort** - Run `git rebase --abort`
- **Let me handle manually** - Exit for user to manage

### Interview Limit: 5 Per Session

After 5 user interviews in a single session:

```
⚠️ Interview limit reached (5 conflicts required user input)

Many conflicts in this rebase require manual decisions.
Consider resolving remaining conflicts manually.

What would you like to do?
```

Use AskUserQuestion:
- **Continue anyway** - Keep interviewing
- **Stop and continue manually** - Save progress, user continues
- **Abort** - Run `git rebase --abort`

---

## Completion

When rebase completes successfully:

```
/uw:fix-conflicts complete!

**Summary:**
- Rebased: {current_branch} onto origin/{default_branch}
- Conflicts resolved: {count}
- Auto-resolved: {count} (>{80}% confidence)
- User decisions: {count}

**Verification:**
- Tests: {pass/fail}
- Document: .unitwork/verify/{DATE}-conflict-resolution.md

Branch is ready for push:
- `git push --force-with-lease` (required after rebase)

Or continue development and push later.
```
