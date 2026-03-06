# Unit Work

A Claude Code plugin with tools for structured AI development. Use them together as a workflow, or pick individual tools as needed.

## Install

```
/plugin marketplace add ryan-relevanceai/unitwork
/plugin install unitwork@ryan-relevanceai-unitwork
```

## Philosophy

AI completes features 70-80% correctly. Reviewing massive diffs to find the remaining 20% is painful. Unit Work addresses this by:

1. **Breaking work into reviewable units** with checkpoints at verifiable boundaries
2. **Running exhaustive multi-agent review** that catches what single-pass review misses
3. **Compounding learnings** so AI gets better at YOUR codebase over time

These tools work independently. Know what to build? Skip the plan, use vanilla Claude Code, then run `/uw:review` and `/uw:pr`. Want the full structured workflow? Go `/uw:plan` → `/uw:work` → `/uw:review` → `/uw:pr`.

## Commands

### Build

| Command | Description |
|---------|-------------|
| `/uw:plan` | Interview-driven planning. Explores codebase, clarifies requirements, creates spec with implementation units. Takes ~15min — skip if you know what to build. |
| `/uw:work` | Implements a spec with checkpoints at verifiable boundaries. Each checkpoint is a commit with a verification document and confidence score. |

### Review & Ship

| Command | Description |
|---------|-------------|
| `/uw:review` | Spawns 7 parallel review agents (type-safety, patterns, performance, architecture, security, simplicity, memory-validation). Verifies findings before presenting. Fixes P1 issues automatically. |
| `/uw:pr` | Creates or updates GitHub PRs with AI-generated descriptions. |
| `/uw:compound` | Extracts learnings from the implementation journey and stores them for future sessions. Auto-triggered after `/uw:review`. |

### Fix & Maintain

| Command | Description |
|---------|-------------|
| `/uw:fix-ci` | Autonomously fixes failing CI. Cycles through analyze → fix → commit → push → verify until CI passes (max 5 cycles). |
| `/uw:fix-conflicts` | Intelligent rebase conflict resolution. Spawns intent + impact analysis agents, auto-resolves high-confidence conflicts, interviews you for ambiguous ones. |
| `/uw:action-comments` | Bulk resolves GitHub PR review comments with checkpoint-based verification. |

### Investigate & Test

| Command | Description |
|---------|-------------|
| `/uw:investigate` | Read-only codebase investigation. Runs tests and temp scripts to verify hypotheses without modifying production code. |
| `/uw:test-plan` | Generates manual testing steps from git diffs. Analyzes frontend + backend changes and produces one continuous end-to-end test plan. |
| `/uw:browser-test` | Browser automation via agent-browser for UI verification, form filling, screenshots, and scraping. |
| `/uw:momentic` | Run, create, debug, or upload Momentic E2E tests with video recording. |

### Session Management

| Command | Description |
|---------|-------------|
| `/uw:park` | Parks current work session to a GitHub PR comment for multi-device handoff. |
| `/uw:resume` | Resumes a parked work session by reading PR parking comments and local artifacts. |
| `/uw:harvest` | Scrapes merged PR review comments from GitHub repos, synthesizes insights, and stores them for future sessions. |
| `/uw:bootstrap` | First-time setup: configure Hindsight memory bank and explore codebase. Only needed if using Hindsight. |

## Agents

15 specialized agents spawned by commands — you don't invoke these directly.

| Category | Agents | Used By |
|----------|--------|---------|
| **Review** (7) | type-safety, patterns-utilities, performance-database, architecture, security, simplicity, memory-validation | `/uw:review` |
| **Plan Review** (3) | gap-detector, feasibility-validator, utility-pattern-auditor | `/uw:plan` |
| **Verification** (2) | test-runner, api-prober | `/uw:work`, `/uw:fix-ci` |
| **Conflict Resolution** (2) | conflict-intent-analyst, conflict-impact-explorer | `/uw:fix-conflicts` |
| **Exploration** (1) | memory-aware-explore | `/uw:plan`, `/uw:bootstrap` |

## MCP Servers

**Context7** — Retrieves up-to-date library documentation and code examples. Used during planning and implementation to research framework patterns.

## Hindsight (Optional)

[Hindsight](https://github.com/vectorize-io/hindsight) gives the plugin persistent memory across sessions. Commands recall past learnings before starting and retain new discoveries when done. Without it, the plugin works fine — you just won't get cross-session memory.

### Setup

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export HINDSIGHT_API_LLM_PROVIDER=openai
export HINDSIGHT_API_LLM_BASE_URL=https://openrouter.ai/api/v1
export HINDSIGHT_API_LLM_API_KEY=<your-openrouter-key>
export HINDSIGHT_API_LLM_MODEL=google/gemini-3-flash-preview
```

Start the container (runs in the background):

```bash
docker run -d --name hindsight --pull always -p 8888:8888 -p 9999:9999 \
  -e HINDSIGHT_API_LLM_API_KEY=$HINDSIGHT_API_LLM_API_KEY \
  -e HINDSIGHT_API_LLM_PROVIDER=$HINDSIGHT_API_LLM_PROVIDER \
  -e HINDSIGHT_API_LLM_BASE_URL=$HINDSIGHT_API_LLM_BASE_URL \
  -e HINDSIGHT_API_LLM_MODEL=$HINDSIGHT_API_LLM_MODEL \
  -v $HOME/.hindsight-docker:/home/hindsight/.pg0 \
  ghcr.io/vectorize-io/hindsight:latest
```

Then run `/uw:bootstrap` to configure the memory bank for your project.

```bash
docker stop hindsight    # Stop
docker start hindsight   # Start again
docker logs hindsight    # View logs
```

## License

MIT
