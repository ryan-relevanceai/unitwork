---
name: uw:compound
description: Extract and store learnings to Hindsight memory and local documentation
argument-hint: "[feature name or empty to auto-detect from recent spec]"
---

# Compound learnings from completed feature

## Introduction

**Note: The current year is 2026.**

The compound phase runs automatically after every feature to capture learnings while context is fresh. Learnings are stored in both local documentation and Hindsight memory for future sessions.

## Feature Detection

<feature_name> #$ARGUMENTS </feature_name>

**If empty:** Detect from most recent spec in `.unitwork/specs/` or from recent checkpoint commits.

## Gather Context

Collect all artifacts from this feature:

1. **Spec file**: `.unitwork/specs/{date}-{feature}.md`
2. **Verification docs**: `.unitwork/verify/{date}-*-*.md`
3. **Review doc**: `.unitwork/review/{date}-{feature}.md`
4. **Git log**: Recent checkpoint commits

## Extract Learnings

### 1. Feature Paths Discovered

Document file locations and their purposes:
- Where does this feature live?
- What are the key entry points?
- How do files connect?

### 2. Architectural Decisions

Capture decisions made during implementation:
- What patterns were used?
- Why were certain approaches chosen?
- What was considered but rejected?

### 3. Gotchas & Quirks

Note anything that caused friction or surprise:
- Unexpected behaviors
- Non-obvious requirements
- Things that needed rework

### 4. Verification Insights

What worked and didn't work in verification:
- What was verified automatically?
- What needed human review and why?
- Verification blind spots discovered

### 5. For Next Time

Advice for similar future features:
- What should be done differently?
- What patterns should be reused?
- What questions should be asked earlier?

## Create Local Documentation

Write `.unitwork/learnings/{DD-MM-YYYY}-{feature-name}.md`:

```markdown
# Learnings: {Feature Name}
Date: {DD-MM-YYYY}
Spec: .unitwork/specs/{date}-{feature}.md

## Feature Paths Discovered
- {path}: {what it does}

## Architectural Decisions
- {decision}: {rationale}

## Gotchas & Quirks
- {gotcha}: {why it matters}

## Verification Insights
- {what was verified automatically}
- {what needed human review and why}

## For Next Time
- {advice for similar features}
```

## Retain to Hindsight

Store learnings in Hindsight memory for future sessions:

```bash
BANK_NAME=$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))

# Retain feature paths
hindsight memory retain "$BANK_NAME" "In repo $BANK_NAME, <feature> lives in <paths>. Key files: <file1> does <purpose1>, <file2> does <purpose2>." \
  --context "$BANK_NAME: feature paths for <feature>" \
  --doc-id "learnings-<feature-name>" \
  --async

# Retain architectural decisions
hindsight memory retain "$BANK_NAME" "In repo $BANK_NAME, for <feature> we used <pattern> because <rationale>. This connects to <other-parts>." \
  --context "$BANK_NAME: architecture decisions for <feature>" \
  --doc-id "learnings-<feature-name>" \
  --async

# Retain gotchas (high priority)
hindsight memory retain "$BANK_NAME" "In repo $BANK_NAME, GOTCHA for <feature>: <description>. This matters because <impact>. Similar situations should <advice>." \
  --context "$BANK_NAME: gotcha for <feature>" \
  --doc-id "learnings-<feature-name>" \
  --async

# Retain verification blind spots (critical)
hindsight memory retain "$BANK_NAME" "In repo $BANK_NAME, verification blind spot: <what was missed>. Human found <issue>. Future similar code needs <specific check>." \
  --context "$BANK_NAME: verification learning" \
  --doc-id "learnings-<feature-name>" \
  --async
```

## Memory Format Guidelines

**Always include:**
- Repo name at start: "In repo myapp, ..."
- Specific file paths (repo-qualified)
- User intent / why changes were made
- Connections to other parts of codebase

**Use narrative format:**
- Write as natural language, not structured data
- Focus on "how to find feature sets and important files easier"
- Include gotchas prominently

## Output

```
Learnings captured for: {Feature Name}

**Local:**
- .unitwork/learnings/{date}-{feature}.md

**Hindsight Memories:**
- Feature paths
- Architectural decisions
- Gotchas & quirks
- Verification insights

These learnings will help with similar features in future sessions.
```
