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
| Agents | 13 |
| Commands | 8 |
| Skills | 2 |
| MCP Servers | 1 |

## Philosophy

Unit Work addresses the "70-80% completion problem" - AI tends to complete features 70-80% correctly, making manual review of massive diffs cumbersome. The solution:

1. **Front-load work** in interview and planning stages
2. **Create checkpoints** at verifiable boundaries, not arbitrary phases
3. **Know your gaps** - AI is strong at backend verification, weak at visual/spatial
4. **Compound learnings** via Hindsight memory across sessions

## How Unit Work Compounds

Each workflow phase contributes to a learning loop that compounds knowledge across sessions:

```
Session 1: Bootstrap → Plan → Work → Review → Compound
                ↓         ↓       ↓        ↓         ↓
           Codebase   Planning  Gotchas  Review   Feature
           patterns   learnings         patterns  learnings
                ↓         ↓       ↓        ↓         ↓
                └─────────┴───────┴────────┴─────────┘
                                  ↓
                            Hindsight Memory
                                  ↓
Session 2: Plan ← recalls learnings from Session 1
```

**What gets compounded:**
- **File purposes** - Where things live and what they do
- **Architectural patterns** - How the codebase is structured
- **Gotchas & quirks** - Things that cause friction or unexpected behavior
- **Verification blind spots** - What automated checks miss

**How it works:**
1. Each phase starts with **Memory Recall** - loading relevant learnings before starting work
2. During work, discoveries are noted in verification documents
3. After completion, `/uw:compound` extracts reusable learnings and stores them to Hindsight
4. Future sessions recall these learnings, avoiding repeated mistakes

The result: AI assistance that gets better at YOUR codebase over time, not just better at coding in general.

## Workflow

```
┌─────────────┐
│ uw:bootstrap│  (First-time setup)
└──────┬──────┘
       ▼
┌─────────────┐
│  uw:plan    │  (Create spec)
└──────┬──────┘
       ▼
┌─────────────┐
│  uw:work    │  (Implement with checkpoints)
└──────┬──────┘
       ▼
┌─────────────┐
│  uw:review  │───► uw:compound (auto-triggered)
└──────┬──────┘
       ▼
┌─────────────┐
│   uw:pr     │  (Create PR)
└──────┬──────┘
       │
  ┌────┴────┐
  ▼         ▼
uw:fix-ci  uw:action-comments
(CI fails)  (PR comments)
  │         │
  └────┬────┘
       ▼
    (Merge)
```

## Commands

### Core Workflow

| Command | Description |
|---------|-------------|
| `/uw:plan` | Interview user, explore codebase, create spec with implementation units |
| `/uw:work` | Execute plan with checkpoints at verifiable boundaries |
| `/uw:review` | Spawn 6 parallel review agents for exhaustive code review |
| `/uw:compound` | Extract and store learnings to Hindsight + local files |

#### /uw:plan

Creates a detailed spec by interviewing you and exploring the codebase. Ensures all requirements are captured before implementation begins.

**Key phases:**
1. **Memory Recall** - Loads relevant learnings from Hindsight to avoid repeating past mistakes
2. **Context Gathering** - Spawns 3 parallel exploration agents to find related code, test patterns, and existing utilities
3. **Interview** - Clarifies requirements, edge cases, testing strategy, and integration points
4. **Plan Review** - Validates the draft plan with 3 review agents before presenting (convergence required)

**Compounds:** Retains discovered file locations, patterns, and architectural decisions to Hindsight for future sessions.

#### /uw:work

Implements the spec with checkpoints at verifiable boundaries. Each checkpoint is a commit with verification documentation.

**Key phases:**
1. **Memory Recall** - Loads gotchas and learnings relevant to the task
2. **Implement** - Works through each unit as specified, querying Context7 for unfamiliar APIs
3. **Verify** - Launches subagents (test-runner, api-prober, browser-automation) based on what changed
4. **Checkpoint** - Creates commit with confidence score; ≥95% continues, <95% pauses for review

**Compounds:** Retains verification blind spots and unexpected issues as gotchas for future reference.

#### /uw:review

Runs exhaustive code review using 6 parallel agents. Finds issues that single-pass review misses.

**Key phases:**
1. **Memory Recall** - Loads past review learnings to inform current review
2. **Parallel Review** - Spawns 6 agents (type-safety, patterns, performance, architecture, security, simplicity)
3. **Finding Verification** - Each finding is independently verified (agents are not oracles)
4. **Fix Loop** - P1 issues are fixed immediately; P2/P3 presented for decision

**Compounds:** Auto-triggers `/uw:compound` to extract learnings from the implementation journey.

