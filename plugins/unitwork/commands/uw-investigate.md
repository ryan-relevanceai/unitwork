---
name: uw:investigate
description: Read-only codebase investigation with memory integration. Run tests and temp scripts to verify hypotheses.
argument-hint: "<investigation goal, e.g., 'why is the API slow'>"
---

# Read-Only Codebase Investigation

## CRITICAL: Read-Only Mode

**NEVER MODIFY ANY PRODUCTION CODE.** This command is strictly read-only for the codebase.

Allowed operations:
- Reading files (Read, Glob, Grep)
- Running read-only bash commands (git log, gh commands, ls)
- Spawning memory-aware-explore agents
- Running existing tests via test-runner agent
- Running inline Python scripts via `uv run python -c`
- Creating temporary Python scripts in `.unitwork/tmp/`

Forbidden operations:
- Editing any existing files (except `.unitwork/tmp/`)
- Writing new files outside `.unitwork/tmp/`
- Running mutating API requests (POST/PUT/DELETE)
- Making any changes to the codebase
- Creating shell scripts directly via bash heredocs

If the user asks to make changes during investigation, remind them: "Investigation is read-only. Use `/uw:plan` to plan changes or `/uw:work` to implement fixes."

## Introduction

**Note: The current year is 2026.**

This command enables deep investigative exploration of codebases without risk of modifying production data or code. Use it for debugging issues, investigating performance bottlenecks, or understanding code before deciding on next steps.

## Investigation Goal

<investigation_goal> #$ARGUMENTS </investigation_goal>

**If empty:** Ask the user: "What would you like to investigate? Describe the issue, behavior, or area you want to understand."

Do not proceed until you have a clear investigation goal.

### Goal Transformation

Detect and transform write-oriented goals into investigation form.

**Write-Oriented Keywords:**
- "fix", "implement", "add", "create", "update", "delete", "remove", "refactor", "change", "modify", "build"

**Detection Logic:**
1. Check if first word (case-insensitive) is a write-oriented keyword
2. If detected: Transform and notify user

**Transformation Examples:**

| User Input | Transformed Goal |
|------------|------------------|
| "fix the login bug" | "investigate why the login bug occurs and what causes it" |
| "add pagination to users list" | "investigate what would be needed to add pagination to users list" |
| "refactor the auth module" | "investigate the current auth module structure and identify what refactoring would involve" |
| "create a new API endpoint" | "investigate existing API patterns and what creating a new endpoint would require" |
| "delete unused code" | "investigate which code is unused and the impact of removing it" |

**User Message when transformation occurs:**

```
This sounds like a write task. I'll investigate first: '{transformed goal}'.

Use /uw:plan or /uw:work to implement changes after investigation.
```

---

## When to Use /uw:investigate vs /uw:plan

| Scenario | Command | Why |
|----------|---------|-----|
| "Why is X slow?" | /uw:investigate | Pure understanding, can run tests to verify |
| "Fix the slow X" | /uw:plan | Has implementation goal |
| "Understand how X works before deciding what to do" | /uw:investigate | No commitment to implement yet |
| "Add feature Y" | /uw:plan | Has implementation goal |
| "Debug why tests are failing" | /uw:investigate | Debugging, may need to run tests |
| "Refactor the auth module" | /uw:plan | Has implementation goal |

**Key difference:**
- `/uw:investigate` can run tests and scripts to verify hypotheses
- `/uw:plan` uses read-only analysis and user confirmation for hypothesis verification
- If you have an implementation goal, use `/uw:plan` - it now includes hypothesis formation

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before exploration. Before any analysis. Before anything else.**

Memory recall ensures you don't repeat failed investigation approaches or miss previous findings on similar issues.

> **If you skip this:** You may investigate the same dead ends that previous sessions already ruled out, or miss documented root causes.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall relevant investigation context (config override → git remote → worktree → pwd)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "investigation of: <investigation_goal>, related bugs, root causes, debugging approaches" --budget mid --include-chunks
```

### Display Learnings

After recall, ALWAYS display relevant learnings:

```
**Relevant Learnings from Memory:**
- {past investigation finding}
- {known root cause for similar issue}
- {debugging approach that worked}
```

If no relevant learnings found: "Memory recall complete - no relevant investigation learnings found."

**DO NOT PROCEED to exploration until memory recall is complete.**

---

## Phase 1: Exploration

Use **memory-aware exploration agents** to investigate the codebase while preserving main thread context and compounding findings across sessions.

### Spawn Exploration Agents

Launch 2-3 exploration agents **in parallel** based on the investigation goal:

**Agent 1 - Primary Area:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Investigation context: <investigation_goal>

Explore this codebase to find code related to: <investigation_goal>
1. Find the primary files involved in this area
2. Trace the code flow for the relevant functionality
3. Identify potential problem areas or complexity
4. Document what you find with file:line references

Report: relevant files, code flow, and initial observations."
```

**Agent 2 - Related Tests and Logs:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Investigation context: <investigation_goal>

Explore this codebase to find tests and logging related to: <investigation_goal>
1. Find existing tests that exercise this functionality
2. Locate logging, error handling, and debugging code
3. Check for any documented edge cases or known issues
4. Note test coverage gaps

