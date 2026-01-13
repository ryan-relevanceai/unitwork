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

```bash
# Try git remote first
BANK_NAME=$(git remote get-url origin 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//')

# Fall back to directory name
if [ -z "$BANK_NAME" ]; then
    BANK_NAME=$(basename $(pwd))
fi

echo "Using bank name: $BANK_NAME"
```

## Step 3: Configure Bank Disposition

```bash
# Set bank background
hindsight bank background "$BANK_NAME" "I am a development assistant working on the $BANK_NAME codebase.
I track file locations, architectural patterns, gotchas, and decision rationale to help
navigate and understand the codebase efficiently."

# Set disposition (high skepticism for code work)
hindsight bank disposition "$BANK_NAME" --skepticism 5 --literalism 3 --empathy 2
```

**Disposition Traits (1-5 scale):**
- **Skepticism (5)**: Question past assumptions - code changes fast
- **Literalism (3)**: Balance between flexible and literal interpretation
- **Empathy (2)**: Focus on technical accuracy over emotional considerations

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

Based on user's selection (or defaults), explore key areas:

### Default Exploration Targets

1. **Entry points**: `main.*`, `app.*`, `index.*`
2. **Configuration**: `config/`, `.env*`, settings files
3. **Models/Schema**: `models/`, `schema.*`, migrations
4. **Routes/Controllers**: `routes/`, `controllers/`, API definitions
5. **Services**: `services/`, business logic
6. **Tests**: `test/`, `spec/`, `__tests__/`

### For Each Area

1. Read key files
2. Document patterns discovered
3. Note naming conventions
4. Identify main services/modules

### Retain Discoveries

```bash
hindsight memory retain "$BANK_NAME" "In repo $BANK_NAME, codebase structure:
- Entry point: <file>
- Models in: <path>
- Routes defined in: <path>
- Services pattern: <description>
- Testing with: <framework>
Key services: <list>" \
  --context "$BANK_NAME: bootstrap exploration" \
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

Add `.unitwork/` to `.gitignore` if not already present (optional - some teams prefer to track these).

## Step 7: Report

```
Bootstrap complete for: {BANK_NAME}

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
