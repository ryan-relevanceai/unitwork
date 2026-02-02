---
name: uw:harvest
description: Scrape merged PR review comments from GitHub repos, synthesize insights, and store in Hindsight memory
argument-hint: "<owner/repo> [owner/repo ...] [--since YYYY-MM-DD]"
---

# Harvest PR Review Insights

## Introduction

**Note: The current year is 2026.**

This command scrapes inline code review comments and review bodies from merged PRs across one or more GitHub repos, synthesizes them into actionable insights, and stores them in each repo's Hindsight memory bank. Designed to run each morning to capture the previous business day's review feedback.

## Argument Parsing

<arguments> #$ARGUMENTS </arguments>

Parse the arguments into:
- **Repo list**: All arguments matching `owner/repo` pattern (e.g., `RelevanceAI/relevance-app`)
- **`--since` override**: If `--since YYYY-MM-DD` is present, use that date instead of calculating the previous business day

**If no repos provided:** Ask the user: "Which repos should I harvest? Provide one or more in `owner/repo` format (e.g., `RelevanceAI/relevance-app`)."

**Validate each repo** before proceeding:
```bash
gh repo view {owner}/{repo} --json nameWithOwner 2>&1
```
If a repo is not found or inaccessible, warn and skip it: "Warning: Could not access {owner}/{repo} — skipping."

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before fetching PRs. Before calculating dates. Before anything else.**

Memory recall ensures you don't store duplicate insights from previous harvest runs and provides context for better synthesis.

> **If you skip this:** You may retain insights that duplicate what previous harvests already captured, reducing signal-to-noise in Hindsight memory.

### Execute Memory Recall NOW

For each validated repo, recall existing harvest insights to check for overlap:

```bash
# Recall prior harvest insights for each repo being harvested
hindsight memory recall "{repo_name}" "HARVEST insights, code review patterns, recurring review themes" --budget low --include-chunks
```

Where `{repo_name}` is the repo name portion of each `owner/repo` argument (e.g., `relevance-app` from `RelevanceAI/relevance-app`).

### Display Learnings

After recall, display any existing harvest insights:

```
**Prior Harvest Insights for {repo_name}:**
- {existing insight or pattern}
- {another existing insight}
```

If no prior insights found: "No prior harvest insights found for {repo_name}."

Use these during Step 4 synthesis to **avoid duplicating** already-stored patterns. If a new comment matches an existing insight, skip it or note it as reinforcing an existing pattern rather than creating a new entry.

**DO NOT PROCEED to date calculation until memory recall is complete for all repos.**

---

## Step 1: Calculate Date Range

Determine the target date for scraping merged PRs.

**If `--since` was provided:** Use that date directly.

**Otherwise, calculate the previous business day:**

```bash
# Get day of week (1=Mon, 7=Sun)
DOW=$(date +%u)

# Calculate previous business day
if [ "$DOW" -eq 1 ]; then
  # Monday: look back to Friday (3 days)
  SINCE_DATE=$(date -v-3d +%Y-%m-%d 2>/dev/null || date -d '3 days ago' +%Y-%m-%d)
elif [ "$DOW" -eq 7 ]; then
  # Sunday: look back to Friday (2 days)
  SINCE_DATE=$(date -v-2d +%Y-%m-%d 2>/dev/null || date -d '2 days ago' +%Y-%m-%d)
elif [ "$DOW" -eq 6 ]; then
  # Saturday: look back to Friday (1 day)
  SINCE_DATE=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d '1 day ago' +%Y-%m-%d)
else
  # Tue-Fri: look back 1 day
  SINCE_DATE=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d '1 day ago' +%Y-%m-%d)
fi

echo "Harvesting merged PRs from: $SINCE_DATE"
```

Report the target date to the user:
```
Harvesting merged PRs from: {SINCE_DATE}
Repos: {repo1}, {repo2}, ...
```

---

## Step 2: Fetch Merged PRs Per Repo

For each repo in the repo list, fetch merged PRs from the target date using the GitHub Search API.

```bash
# Find merged PRs on the target date
gh api 'search/issues?q=repo:{owner}/{repo}+is:pr+is:merged+merged:{SINCE_DATE}&per_page=100' \
  --jq '.items[] | {number: .number, title: .title, user: .user.login}'
```

**If zero results for a repo:** Log `"No merged PRs found for {owner}/{repo} on {SINCE_DATE} — skipping."` and continue to the next repo.

**If the API call fails:** Log `"Warning: Failed to fetch PRs for {owner}/{repo} — skipping."` and continue to the next repo.

---

## Step 3: Fetch Review Comments Per PR

For each merged PR found, fetch both inline review comments and review bodies.

### 3a: Inline review comments (code-level feedback)

