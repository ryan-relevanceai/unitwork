---
name: uw:compound
description: Extract and store learnings to Hindsight memory and local documentation
argument-hint: "[feature name or empty to auto-detect from recent spec]"
---

# Compound learnings from completed feature

## Introduction

**Note: The current year is 2026.**

The compound phase captures **the journey**, not the destination. Learnings document what deviated from the spec, what surprised you, and what patterns transfer to future work.

**Key principle:** Learnings should help a future /plan or /work session that's working on a *different but related* task. They should NOT duplicate spec content.

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

Focus on the **delta** between plan and reality. Include only sections that have meaningful content - skip sections where nothing noteworthy occurred.

### Summary (required)

Write 1-2 sentences: what was built and why. This provides context without duplicating the spec.

### What Deviated from Spec (if any)

Compare implementation to the original plan. What changed and why? What does this teach us about planning similar features?

### Gotchas & Surprises (if any)

Document friction and non-obvious discoveries. Frame for transferability: "When working on X type of task, watch out for Y"

### Generalizable Patterns (if any)

Extract insights that apply beyond this specific feature. Format: "{Pattern name}: {when to apply it}"

### Verification Blind Spots (if any)

What did human QA find that automated checks missed? How should similar features be verified next time?

## Create Local Documentation

Write `.unitwork/learnings/{DD-MM-YYYY}-{feature-name}.md` with only the sections that have content:

```markdown
# Learnings: {Feature Name}
Date: {DD-MM-YYYY}
Spec: .unitwork/specs/{date}-{feature}.md

## Summary
{1-2 sentences}

## Gotchas & Surprises
- {gotcha}: {why it matters for future similar work}

## Generalizable Patterns
- {pattern}: {when to apply it}
```

*(Include only sections with meaningful content - omit empty sections)*

## Retain to Hindsight

Store learnings for future recall. Use feature *type* (e.g., "OAuth integration", "database migration") not just feature name, so insights transfer to related work.

```bash
# Example: Retain a gotcha discovered during OAuth implementation (handles worktrees)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory retain "$BANK" "GOTCHA when working on OAuth integrations: token refresh must happen before expiry, not after. This matters because expired tokens cause silent auth failures. Similar auth flows should add 60-second buffer to token lifetime checks." \
  --context "gotcha from oauth-feature" \
  --doc-id "learnings-oauth-feature" \
  --async
```

Retain each meaningful learning (deviations, gotchas, patterns, blind spots) as a separate memory with:
- Feature *type* for transferability (not just feature name)
- The "why" and actionable advice
- `--async` to avoid blocking

## Output

```
Learnings captured for: {Feature Name}

**Local:**
- .unitwork/learnings/{date}-{feature}.md

**Hindsight Memories:**
- {count} insights retained

These learnings will help with similar features in future sessions.
```
