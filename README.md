# Unit Work Plugin

Human-in-the-loop verification framework for AI-assisted development. Breaks work into "minimum reviewable units" with checkpoints at verifiable boundaries.

> "The largest task an AI can self-validate to 100% accuracy, that is also able to get validated by the minimum amount of human review"

## Installation

```bash
/plugin marketplace add https://github.com/ryan-relevanceai/unitwork
/plugin install unitwork
```

## Components

| Component | Count |
|-----------|-------|
| Agents | 9 |
| Commands | 7 |
| Skills | 1 |
| MCP Servers | 1 |

## Philosophy

Unit Work addresses the "70-80% completion problem" - AI tends to complete features 70-80% correctly, making manual review of massive diffs cumbersome. The solution:

1. **Front-load work** in interview and planning stages
2. **Create checkpoints** at verifiable boundaries, not arbitrary phases
3. **Know your gaps** - AI is strong at backend verification, weak at visual/spatial
4. **Compound learnings** via Hindsight memory across sessions

## Workflow

```
/uw:plan -> /uw:work -> /uw:review -> /uw:compound
    |           |            |             |
  Spec.md   Checkpoints   Code Review   Learnings
            + Verify.md   + Fix Loop    to memory
```

## Commands

### Core Workflow

| Command | Description |
|---------|-------------|
| `/uw:plan` | Interview user, explore codebase, create spec with implementation units |
| `/uw:work` | Execute plan with checkpoints at verifiable boundaries |
| `/uw:review` | Spawn 6 parallel review agents for exhaustive code review |
| `/uw:compound` | Extract and store learnings to Hindsight + local files |

### Utilities

| Command | Description |
|---------|-------------|
| `/uw:bootstrap` | First-time setup: check deps, configure Hindsight, explore codebase |
| `/uw:action-comments` | Bulk resolve GitHub PR comments |
| `/uw:pr` | Create or update GitHub PRs with AI-generated descriptions |

## Agents

### Verification Agents (3)

| Agent | Purpose |
|-------|---------|
| `test-runner` | Execute test suites and report structured results |
| `api-prober` | Make API calls to verify endpoints (read-only unless permitted) |
| `browser-automation` | UI verification via agent-browser (flags layout for human review) |

### Review Agents (6)

| Agent | Focus |
|-------|-------|
| `type-safety` | Casting, type guards, nullability, `any` usage |
| `patterns-utilities` | Existing solutions, duplication, pattern violations |
| `performance-database` | N+1 queries, missing indexes, parallelization |
| `architecture` | File locations, coupling, boundary violations |
| `security` | Injection, auth bypasses, data exposure, OWASP top 10 |
| `simplicity` | Over-engineering, YAGNI, premature abstraction |

## Skills

### unitwork

Core skill containing:
- Philosophy and methodology
- Decision trees for checkpoints and verification
- Agent behavior rules
- Templates for specs, verification docs, and learnings

## MCP Servers

### Context7

Retrieves up-to-date documentation and code examples for any library. Used during `/uw:plan` and `/uw:work` to research framework patterns and best practices.

## Requirements

### Prerequisites

- **Docker** - [Install Docker](https://docs.docker.com/get-docker/)
- **Node.js 18+** - [Install Node.js](https://nodejs.org/)

### Quick Install

Run the install script to set up all dependencies:

```bash
./install_deps.sh
```

This script installs the Hindsight CLI and agent-browser, then prints instructions for starting the Hindsight Docker container.

Or install manually using the commands below.

---

### Required: Hindsight

Memory system for persistent learning across sessions.

#### Step 1: Set Environment Variables

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export HINDSIGHT_API_LLM_PROVIDER=openai
export HINDSIGHT_API_LLM_BASE_URL=https://openrouter.ai/api/v1
export HINDSIGHT_API_LLM_API_KEY=<your-openrouter-key>
export HINDSIGHT_API_LLM_MODEL=google/gemini-3-flash-preview
```

**Recommended:** OpenRouter with Gemini 3 Flash provides good performance at low cost.

#### Step 2: Start Hindsight Container

```bash
docker run -d --name hindsight --pull always -p 8888:8888 -p 9999:9999 \
  -e HINDSIGHT_API_LLM_API_KEY=$HINDSIGHT_API_LLM_API_KEY \
  -e HINDSIGHT_API_LLM_PROVIDER=$HINDSIGHT_API_LLM_PROVIDER \
  -e HINDSIGHT_API_LLM_BASE_URL=$HINDSIGHT_API_LLM_BASE_URL \
  -e HINDSIGHT_API_LLM_MODEL=$HINDSIGHT_API_LLM_MODEL \
  -v $HOME/.hindsight-docker:/home/hindsight/.pg0 \
  ghcr.io/vectorize-io/hindsight:latest
```

**Container management:**

```bash
docker stop hindsight    # Stop the container
docker start hindsight   # Start it again
docker logs hindsight    # View logs
```

#### Step 3: Install Hindsight CLI

```bash
# macOS
brew install vectorize-io/tap/hindsight

# Linux (x86_64)
curl -L https://github.com/vectorize-io/hindsight/releases/latest/download/hindsight-linux-x86_64 -o hindsight
chmod +x hindsight && sudo mv hindsight /usr/local/bin/

# Verify
hindsight --version
```

#### Alternative: Native Install

See the [Hindsight Developer Docs](https://hindsight.vectorize.io/) for running Hindsight without Docker.

---

### Optional: agent-browser

Browser automation for UI verification during `/uw:work`.

```bash
# Requires Node.js 18+
npm install -g @anthropic/agent-browser
agent-browser install

# Verify
agent-browser --version
```

## Directory Structure

Unit Work creates this structure in your project:

```
.unitwork/
├── specs/           # Feature specifications
├── verify/          # Checkpoint verification docs
├── review/          # Code review findings
└── learnings/       # Compound phase output
```

## Checkpoint System

### Confidence Assessment

Checkpoints are created at verifiable boundaries with confidence scores:

- **>= 95% confidence**: Checkpoint and continue
- **< 95% confidence**: Checkpoint and pause for human review

Confidence calculation:
- Start at 100%
- -5% for each untested edge case
- -20% if UI layout changes
- -10% if complex state management
- -15% if external API integration

### Commit Format

```
checkpoint({unit-number}): {brief description}

Unit: {unit-name from plan}
Confidence: {percentage}%
Verification: {test-runner|api-prober|browser|manual}

See: .unitwork/verify/{DD-MM-YYYY}-{checkpoint-number}-{short-name}.md
```

## Hindsight Integration

Unit Work uses Hindsight for persistent memory across sessions:

- **One bank per project** (isolated memories)
- **High skepticism (5)** - question past assumptions
- **Narrative format** - memories written as natural language
- **Async writes** - never block on memory operations

### Memory Types

1. **File Purposes** - Where things live and what they do
2. **Architectural Patterns** - How the codebase is structured
3. **Gotchas & Quirks** - Things that cause friction
4. **Decision Rationale** - Why choices were made

## Getting Started

1. Bootstrap the plugin:
   ```bash
   /uw:bootstrap
   ```

2. Plan a feature:
   ```bash
   /uw:plan "Add password reset functionality"
   ```

3. Execute with checkpoints:
   ```bash
   /uw:work
   ```

4. Review before PR:
   ```bash
   /uw:review
   ```

## License

MIT
