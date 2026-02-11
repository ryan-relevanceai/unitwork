---
name: uw:fix-ci
description: Autonomously fix failing CI by cycling through analyze → fix → commit → push → verify
argument-hint: "[workflow name to focus on]"
---

# Fix CI Failures Autonomously

## Introduction

**Note: The current year is 2026.**

This command autonomously fixes CI failures by cycling through: analyze failure → plan fix → implement → commit → push → wait for CI → repeat until CI passes or limits are reached.

**Prerequisite:** This command requires an existing PR on the current branch. If no PR exists, the command fails with a clear message.

## Arguments

<arguments> #$ARGUMENTS </arguments>

Parse naturally:
- **Workflow name**: Optional - focus on a specific workflow file (e.g., "test", "lint", "build")
- If not specified, analyze all failing workflows

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before checking PR status. Before analyzing CI. Before anything else.**

Memory recall ensures you don't repeat failed fix attempts from previous sessions.

> **If you skip this:** You may try the same fix approach that already failed, wasting CI cycles.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall CI fix learnings (config override → git remote → worktree → pwd)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "CI failures, fix attempts, build errors, test failures, lint errors" --budget mid --include-chunks
```

### Display Learnings

After recall, ALWAYS display relevant learnings:

```
**Relevant Learnings from Memory:**
- {past CI fix that worked}
- {approach that didn't work}
```

If no relevant learnings found: "Memory recall complete - no relevant CI fix learnings found."

**DO NOT PROCEED until memory recall is complete.**

---

## Step 1: Verify PR Exists (MANDATORY - FAIL FAST)

```bash
CURRENT_BRANCH=$(git branch --show-current)
gh pr list --head "$CURRENT_BRANCH" --json number,title,url,state
```

**If no PR exists:** Stop immediately with this message:

```
❌ No PR found for branch: {branch_name}

This command requires an existing PR with CI checks.

To create a PR first, run:
- /uw:pr - Create PR with AI-generated description
- gh pr create - Create PR manually

Then re-run /uw:fix-ci
```

**If PR exists:** Continue to Step 2.

---

## Step 2: Check for CI Failures

```bash
# Get the latest workflow runs for this branch
gh run list --branch "$CURRENT_BRANCH" --limit 5 --json databaseId,name,status,conclusion,headSha

# Get detailed status of the most recent run
LATEST_RUN_ID=$(gh run list --branch "$CURRENT_BRANCH" --limit 1 --json databaseId -q '.[0].databaseId')
gh run view "$LATEST_RUN_ID" --json status,conclusion,jobs
```

**If all CI passing:** Report success and exit:

```
✅ All CI checks are passing!

No fixes needed. Ready for merge.
```

**If CI failing:** Continue to Step 3.

---

## Step 3: Parse CI Workflow Files (Limited Scope)

Read the workflow files to understand what commands CI is running:

```bash
# List workflow files
ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null

# Read each workflow file
cat .github/workflows/{workflow-name}.yml
```

**LIMITED SCOPE:** Only extract literal `run:` steps. Skip:
- Matrix expressions
- Reusable workflows (`uses: ./.github/workflows/other.yml`)
- Conditional expressions (`if:`)
- Service containers

Extract a simple mapping of:
```
Workflow: {name}
Steps with run commands:
- Step: {step name} -> Command: {run command}
```

---

## Step 4: Analyze Failure Output

```bash
# Get failed job logs
gh run view "$LATEST_RUN_ID" --log-failed
```

Parse the failure output to extract:
- **Failing step name**: Which step failed
- **Error message**: The error text
- **File:line** (if available): Where the error occurred

Present the analysis:

```
**CI Failure Analysis:**

Workflow: {workflow name}
Failed Step: {step name}
Error Type: {test failure | lint error | type error | build error | other}

Error Details:
{relevant error output, truncated if very long}

File(s) Affected:
- {file:line} - {brief description}
```

---

## Step 5: Plan Fix

Based on the failure analysis, plan a single fix. Do NOT try to fix multiple unrelated issues at once.

**For test failures:** Read the test file and implementation to understand the failure.

**For lint errors:** Read the specific lint rule violation and fix it.

**For type errors:** Read the type error and fix the type issue.

**For build errors:** Analyze the build output and fix the compilation issue.

Present the fix plan:

```
**Fix Plan:**

Issue: {brief description}
File(s) to modify: {list}
Approach: {what will be changed}

Proceeding with fix...
```

---

## Step 6: Implement Fix

Implement the planned fix. Follow codebase conventions.

**CRITICAL:** This is a CI fix, not a feature. Do NOT:
- Add new features
- Refactor unrelated code
- "Improve" code beyond what's needed for the fix
- Expand scope

---

## Step 7: Local Verification (If Applicable)

Before pushing, run the CI command locally if it's a standard package manager command:

| CI Command Pattern | Run Locally |
|-------------------|-------------|
| `npm test`, `npm run test` | Yes |
| `yarn test` | Yes |
| `pnpm test` | Yes |
| `pip install && pytest` | Yes |
| `cargo test` | Yes |
| `go test ./...` | Yes |
| Docker commands | No - skip local verification |
| `actions/*` | No - skip local verification |
| Custom scripts | No - skip local verification |

```bash
# Example: Run the CI command locally
{ci_command}
```

**If local verification fails:** Fix the issue before pushing.

**If local verification passes or was skipped:** Continue to Step 8.

---

## Step 8: Commit and Push

Commit the fix with a descriptive message:

```bash
git add {files}
git commit -m "$(cat <<'EOF'
fix(ci): {brief description of what was fixed}

Fixes {error type} in {workflow name}
Error: {brief error description}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"

git push
```

---

## Step 9: Poll for CI Completion

Wait for CI to complete. Use polling, NOT blocking `gh run watch`.

```bash
# Poll every 30 seconds
while true; do
  STATUS=$(gh run list --branch "$CURRENT_BRANCH" --limit 1 --json status,conclusion -q '.[0]')
  echo "CI Status: $STATUS"

  if [[ "$STATUS" == *"completed"* ]]; then
    break
  fi

  sleep 30
done
```

**Timeout:** 15 minutes per CI run. If CI hasn't completed after 15 minutes:

```
⏱️ CI timeout (15 minutes)

The CI run is taking longer than expected.
Current status: {status}

What would you like to do?
```

Use AskUserQuestion:
- **Continue waiting** - Wait another 15 minutes
- **Check status manually** - Stop polling, user will check
- **Abort** - Stop the fix-ci process

---

## Step 10: Check Result and Loop

After CI completes, check the result:

```bash
gh run view "$LATEST_RUN_ID" --json conclusion -q '.conclusion'
```

**If CI passes:** 🎉 Success! Report and exit:

```
✅ CI is now passing!

**Fixes applied:**
1. {first fix description}
2. {second fix description}
...

Total cycles: {n}
Ready for merge.
```

**If CI still fails:** Loop back to Step 4 (Analyze Failure Output).

---

## Cycle Limits and Safety

### Hard Limit: 5 Cycles

After 5 fix attempts without success:

```
⚠️ Fix cycle limit reached (5 attempts)

**Attempts made:**
1. {fix 1 description} - Result: {still failing}
2. {fix 2 description} - Result: {still failing}
...

**Failure patterns observed:**
- {pattern 1}
- {pattern 2}

**Recommendation:** This may require manual investigation.

What would you like to do?
```

Use AskUserQuestion:
- **Continue manually** - User takes over
- **Revert fixes** - Revert all fix commits
- **Get more context** - Spawn exploration agent to investigate

### Same Error Detection: 3 Consecutive

If the same error appears 3 times consecutively:

```
🔄 Same error detected 3 times

Error: {error description}

This error is likely not fixable by code changes alone. Possible causes:
- Missing environment variable or secret
- External service unavailable
- Flaky test
- Infrastructure issue

What would you like to do?
```

Use AskUserQuestion:
- **Investigate further** - Spawn exploration agent
- **Skip this error** - Focus on other failures
- **Stop** - End the fix-ci process

---

## Gap Collection

During analysis, collect any gaps that require user input:

- Missing information (unclear error, needs context)
- Credentials or secrets needed
- External dependencies
- Ambiguous fix approaches

**Present all gaps together** before proceeding:

```
**Gaps Found:**

1. {gap description}
   - What's needed: {requirement}

2. {gap description}
   - What's needed: {requirement}

Please provide the missing information to continue.
```

Use AskUserQuestion to gather the needed information.

---

## Completion

When CI passes or the user chooses to stop:

```
/uw:fix-ci complete.

**Summary:**
- CI Status: {passing | still failing}
- Cycles used: {n}/5
- Fixes applied: {count}

**Commits created:**
- {commit hash} - fix(ci): {description}
...

{Next steps recommendation}
```

Retain learnings:

```bash
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory retain "$BANK" "CI fix: {what was fixed}. Approach: {what worked}. {any gotchas}." \
  --context "CI fix learning" \
  --doc-id "learn-ci-fix-<date>" \
  --async
```
