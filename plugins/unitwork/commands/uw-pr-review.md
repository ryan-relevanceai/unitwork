---
name: uw:pr-review
description: Review someone else's PR using 8 parallel specialist agents and post findings as GitHub PR review with inline comments
argument-hint: "<PR number>"
---

# Review a pull request with parallel specialist agents

## Introduction

**Note: The current year is 2026.**

This command reviews someone else's PR using unitwork's 8 parallel specialist agents and posts findings directly to GitHub as a PR review with inline comments and suggestion blocks.

**Key difference from `/uw:review`:** This command is for reviewing *other people's code*, not your own. It posts to GitHub instead of generating a local review document. There is no fix loop — findings are reported, not fixed.

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before fetching the PR. Before reading any code. Before anything else.**

```bash
# MANDATORY: Recall review-related learnings BEFORE any other work (config override → git remote → worktree → pwd)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "code review learnings, past mistakes, type safety issues, security issues, pattern violations" --budget mid --include-chunks
```

### Display Learnings

After recall, display relevant learnings:

```
**Relevant Learnings from Memory:**
- {past review finding or gotcha}
- {pattern violation discovered before}
```

If no relevant learnings found: "Memory recall complete - no relevant learnings found for this review."

### Route Learnings to Agents

Include recalled memories in each review agent's context based on domain (same routing table as `/uw:review`):

| Memory Topic | Route To Agent |
|--------------|----------------|
| Type safety, casting, null handling | type-safety |
| Security vulnerabilities, auth issues | security |
| Patterns, utilities, duplication | patterns-utilities |
| Performance, database, queries | performance-database |
| Architecture, file organization | architecture |
| Complexity, over-engineering | simplicity |
| General gotchas | All agents |

**DO NOT PROCEED to PR fetching until memory recall is complete.**

---

## Required Reading

**Before reviewing, load the `review-standards` skill which contains:**

- 47 issue patterns with detection criteria and severity tiers
- Team standards to enforce
- Implementation checklists

The skill provides the taxonomy reference needed for categorizing findings.

---

## Step 1: Parse PR Number

<pr_number> #$ARGUMENTS </pr_number>

