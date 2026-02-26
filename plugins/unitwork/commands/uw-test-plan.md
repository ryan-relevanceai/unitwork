---
name: uw:test-plan
description: "Generate comprehensive manual testing steps from git diffs. Analyzes frontend and backend changes, identifies edge cases, and produces one continuous end-to-end test plan. Stores in .unitwork/test-plans/. Triggers on: test plan, manual testing, testing steps, QA plan, verification plan, generate test."
argument-hint: "<feature name or empty to auto-detect from branch>"
---

# Generate Manual Test Plan from Git Diff

## CRITICAL: Write-Only to .unitwork/test-plans/

**This command does NOT modify any source code.** It only writes to `.unitwork/test-plans/`.

Allowed operations:
- Reading files (Read, Glob, Grep)
- Running read-only bash commands (git diff, git log, ls)
- Spawning memory-aware-explore agents
- Writing ONLY to `.unitwork/test-plans/{DD-MM-YYYY}-{feature-name}.md`

Forbidden operations:
- Editing any existing source files
- Writing new files outside `.unitwork/test-plans/`
- Running tests or modifying the codebase

## Introduction

**Note: The current year is 2026.**

This command analyzes the git diff of your current branch to fully understand a feature, then generates a comprehensive set of manual testing steps. The test plan is written as one continuous end-to-end test (not separate test cases) that covers the happy path, edge cases, and error scenarios for what the diff changed.

After storing the test plan, it suggests execution via `/uw:browser-test` or Momentic.

## Feature Name

<feature_name> #$ARGUMENTS </feature_name>

**If empty:** Auto-detect from branch name:

```bash
BRANCH=$(git branch --show-current)
# Strip user prefix (e.g., myz96/add-cron-scheduling -> add-cron-scheduling)
FEATURE_NAME=$(echo "$BRANCH" | sed 's|^[^/]*/||' | sed 's|^[A-Z]*-[0-9]*[-_]||')
echo "Auto-detected feature name: $FEATURE_NAME"
```

If branch name is unhelpful (e.g., `main`, `dev`), ask the user: "What feature should this test plan cover? I couldn't derive a meaningful name from the branch."

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before repo detection. Before diff analysis. Before anything else.**

Memory recall loads past testing learnings, known edge cases, and verification gotchas to produce better test plans.

> **If you skip this:** You may miss known edge cases, fail to test authentication flows correctly, or overlook patterns that previous testing sessions already documented.

### Execute Memory Recall NOW

```bash
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "testing patterns, edge cases, verification gotchas, and browser testing learnings for: $FEATURE_NAME" --budget mid --include-chunks
```

### Display Learnings

After recall, display relevant learnings:

```
**Relevant Testing Learnings from Memory:**
- {testing gotcha or pattern}
- {edge case from prior testing}
- {browser testing pattern}
```

If no relevant learnings found: "Memory recall complete - no relevant testing learnings found."

**DO NOT PROCEED to repo detection until memory recall is complete.**

---

## Phase 1: Repo Detection

Detect which repositories are available for analysis. The goal is to find both frontend and backend repos when possible.

### 1a: Classify Current Workspace

```bash
# Check if current workspace is backend
if [ -f "apps/nodeapi/package.json" ] || [ -f "src/server.ts" ] || [ -f "src/app.ts" ]; then
  echo "CURRENT_TYPE=backend"
elif [ -f "package.json" ] && (grep -q '"expo"' package.json 2>/dev/null || grep -q '"react-native"' package.json 2>/dev/null || grep -q '"next"' package.json 2>/dev/null || grep -q '"vue"' package.json 2>/dev/null); then
  echo "CURRENT_TYPE=frontend"
else
  echo "CURRENT_TYPE=unknown"
fi
echo "CURRENT_PATH=$(pwd)"
```

### 1b: Search for Companion Repo

If current workspace is backend, search for a frontend repo. If frontend, search for backend. Search strategy:

```bash
# Search parent and sibling directories for companion repos
SEARCH_DIRS=$(dirname "$(pwd)")

# Look for frontend indicators
for dir in "$SEARCH_DIRS"/*/; do
  if [ -f "$dir/package.json" ] && (grep -q '"expo"' "$dir/package.json" 2>/dev/null || grep -q '"react-native"' "$dir/package.json" 2>/dev/null || grep -q '"next"' "$dir/package.json" 2>/dev/null || grep -q '"vue"' "$dir/package.json" 2>/dev/null); then
    echo "FRONTEND_PATH=$dir"
    break
  fi
done

# Look for backend indicators
for dir in "$SEARCH_DIRS"/*/; do
  if [ -f "$dir/apps/nodeapi/package.json" ] || ([ -f "$dir/package.json" ] && grep -q '"express"' "$dir/package.json" 2>/dev/null) || [ -f "$dir/src/server.ts" ]; then
    echo "BACKEND_PATH=$dir"
    break
  fi
done
```

### 1c: Report Detection Results

```
**Repos detected:**
- Backend: {path or "not found"}
- Frontend: {path or "not found"}
- Current workspace type: {backend|frontend|unknown}
```

If only one repo is found, proceed with just that repo. If neither is detected, analyze the current workspace as-is.

---

## Phase 2: Diff Analysis

For each detected repo, get the diff against the base branch.

### 2a: Determine Base Branch

```bash
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
echo "Base branch: $BASE_BRANCH"
```

### 2b: Get Current Repo Diff

```bash
# File-level summary
git diff --name-status "origin/${BASE_BRANCH}...HEAD"

# Full diff excluding generated files
git diff "origin/${BASE_BRANCH}...HEAD" -- ':(exclude)*codegen*' ':(exclude)*generated*' ':(exclude)*.lock'
```

### 2c: Get Companion Repo Diff (If Available)