Report: test locations, logging points, and coverage observations."
```

**Agent 3 (if needed) - Historical Context:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Investigation context: <investigation_goal>

Explore git history for context on: <investigation_goal>
1. Find recent commits that modified relevant files
2. Look for past bug fixes in this area
3. Check commit messages for context on design decisions
4. Note any patterns in when/how issues were introduced

Report: historical context and patterns."
```

After agents complete, synthesize findings into initial hypotheses.

---

## Phase 2: Form Hypotheses

Based on exploration findings, form 1-3 concrete hypotheses about the investigation target:

```
**Investigation Hypotheses:**

1. **{Hypothesis 1 - most likely}**
   - Evidence: {what from exploration supports this}
   - How to verify: {test or script to confirm/reject}

2. **{Hypothesis 2 - alternative}**
   - Evidence: {supporting evidence}
   - How to verify: {verification approach}

3. **{Hypothesis 3 - if applicable}**
   - Evidence: {supporting evidence}
   - How to verify: {verification approach}
```

---

## Phase 3: Verify Hypotheses

Test each hypothesis using available tools. Work through hypotheses in order of likelihood.

### Using Existing Tests

If existing tests can verify a hypothesis:

```
Task tool with subagent_type="unitwork:verification:test-runner"
prompt: "Run tests to verify hypothesis: <hypothesis>

Specific tests to run:
- {test file or pattern}

Expected outcome: {what would confirm/reject hypothesis}"
```

### Using Temporary Scripts

When existing tests don't cover the specific hypothesis, create a temporary verification script using Python.

**When to Use Temporary Scripts:**
- When existing tests don't cover the specific hypothesis
- When you need to reproduce a bug with specific input
- When you need to measure performance with specific data
- When no test file exists for the code under investigation

**Approach 1: Inline Python (Preferred)**

For simple, one-off verification scripts, use `uv run python -c` which is ephemeral and requires no cleanup:

```bash
uv run python -c "
import json
from pathlib import Path

# Read-only verification code (max 50 lines)
# Example: verify a JSON file structure
data = json.loads(Path('config.json').read_text())
assert 'required_key' in data, 'Missing required_key'
print('Verification passed')
"
```

**Approach 2: Persistent Script (for reuse)**

When you need to run the same verification multiple times or the script is complex, use `.unitwork/tmp`:

```bash
# Ensure tmp directory exists
mkdir -p .unitwork/tmp

# Use Write tool to create the script at .unitwork/tmp/verify_<topic>.py
# Then run with:
uv run python .unitwork/tmp/verify_<topic>.py
```

The `.unitwork/tmp` directory can be cleaned up later or added to `.gitignore`.

**Script Constraints:**
- Read-only operations only (no DB writes, no file modifications)
- Max 50 lines
- Must complete within 30 seconds
- Must not require user input
- Use Python standard library or packages available via `uv run`

### Verification Results

For each hypothesis, document the result:

```
**Hypothesis 1: {description}**
Result: CONFIRMED | REJECTED | INCONCLUSIVE

Evidence:
- {test output or script result}
- {specific finding}

{If CONFIRMED: This is likely the root cause.}
{If REJECTED: Moving to next hypothesis.}
{If INCONCLUSIVE: Need more investigation - {what's needed}}
```

---

## Phase 4: Investigation Summary

After verifying hypotheses, produce an in-conversation summary (no file artifact):

```
**Investigation Summary: {original goal}**

**Finding:** {1-2 sentence summary of what was discovered}

**Root Cause:** {if identified}
- {detailed explanation}
- Location: {file:line references}

**Evidence:**
1. {evidence point with reference}
2. {evidence point with reference}
3. {evidence point with reference}

**Confidence:** {HIGH | MEDIUM | LOW}
- {reason for confidence level}

**Recommended Next Steps:**
- {action 1, e.g., "Fix the null check in user_service.py:42"}
- {action 2}
- {action 3 if applicable}

**Related Files:**
- {file1} - {why relevant}
- {file2} - {why relevant}
```

If root cause was NOT identified:

```
**Investigation Summary: {original goal}**

**Status:** Root cause not definitively identified

**Findings:**
- {what was learned}
- {what was ruled out}

**Remaining Hypotheses:**
1. {hypothesis that couldn't be verified} - Blocked by: {what's needed}

**Suggested Follow-up:**
- {what additional investigation is needed}
- {what access/tools would help}
```

---

## Phase 5: Retain Findings

Retain investigation findings to Hindsight for future sessions:

```bash
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory retain "$BANK" "Investigation: <goal>. Root cause: <finding or 'not identified'>. Key files: <files>. <any gotchas or patterns discovered>." \
  --context "investigation <topic>" \
  --doc-id "investigate-<topic-slug>" \
  --async
```

---

## Completion

After presenting the summary:

```
/uw:investigate complete.

{summary reference}

What would you like to do next?
```

Use AskUserQuestion:
- **Plan a fix** - Run /uw:plan to plan implementation
- **Investigate further** - Continue with a follow-up question
- **Done for now** - End investigation
