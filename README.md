# Unit Work Plugin

Human-in-the-loop verification framework for AI-assisted development. Breaks work into "minimum reviewable units" with checkpoints at verifiable boundaries.

> "The largest task an AI can self-validate to 100% accuracy, that is also able to get validated by the minimum amount of human review"

## Installation

```bash
claude /plugin install unitwork
```

## Components

| Component | Count |
|-----------|-------|
| Agents | 9 |
| Commands | 6 |
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

### Required

- **Hindsight CLI** - Memory system for persistent learning
  - Install: https://hindsight.vectorize.io/developer/

### Optional

- **agent-browser** - Browser automation for UI verification
  - Install: `npm install -g agent-browser && agent-browser install`

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
