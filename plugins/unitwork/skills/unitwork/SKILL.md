---
name: unitwork
description: "This skill should be used when implementing features with human-in-the-loop verification. It provides the core Unit Work methodology including checkpoint-based development, confidence assessment, memory integration with Hindsight, and verification strategies. Use this skill for planning features, executing with checkpoints, reviewing code, and compounding learnings."
---

# Unit Work - Human-in-the-Loop Verification Framework

> "The largest task an AI can self-validate to 100% accuracy, that is also able to get validated by the minimum amount of human review"

## Core Philosophy

Unit Work replaces arbitrary development phases with a verification-driven approach:

1. **Front-load work** in interview and planning stages
2. **Use Hindsight memory** to compound learnings across sessions
3. **Create checkpoints** at verifiable boundaries, not arbitrary phases
4. **Treat commits as checkpoints** with verification documents
5. **Know your gaps** and invite human verification where AI is weak

## AI Capability Awareness

**AI is strong at verifying:**
- API endpoints (especially with before/after DB state)
- Backend logic and data transformations
- Test execution and result parsing

**AI is weak at verifying:**
- Visual design and layout
- UI component placement and spacing
- Spatial relationships ("does X overlap Y")

The plugin adapts confidence and checkpoint behavior based on these strengths/weaknesses.

## Workflow Overview

```
/uw:plan -> /uw:work -> /uw:review -> /uw:compound
    |           |            |             |
  Spec.md   Checkpoints   Code Review   Learnings
            + Verify.md   + Fix Loop    to memory
                              |
                          Create PR
```

## Decision Trees

See [decision-trees.md](./references/decision-trees.md) for detailed decision flows:
- When to checkpoint
- When to ask user vs decide autonomously
- When to use each memory operation
- Which verification subagent to use

## Templates

- [Spec Template](./templates/spec.md) - Feature specification format
- [Verify Template](./templates/verify.md) - Checkpoint verification document
- [Learnings Template](./templates/learnings.md) - Compound phase output

## Directory Structure

Unit Work creates this structure in your project:

```
.unitwork/
├── specs/           # {DD-MM-YYYY}-{feature}.md
├── verify/          # {DD-MM-YYYY}-{n}-{name}.md
├── review/          # Code review findings
└── learnings/       # Compound phase output
```

## Agent Behavior Rules

### Interview Phase
1. Research before asking - check Hindsight, codebase, then web docs
2. Group related questions - don't ask one at a time
3. Push back on scope - "That sounds like a separate feature"
4. Advocate once - state recommendation, then accept decision
5. No premature solutions - don't propose implementation during requirements
6. Confirm understanding - summarize before writing spec

### Implementation Phase
1. Follow the spec - it's the contract
2. Minimal changes - smallest diff that satisfies requirement
3. No drive-by refactoring - note tech debt, don't fix it
4. No drive-by bug fixes - unless critical and blocking
5. Checkpoint at boundaries - every verifiable unit
6. Document uncertainty - say so in checkpoint
7. Never skip verification - even if confident

### Verification Phase
1. Tests first - always run relevant tests
2. API safety - never call mutating endpoints without permission
3. Screenshot everything - UI changes always get screenshots
4. Explicit confidence - state percentage with rationale
5. Human QA reproducible - no LLM-dependent steps
6. Precursor state documented - if testing needs setup, document how

### Memory Rules
1. Always async - never block on memory writes
2. Always contextualized - include repo name and work context
3. Document tracking - group by feature doc-id
4. Narrative format - write as natural language
5. Retain discoveries immediately - don't wait for phase end
6. Blind spots are critical - always retain when human finds what agent missed

## Checkpoint Commit Format

```
checkpoint({unit-number}): {brief description}

Unit: {unit-name from plan}
Confidence: {percentage}%
Verification: {test-runner|api-prober|browser|manual}

See: .unitwork/verify/{DD-MM-YYYY}-{checkpoint-number}-{short-name}.md
```

## Hindsight Integration

### Bank Configuration
- One bank per project (isolated memories)
- Bank name derived from git remote or directory
- High skepticism (5) - question assumptions, code changes fast
- Moderate literalism (3) - balance flexibility
- Low empathy (2) - focus on technical accuracy

### Memory Operations

**Recall (cheap, use freely):**
```bash
hindsight memory recall $BANK "query" --budget low|mid|high
```

**Retain (expensive, always async):**
```bash
hindsight memory retain $BANK "narrative" --context "context" --doc-id "id" --async
```

**Reflect (for reasoning):**
```bash
hindsight memory reflect $BANK "question" --context "context"
```

## Context7 Integration

Context7 provides framework documentation lookup via MCP. Use it when implementing unfamiliar APIs.

### Usage

```
Step 1: Resolve library ID
mcp__unitwork_context7__resolve-library-id
  query: "what you're trying to implement"
  libraryName: "framework-name"

Step 2: Query documentation
mcp__unitwork_context7__query-docs
  libraryId: "/org/project"  (from step 1)
  query: "specific API or pattern"
```

### When to Use
- Unfamiliar framework APIs (check docs before guessing)
- Best practices for specific patterns
- Version-specific behavior differences
- Implementation examples from official docs

### When NOT to Use
- Project-specific patterns (use Hindsight)
- Simple/well-known APIs
- Already checked docs this session

## Verification Subagents

| Subagent | Purpose | When to Use |
|----------|---------|-------------|
| test-runner | Execute tests | Changed test files or tested code |
| api-prober | Probe API endpoints | Changed API endpoints |
| browser-automation | UI verification | Changed UI components |

## Review Agents (Parallel)

| Agent | Focus |
|-------|-------|
| type-safety | Casting, guards, nullability |
| patterns-utilities | Existing solutions, duplication |
| performance-database | N+1, indexes, parallelization |
| architecture | Structure, coupling, boundaries |
| security | Injection, auth, data exposure |
| simplicity | Over-engineering, YAGNI |

## Confidence Assessment

Start at 100%, subtract:
- -5% for each untested edge case
- -20% if UI layout changes
- -10% if complex state management
- -15% if external API integration

**>= 95%**: Checkpoint and continue
**< 95%**: Checkpoint and pause for human review

## Commands

- `/uw:plan` - Interview and create spec
- `/uw:work` - Execute with checkpoints
- `/uw:review` - Parallel code review
- `/uw:compound` - Extract learnings
- `/uw:bootstrap` - First-time setup
- `/uw:action-comments` - Resolve PR comments