If a companion repo was detected in Phase 1, check if it has a branch with the same or similar name:

```bash
cd {companion_repo_path}

# Check if same branch name exists
COMPANION_BRANCH=$(git branch --show-current)
COMPANION_BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Get diff if not on base branch
if [ "$COMPANION_BRANCH" != "$COMPANION_BASE" ]; then
  git diff --name-status "origin/${COMPANION_BASE}...HEAD"
  git diff "origin/${COMPANION_BASE}...HEAD" -- ':(exclude)*codegen*' ':(exclude)*generated*' ':(exclude)*.lock'
else
  echo "Companion repo is on base branch — no changes to analyze"
fi
```

If the companion repo is on the base branch (no changes), skip it and analyze only the current repo.

---

## Phase 3: Feature Understanding

Spawn exploration agents to deeply understand what the diff changes. The number of agents depends on which repos have diffs.

### If Both Frontend and Backend Have Diffs (2 Agents in Parallel)

**Agent 1 — Backend Changes:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Analyze this git diff to understand the backend changes for writing a manual test plan.

<diff>
{backend diff}
</diff>

Focus on:
1. API endpoints added or modified — what do they accept and return?
2. Business logic changes — what behavior is new or different?
3. Validation rules — what inputs are validated and how?
4. Error handling — what error cases are handled? What error messages?
5. Database changes — any new tables, columns, queries?
6. Authentication/authorization — any permission changes?
7. Edge cases — empty inputs, null values, boundary conditions, concurrent access

Report: For each changed area, describe what it does, how to trigger it, what inputs it needs, and what can go wrong."
```

**Agent 2 — Frontend Changes:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Analyze this git diff to understand the frontend changes for writing a manual test plan.

<diff>
{frontend diff}
</diff>

Focus on:
1. UI components added or modified — what do they render and when?
2. User interactions — what can the user click, type, select, drag?
3. State management — what state drives the UI? How does it change?
4. API calls — what backend endpoints does the frontend call?
5. Error display — how are errors shown to the user?
6. Loading states — what happens while data is loading?
7. Navigation — any new routes or page transitions?
8. Edge cases — empty states, long text, rapid clicks, offline behavior

Report: For each changed area, describe the user journey, what the user sees, what they can interact with, and what can go wrong visually."
```

### If Only One Repo Has Diffs (1 Agent)

Spawn a single agent with the appropriate prompt from above based on whether it's frontend or backend.

---

## Phase 4: Test Plan Generation

Using the exploration agent findings, generate ONE continuous test plan.

### Structure Rules

1. **One continuous test** — All steps are numbered sequentially. No separate "Test Case 1", "Test Case 2" sections.
2. **User journey order** — Steps follow the user's perspective: navigate, interact, verify result.
3. **Happy path first** — The main expected flow comes first.
4. **Edge cases after** — After the happy path, add steps that test boundaries, errors, and unusual inputs.
5. **Concrete test data** — Use specific values ("type 'test@example.com'"), not placeholders ("type an email").
6. **Verify after each action** — Every meaningful action has a `**Verify:**` line stating what should be observable.
7. **Prerequisites up front** — Login steps, navigation to the right page, any setup data.

### Generation Process

Read the diff and agent findings, then:

1. Identify the core user journey (what does the feature let you do?)
2. Write prerequisite steps (login, navigate, setup)
3. Write happy-path steps with verify lines
4. Identify edge cases from the diff:
   - What happens with empty/null inputs?
   - What happens with very long inputs?
   - What happens with invalid inputs?
   - What happens if the user double-clicks or submits twice?
   - What happens if the backend returns an error?
   - What about permissions — can unauthorized users access this?
5. Write edge case steps with verify lines
6. Note any visual/layout items that need human eyes

### Use the Template

Write the test plan using the template at [templates/test-plan.md](../skills/unitwork/templates/test-plan.md):

- Fill in Feature Summary from diff analysis
- List Changed Files from `git diff --name-status`
- Write Prerequisites
- Write all Test Steps sequentially
- Summarize Edge Cases Covered with step references
- List Visual/Layout Checks for human review

---

## Phase 5: Store Test Plan

```bash
# Create the test-plans directory if it doesn't exist
mkdir -p .unitwork/test-plans

# Date in DD-MM-YYYY format
DATE=$(date +%d-%m-%Y)

# Write the test plan
# File: .unitwork/test-plans/{DATE}-{FEATURE_NAME}.md
```

Write the generated test plan to `.unitwork/test-plans/{DATE}-{FEATURE_NAME}.md` using the Write tool.

---

## Phase 6: Suggest Execution

Present the test plan summary and suggest execution methods:

```
Test plan written to: .unitwork/test-plans/{DATE}-{FEATURE_NAME}.md

**{N} test steps** covering {M} edge cases.

**Execute this test plan:**

1. **`/uw:browser-test`** — Walk through the test steps interactively using agent-browser.
   Best for: quick ad-hoc verification, local development testing, visual checks.
   Usage: Copy the test steps and use them as the task for /uw:browser-test.

2. **Momentic** — Create a Momentic .test.yaml from these steps for automated E2E runs with video recording.
   Best for: repeatable regression tests, CI integration, multi-step flows.
   Usage: Use the /momentic skill to create a test from these steps.

Review the test plan first — adjust any steps before executing.
```

---

## Phase 7: Retain Learnings

Store the test plan generation experience to Hindsight for future improvement:

```bash
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory retain "$BANK" "Generated test plan for $FEATURE_NAME: {N} steps covering {M} edge cases. Key areas tested: {summary of what was covered}. Repos analyzed: {backend|frontend|both}." \
  --context "test-plan generation for $FEATURE_NAME" \
  --doc-id "test-plan-$FEATURE_NAME" \
  --async
```
