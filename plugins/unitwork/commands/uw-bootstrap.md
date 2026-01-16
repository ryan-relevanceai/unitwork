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

## Step 1.5: Detect Existing Setup

Check if this repo already has Unit Work setup:

```bash
# Check .unitwork dir
test -d .unitwork && UNITWORK_EXISTS="yes" || UNITWORK_EXISTS="no"

# Derive bank name
BANK=$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")

# Check bank exists in Hindsight
BANK_EXISTS=$(hindsight bank list -o json 2>&1 | grep -q "\"bank_id\": \"$BANK\"" && echo "yes" || echo "no")
```

**If EITHER `.unitwork` exists OR bank exists:**

Use AskUserQuestion to prompt:

**Question:** "Existing setup detected. What would you like to do?"

**Options:**
- **Full setup** - Re-run exploration and import team learnings
- **Sync learnings only** - Skip exploration, just import team learnings from .unitwork/learnings/
- **Exit** - Keep current state

**If user selects:**
- **Full setup:** Continue to Step 2 (proceed with normal bootstrap)
- **Sync learnings only:** Skip to Step 7.5 (learnings import section)
- **Exit:** Stop bootstrap with message "Bootstrap cancelled. Current setup preserved."

**If NEITHER exists:** Continue to Step 2 (fresh setup).

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

## Step 7.5: Import Team Learnings

**Note:** This step runs for both full setup (after Step 7) and sync-only mode (skipping directly here from Step 1.5).

### Check for Learnings Directory

```bash
# Check if learnings directory exists and has .md files
if [ -d ".unitwork/learnings" ] && [ "$(find .unitwork/learnings -name '*.md' 2>/dev/null | head -1)" ]; then
    LEARNINGS_EXIST="yes"
else
    LEARNINGS_EXIST="no"
fi
```

**If no learnings exist:** Skip to Step 8 with message "No team learnings found to import."

### Build Filtered Import List

Get setup variables:
```bash
CURRENT_USER=$(git config user.email)
LAST_IMPORT=$(jq -r '.lastLearningsImport // "1970-01-01T00:00:00Z"' .unitwork/.bootstrap.json 2>/dev/null || echo "1970-01-01T00:00:00Z")
```

Build list of files to import (must satisfy BOTH conditions):
1. Authored by someone else (exact email match)
2. Modified after last import timestamp

```bash
IMPORT_LIST=()

for file in .unitwork/learnings/*.md; do
    [ -f "$file" ] || continue

    # Skip untracked files (no git history)
    if ! git ls-files --error-unmatch "$file" &>/dev/null; then
        continue
    fi

    # Get original author email (who first created the file)
    AUTHOR=$(git log --follow --diff-filter=A --format='%ae' -- "$file" | head -1)

    # Skip if authored by current user (exact email match)
    if [ "$AUTHOR" = "$CURRENT_USER" ]; then
        continue
    fi

    # Skip if not modified after last import
    # Get file mtime in ISO format for comparison
    FILE_MTIME=$(git log -1 --format='%aI' -- "$file")
    if [[ "$FILE_MTIME" < "$LAST_IMPORT" ]]; then
        continue
    fi

    # File passes both filters - add to import list
    IMPORT_LIST+=("$file")
done
```

**Filter Logic Summary:**
- Uses git file tracking (not filesystem mtime) for timestamp comparison
- Exact email match for author filtering (no partial matches)
- Untracked files are skipped (they have no author to check)

### Prompt User Before Import

If filtered list is empty:
- Report "No new team learnings to import."
- Skip to Step 8

If files to import exist, use AskUserQuestion:

**Question:** "Found {N} team learning(s) to import. Import to Hindsight memory?"

Show list of files to import.

**Options:**
- **Yes, import all** - Import all filtered learnings
- **No, skip** - Skip import this time

### Execute Import

If user confirms:

```bash
# Create temp directory with filtered files
TEMP_DIR=$(mktemp -d)
# Copy filtered .md files to temp directory
# (preserving directory structure is optional)

# Import using retain-files
BANK=$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")

hindsight memory retain-files "$BANK" "$TEMP_DIR" \
  --recursive \
  --context "unitwork team learnings" \
  --async

# Cleanup temp directory
rm -rf "$TEMP_DIR"
```

### Update Import Timestamp

After successful import (or if no new learnings to import), update `.unitwork/.bootstrap.json`:
```bash
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create .unitwork if needed
mkdir -p .unitwork

# Create or update .bootstrap.json
if [ -f ".unitwork/.bootstrap.json" ]; then
    # Update existing file preserving other fields
    jq --arg ts "$TIMESTAMP" '.lastLearningsImport = $ts' .unitwork/.bootstrap.json > .unitwork/.bootstrap.json.tmp && \
    mv .unitwork/.bootstrap.json.tmp .unitwork/.bootstrap.json
else
    # Create new file
    echo "{\"lastLearningsImport\": \"$TIMESTAMP\"}" > .unitwork/.bootstrap.json
fi
```

### Report Import Result

```
**Team Learnings:**
- Imported {N} learning(s) to Hindsight memory
- Last import: {timestamp}
```

After bootstrap, suggest:

"Would you like to start planning a feature now? Run `/uw:plan` with a description of what you want to build."