#### /uw:compound

Extracts learnings from the implementation and stores them for future sessions. Documents what deviated from the plan.

**Key phases:**
1. **Gather Context** - Collects spec, verification docs, review findings, and git history
2. **Extract Learnings** - Focuses on delta between plan and reality (gotchas, surprises, patterns)
3. **Local Documentation** - Creates `.unitwork/learnings/{date}-{feature}.md`
4. **Hindsight Retention** - Stores learnings by feature *type* for transferability across projects

**Compounds:** This IS the compounding phase - it transforms implementation experience into reusable knowledge.

### Utilities

| Command | Description |
|---------|-------------|
| `/uw:bootstrap` | First-time setup: check deps, configure Hindsight, explore codebase |
| `/uw:pr` | Create or update GitHub PRs with AI-generated descriptions |
| `/uw:action-comments` | Bulk resolve GitHub PR comments |
| `/uw:fix-ci` | Autonomously fix failing CI with analyze→fix→commit→push→verify loop |

#### /uw:bootstrap

One-time setup when adopting Unit Work on a new codebase. Configures Hindsight and builds initial codebase understanding.

**Key phases:**
1. **Check Dependencies** - Verifies Hindsight CLI (required), agent-browser (optional)
2. **Configure Hindsight** - Sets up memory bank with high skepticism for the project
3. **Deep Exploration** - Spawns 2 parallel agents to map architecture, entry points, tests, and utilities
4. **Create Directory Structure** - Sets up `.unitwork/` folders for specs, verify, review, learnings

**Compounds:** Retains initial codebase exploration findings (file purposes, patterns, key entry points) to Hindsight.

#### /uw:pr

Creates or updates GitHub PRs with AI-generated descriptions. Handles both new PR creation and updates to existing PRs.

**Key phases:**
1. **Verify Environment** - Checks git repo and gh CLI authentication
2. **Gather Context** - Collects diff, commits, and file changes since branch divergence
3. **Generate Description** - Creates PR description with context, changes summary, and notes
4. **Create/Update PR** - Creates draft PR or updates existing PR description

**Compounds:** Does not compound - PR metadata is transient and project-specific.

#### /uw:action-comments

Bulk resolves GitHub PR comments by categorizing each comment and implementing appropriate responses.

**Key phases:**
1. **Fetch Comments** - Retrieves pending PR comments with file/line references
2. **Categorize** - Classifies each as VALID_FIX, ALREADY_HANDLED, QUESTION, DEFER, or DISAGREE
3. **Implement Fixes** - Applies valid fixes with lightweight verification
4. **Post Replies** - Responds to questions and documents deferrals

**Compounds:** Does not compound - comment resolution is PR-specific.

#### /uw:fix-ci

Autonomously fixes failing CI by cycling through analyze→fix→commit→push→verify until CI passes or limits are reached.

**Key phases:**
1. **Memory Recall** - Loads past CI fix learnings
2. **Analyze Failure** - Parses CI output to identify failing step and error
3. **Fix and Verify** - Implements fix, runs local verification, commits with `fix(ci):` prefix
4. **Poll and Loop** - Pushes, waits for CI, loops back if still failing (max 5 cycles)

**Compounds:** Retains CI fix patterns and gotchas to Hindsight for future CI issues.

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

### Plan Review Agents (3)

| Agent | Focus |
|-------|-------|
| `gap-detector` | Investigation language, unclear APIs, ambiguous requirements |
| `utility-pattern-auditor` | Existing utilities, pattern violations, reinvented wheels |
| `feasibility-validator` | Technical blockers, verification clarity, hidden dependencies |

These agents validate draft plans during `/uw:plan` before presenting to the user. Findings are independently verified (agents are not oracles) before acting.

### Exploration Agents (1)

| Agent | Purpose |
|-------|---------|
| `memory-aware-explore` | Codebase exploration with Hindsight integration (recalls prior findings, retains discoveries) |

## Skills

### unitwork

Core skill containing:
- Philosophy and methodology
- Decision trees for checkpoints and verification
- Agent behavior rules
- Templates for specs, verification docs, and learnings

### review-standards

Code review standards and issue taxonomy:
- 47 issue patterns across 6 review categories
- Severity tiers (Tier 1: correctness, Tier 2: cleanliness)
- Implementation checklists for common patterns
- See: [plugins/unitwork/skills/review-standards/references/issue-patterns.md](plugins/unitwork/skills/review-standards/references/issue-patterns.md)

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
npm install -g agent-browser
agent-browser install  # On Linux, use: agent-browser install --with-deps

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
