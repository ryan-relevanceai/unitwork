---
name: uw:bootstrap
description: First-time setup for Unit Work - check dependencies, configure Hindsight bank, explore codebase
argument-hint: ""
---

# Bootstrap Unit Work for a new codebase

## Introduction

**Note: The current year is 2026.**

Bootstrap runs intensive initial exploration on a new codebase and configures Hindsight memory for persistent learning across sessions.

## Step 1: Check Dependencies

### Hindsight CLI

```bash
if ! command -v hindsight &> /dev/null; then
    echo "Hindsight not found."
    echo "Install from: https://hindsight.vectorize.io/developer/"
    exit 1
fi
```

If Hindsight is missing, stop and ask user to install it.

### agent-browser

```bash
if ! command -v agent-browser &> /dev/null; then
    echo "agent-browser not found."
    echo "Run: npm install -g agent-browser && agent-browser install"
fi
```

If agent-browser is missing, note it but continue (only needed for UI verification).

### Context7 MCP

Context7 is bundled with the unitwork plugin as an MCP server. No installation needed.

Use it for framework documentation lookup:
```
mcp__unitwork_context7__resolve-library-id  # Find library ID
mcp__unitwork_context7__query-docs          # Query documentation
```

## Step 2: Derive Bank Name

The bank name is derived from the git remote URL (handles worktrees), falling back to main worktree name or directory:
```bash
# Inline derivation (handles worktrees - all worktrees share same bank)
$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
```

## Step 3: Configure Bank Background

```bash
# Set bank background (disposition is automatically inferred from background content)
hindsight bank background "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "I am a development assistant working on this codebase.
I track file locations, architectural patterns, gotchas, and decision rationale to help
navigate and understand the codebase efficiently.
I maintain high skepticism about past assumptions since code changes fast.
I balance between flexible and literal interpretation of requirements.
I focus on technical accuracy over emotional considerations."
```

The background content shapes the bank's disposition - Hindsight automatically infers skepticism, literalism, and empathy from the background text.

## Step 4: Ask User About Key Areas

Use AskUserQuestion:

**Question:** "Which areas of the codebase are most important to understand?"

**Options:**
- **Authentication/Authorization** - Login, permissions, security
- **Core business logic** - Main domain models and services
- **API layer** - Routes, controllers, endpoints
- **Database** - Models, migrations, queries
- **Frontend/UI** - Views, components, styling
- **Not sure** - Use defaults (entry points, models, routes, tests)

Allow multiple selections.

## Step 5: Deep Exploration

Based on user's selection (or defaults), explore key areas using **memory-aware exploration agents** to preserve main thread context and compound findings across sessions.

### Launch Memory-Aware Explore Agents

Spawn 2 memory-aware exploration agents **in parallel** (single message, multiple Task tool calls) with specific focuses:

**Agent 1 - Architecture & Entry Points:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Feature context: codebase architecture

Explore this codebase to understand architecture and entry points:
1. Find entry points: main.*, app.*, index.*
2. Locate configuration: config/, .env*, settings files
3. Identify models/schema: models/, schema.*, migrations
4. Map routes/controllers: routes/, controllers/, API definitions
5. Document the overall architecture pattern (MVC, service-oriented, etc.)
6. Note key dependencies from package.json, requirements.txt, Gemfile, etc.

Report: file locations, architecture patterns, and naming conventions discovered."
```

**Agent 2 - Tests & Utilities:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Feature context: testing and utilities

Explore this codebase to understand testing patterns and utilities:
1. Find test directories: test/, spec/, __tests__/
2. Identify test framework (Jest, pytest, RSpec, etc.)
3. Document test naming conventions and patterns
4. Locate shared utilities and helpers
5. Find service layer: services/, business logic
6. Note any existing patterns for error handling, logging, validation

Report: test framework, utility locations, and reusable patterns discovered."
```

### After Agents Complete

1. Review agent outputs for key discoveries
2. Identify main services/modules
3. Note any gotchas or unusual patterns

### Retain Discoveries

```bash
hindsight memory retain "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "Codebase structure:
- Entry point: <file>
- Models in: <path>
- Routes defined in: <path>
- Services pattern: <description>
- Testing with: <framework>
Key services: <list>" \
  --context "bootstrap exploration" \
  --doc-id "bootstrap" \
  --async
```

## Step 6: Create Directory Structure

```bash
mkdir -p .unitwork/specs
mkdir -p .unitwork/verify
mkdir -p .unitwork/review
mkdir -p .unitwork/learnings
```

## Step 7: Report

```
Bootstrap complete for: {repo-name}

**Dependencies:**
- Hindsight CLI: {status}
- agent-browser: {status}

**Codebase Summary:**
- {X} main services/modules found
- {pattern} architecture pattern detected
- {framework} for testing
- {framework} for API

**Key Discoveries:**
- {discovery 1}
- {discovery 2}
- {discovery 3}

**Created:**
- .unitwork/specs/     (feature specifications)
- .unitwork/verify/    (checkpoint verification docs)
- .unitwork/review/    (code review findings)
- .unitwork/learnings/ (compound phase output)

Ready for /uw:plan to start planning your first feature.
```

## First Feature Suggestion

After bootstrap, suggest:

"Would you like to start planning a feature now? Run `/uw:plan` with a description of what you want to build."