```bash
gh api 'repos/{owner}/{repo}/pulls/{pr_number}/comments?per_page=100' \
  --jq '[.[] | select(.user.type == "Bot" | not) | select(.user.login | endswith("[bot]") | not) | select((.body | length) >= 20) | {user: .user.login, body: .body, path: .path, line: .line}]'
```

### 3b: Review bodies (summary-level feedback)

```bash
gh api 'repos/{owner}/{repo}/pulls/{pr_number}/reviews?per_page=100' \
  --jq '[.[] | select(.body == null | not) | select(.body == "" | not) | select(.user.type == "Bot" | not) | select(.user.login | endswith("[bot]") | not) | select((.body | length) >= 20) | {user: .user.login, body: .body, state: .state}]'
```

### Filtering Rules

- **Exclude** bot accounts: `.user.type == "Bot"` or username ends with `[bot]`
- **Exclude** trivial comments: body shorter than 20 characters
- **Exclude** empty review bodies (approvals with no written feedback)
- **Include** all human reviewer comments that pass the above filters

Collect all comments into a structured list per repo:

```
## {owner}/{repo} — {SINCE_DATE}

### PR #{number}: {title} (by @{user})

**Inline comments:**
- @{reviewer} on `{path}:{line}`: {body}
- @{reviewer} on `{path}:{line}`: {body}

**Review comments:**
- @{reviewer} ({state}): {body}

### PR #{number}: {title} (by @{user})
...
```

**If a repo has zero comments across all its PRs:** Log `"No review comments found for {owner}/{repo} — skipping synthesis."` and continue to the next repo.

---

## Step 4: Synthesize Insights

For each repo that has collected comments, synthesize them into actionable insights.

### Insight Categories

Group findings into these categories:

1. **Recurring Review Themes** — Patterns flagged across multiple PRs
2. **Code Pattern Recommendations** — Suggestions for better approaches or utilities
3. **Common Gotchas** — Mistakes caught by reviewers that others should avoid
4. **Testing Gaps** — Comments about missing or insufficient tests
5. **Architecture Feedback** — Structural or design-level comments

### Synthesis Rules

- **Cross-PR deduplication**: If multiple PRs have comments about the same pattern, merge into one insight
- **Actionable framing**: Each insight must be framed as advice (not just "reviewer said X" — frame as "when doing Y, remember to Z")
- **Discard trivia**: Skip PR-specific feedback that doesn't generalize to future work
- **Include references**: Note the PR numbers where the pattern was observed (e.g., "observed in PRs #123, #456")
- **Skip empty categories**: Only include categories that have insights

### Example Transformation

```
Raw comments:
- PR #101 @alice on handlers/users.ts:45: "This API handler doesn't validate the request body schema"
- PR #105 @bob on handlers/projects.ts:22: "Missing input validation on the POST endpoint"
- PR #108 @alice on handlers/agents.ts:67: "Should validate against the OpenAPI schema here"

Synthesized insight:
"PATTERN: API handlers frequently miss request body validation. Reviewers flagged
this in PRs #101, #105, #108. When adding new API endpoints, validate request
bodies against the schema before processing."
```

---

## Step 5: Store Insights in Hindsight

For each synthesized insight, store it in the corresponding repo's Hindsight bank.

**Bank name derivation:** Extract the repo name (portion after `/`) from the `owner/repo` argument.
- `RelevanceAI/relevance-app` → bank name `relevance-app`

**Note:** This differs from the standard bank name derivation (which uses `git remote origin URL`) because uw-harvest operates on remote repos, not the local checkout. The extracted name matches in most cases since GitHub repo names are the same slug used in remote URLs. If a repo uses a fork or SSH alias with a different name, the bank names may diverge.

```bash
# Store each insight separately
hindsight memory retain "{repo_name}" \
  "HARVEST insight from code reviews ({SINCE_DATE}): {synthesized insight text}" \
  --context "harvest: code review insight from {repo_name}" \
  --doc-id "harvest-{repo_name}-{SINCE_DATE}-{n}" \
  --async
```

Where `{n}` is a sequential number (1, 2, 3...) for each insight within a repo on that date.

**Important:**
- Always use `--async` to avoid blocking
- One `retain` call per insight (not batched)
- Use the `HARVEST` prefix so these are distinguishable from other memory types during recall

---

## Step 6: Output Summary

After processing all repos, present the harvest summary:

```
Harvest complete for {SINCE_DATE}

{For each repo with insights:}
**{owner}/{repo}** — {X} merged PRs, {Y} review comments collected
Insights stored to Hindsight bank "{repo_name}":
  1. [{category}] {brief insight summary}
  2. [{category}] {brief insight summary}
  ...

{For each repo with no insights:}
**{owner}/{repo}** — No actionable review comments found

**Total:** {N} insights stored across {M} repos

To verify stored insights:
hindsight memory recall "{repo_name}" "code review patterns" --budget low
```