**PR number is required.** Unlike `/uw:review`, this command does not auto-detect from the current branch (you are reviewing someone else's PR, not your own).

**If empty or not a number:** Ask the user: "Which PR would you like to review? Provide the PR number."

**If a GitHub URL is provided:** Extract the PR number from the URL.

## Step 2: Save Current Branch

```bash
ORIGINAL_BRANCH=$(git branch --show-current)
```

Save this to restore after review is complete.

## Step 3: Fetch PR Metadata

```bash
PR_NUMBER={from step 1}

# Get PR metadata
gh pr view $PR_NUMBER --json title,body,headRefName,headRefOid,baseRefName,additions,deletions,author

# Store head SHA for posting review later
HEAD_SHA=$(gh pr view $PR_NUMBER --json headRefOid -q .headRefOid)
```

Capture:
- `title` — PR title (for review context)
- `body` — PR description (for approach understanding)
- `headRefName` — PR branch name
- `headRefOid` — HEAD commit SHA (**used as `commit_id` when posting review**)
- `baseRefName` — base branch (usually `main`)
- `additions` / `deletions` — line counts for scope check
- `author.login` — PR author

## Step 4: Scope Check

```bash
# Get total lines changed
ADDITIONS=$(gh pr view $PR_NUMBER --json additions -q .additions)
DELETIONS=$(gh pr view $PR_NUMBER --json deletions -q .deletions)
TOTAL=$((ADDITIONS + DELETIONS))
```

**If total > 2,000 lines:** Warn and confirm:

```
This PR has {TOTAL} lines changed ({ADDITIONS}+ / {DELETIONS}-).
Large PRs produce more noise. Consider reviewing in focused areas.
```

Use AskUserQuestion:
- **Continue** — Review the full PR
- **Cancel** — Abort review

## Step 5: Checkout PR Branch

```bash
gh pr checkout $PR_NUMBER
```

This gives agents full file access for finding verification. The original branch is restored in the Completion step.

## Step 6: Get Diff

```bash
gh pr diff $PR_NUMBER
```

**Exclude from scope count** (but still include in agent context — agents handle filtering):
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`
- `Cargo.lock`, `poetry.lock`, `Pipfile.lock`
- Files matching `*.generated.*`, `*codegen*`, `*.min.js`, `*.min.css`

## Step 7: Gather Project Rules

Read project conventions so agents can enforce them:

```bash
# Primary convention file
cat CLAUDE.md 2>/dev/null || cat .claude/CLAUDE.md 2>/dev/null

# Follow @doc references if present
# Read any referenced files (e.g., docs/ai/code-conventions.md)
```

Pass the full text of convention docs to agents (especially patterns-utilities). Do not summarize.

---

## Severity Tiers

Same as `/uw:review`:

### Tier 1 - Correctness (Always Higher Priority)
- Security vulnerabilities
- Architecture problems (wrong boundaries, circular deps)
- Implementation bugs (incorrect logic, runtime errors)
- Type safety violations (casting that hides bugs)
- Functionality gaps (missing error handling, edge cases)

### Tier 2 - Cleanliness (Lower Priority)
- Naming clarity
- File organization
- Code duplication (when not causing bugs)
- Comment quality
- Import/style consistency

| Level | Tier 1 (Correctness) | Tier 2 (Cleanliness) |
|-------|---------------------|---------------------|
| P1 CRITICAL | Security vuln, arch causing bugs, runtime errors | (Rare) Cleanliness issue causing production confusion |
| P2 IMPORTANT | Type casting, incomplete guards, boundary violations | Significant duplication, wrong file location |
| P3 NICE-TO-HAVE | Minor edge cases, defensive improvements | Naming nits, comment additions, style consistency |

---

## Approach Sanity Check (Before Agents)

**Before spawning specialist agents, zoom out on the entire diff and ask: "Should this code exist at all?"**

This is the same check as `/uw:review`, but adapted for external review:

### Step 1: Frame the Problem

Extract from PR title, body, commit messages, or branch name:
```
What problem is this PR solving? (one sentence)
```

### Step 2: Measure the Solution

```bash
gh pr diff $PR_NUMBER --stat
```

### Step 3: Check for Existing Solutions

For each new file or significant new function, check:
1. Does a browser/platform/stdlib API already do this?
2. Does an installed dependency already do this?
3. Does a well-known library solve this in fewer lines?

```bash
cat package.json 2>/dev/null | jq -r '.dependencies // {} | keys[]'
cat package.json 2>/dev/null | jq -r '.devDependencies // {} | keys[]'
```

### Step 4: Assess Proportionality

Red flags:
- 100+ lines of new code for something a 5-line API call handles
- New files for functionality that exists as a one-liner
- Hand-rolling infrastructure instead of using libraries
- Building abstractions for a single use case

### Step 5: Verdict

**If the approach is sound:** Continue to specialist agents.

**If the approach is questionable:** Include as a P1 APPROACH_SANITY finding in the review. **Do NOT halt the review** (unlike uw:review) — you are a reviewer, not the author. Still run specialist agents, but note the approach concern prominently in the review body.

---

## Spawn Parallel Review Agents

Launch all 8 review agents in parallel with the diff context. Each agent should reference the issue patterns taxonomy from `review-standards`.

1. **type-safety** - TYPE_SAFETY_IMPROVEMENT, UNNECESSARY_CAST, NULL_HANDLING
2. **patterns-utilities** - EXISTING_UTILITY_AVAILABLE, CODE_DUPLICATION, BETTER_IMPLEMENTATION_APPROACH
3. **performance-database** - DATABASE_INDEX_MISSING, PARALLELIZATION_OPPORTUNITY, PERFORMANCE_OPTIMIZATION
4. **architecture** - ARCHITECTURAL_CONCERN, FILE_ORGANIZATION, WRONG_LOCATION
5. **security** - INJECTION_VULNERABILITY, AUTHENTICATION_BYPASS, AUTHORIZATION_BYPASS, SENSITIVE_DATA_EXPOSURE
6. **simplicity** - REDUNDANT_LOGIC, REMOVE_UNUSED_CODE, CONSOLIDATE_LOGIC
7. **ai-smell-detector** - AI_UNNECESSARY_ABSTRACTION, AI_REIMPLEMENTED_LIBRARY, AI_DEFENSIVE_OVERCODING, AI_CONFIG_EXPLOSION, AI_PREMATURE_OPTIMIZATION, AI_ONETIME_HELPER
8. **memory-validation** - MEMORY_LEARNING_VIOLATION (receives ALL learnings, not domain-filtered)

**Include recalled context in agent prompts:**

```markdown
**Past Learnings (from team memory):**
- {learning 1 relevant to this agent's domain}
- {learning 2}

Watch for these patterns based on past issues.
```

Each agent returns findings in this format:

```markdown
### [PATTERN_NAME] - Severity: P1/P2/P3 - Tier: 1/2

**Location:** `file:line`

**Issue:** What's wrong

**Why:** Link to pattern from issue-patterns.md

**Fix:**
// Before
problematic code

// After
fixed code
```

---

## Finding Verification (Critical)

**Agents are not oracles.** Their findings are hypotheses that must be verified before posting to GitHub.

For each finding from the review agents:

1. **Check factual accuracy**: Does the claim hold up?
   - "Utility exists at X" → Actually read the file, confirm it exists and does what's claimed
   - "Pattern violation" → Verify the pattern actually applies to this context
   - "Security issue" → Confirm the vulnerability is real and exploitable

2. **Check scope relevance**: Is this finding in-scope for the PR?
   - A real issue but unrelated to this change → Dismiss (note for existing code section in review body)
   - A stylistic preference vs actual problem → Dismiss
   - Pre-existing issue not introduced by this change → Move to "Existing Code Issues" in review body

3. **Classify the finding**:
   - **VERIFIED**: Factually correct and in-scope → Include in review
   - **DISMISSED**: False positive or out of scope → Document rationale, do not post

**Only VERIFIED findings are posted as inline comments.**

Findings targeting different files can be verified in parallel. When multiple findings exist, read files for independent findings simultaneously using parallel tool calls before classifying.

---

## Map Findings to Inline Comments

For each VERIFIED finding:

1. **Check if the finding's line appears in the diff** (added/modified line with `+` prefix)
   - **Yes** → Create inline comment using the `line` parameter (file line number on HEAD side)
   - **No** (existing code / context line) → Include in review body summary under "Existing Code Issues"

2. **Format inline comment:**

```markdown
**[P1] PATTERN_NAME** — Tier 1 (Correctness)

**Issue:** Description of what's wrong

**Fix:**
```suggestion
corrected code here
```
```

Use GitHub suggestion blocks where the agent provides a concrete code fix. Omit the suggestion block if the fix is conceptual rather than a specific code change.

---

## Determine Review Event

| Findings | Event |
|----------|-------|
| Any P1 (Correctness or Cleanliness) | `REQUEST_CHANGES` |
| Only P2 or P3 | `COMMENT` |
| No findings | `APPROVE` |

---

## Post Review to GitHub

```
mcp__github__create_pull_request_review(
  owner: {repo_owner},
  repo: {repo_name},
  pull_number: {PR_NUMBER},
  commit_id: {HEAD_SHA from Step 3},
  event: {determined above},
  body: {review summary - see format below},
  comments: [
    { path: "src/file.ts", line: 45, body: "**[P2] TYPE_SAFETY_IMPROVEMENT** — ..." },
    ...
  ]
)
```

### Review Body Format

```markdown
## Code Review

**Scope**: X files, Y lines changed
**Findings**: N raw → M confirmed (Z% filtered by verification)

| Severity | Correctness | Cleanliness |
|----------|-------------|-------------|
| P1 Critical | X | Y |
| P2 Important | X | Y |
| P3 Nice-to-have | X | Y |

{If approach sanity finding:}
### Approach Concern
{APPROACH_SANITY finding details}

{If existing code issues:}
### Existing Code Issues (Informational)
Issues found in code that predates this change. Not blocking, but worth noting:
- `file:line` - {brief description}

See inline comments for details.

---
🤖 Review by [Unit Work](https://github.com/RelevanceAI/unitwork)
```

### If No Findings

Post an `APPROVE` review:

```markdown
## Code Review

**Scope**: X files, Y lines changed
**Result**: No issues found — clean code!

---
🤖 Review by [Unit Work](https://github.com/RelevanceAI/unitwork)
```

### If Posting Fails

If `mcp__github__create_pull_request_review` fails (permissions, network, invalid commit SHA):

1. Save the full review to `.unitwork/review/{DD-MM-YYYY}-pr-{PR_NUMBER}.md`
2. Display the review body and inline comments to the user
3. Suggest: "Review saved locally. You can post it manually or fix the issue and retry."

---

## Restore Original Branch

After review is complete (whether posted successfully or saved locally):

```bash
git checkout $ORIGINAL_BRANCH
```

---

## Completion

```
Review posted for PR #{PR_NUMBER}: {title}

**Review Event:** {REQUEST_CHANGES / COMMENT / APPROVE}

**Findings:**
- P1: {count} ({tier1} correctness, {tier2} cleanliness)
- P2: {count}
- P3: {count}
- Dismissed: {count} (false positives filtered)

**Existing Code Issues:** {count} (informational, in review body)

Patterns found: {list of PATTERN_NAMEs}

Branch restored to: {ORIGINAL_BRANCH}
```
