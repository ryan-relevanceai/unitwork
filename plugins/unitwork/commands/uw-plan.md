---
name: uw:plan
description: Interview user, explore codebase via Hindsight, and create spec with implementation units
argument-hint: "[feature description or empty to interview]"
---

# Plan a new feature with Unit Work

## CRITICAL: Read-Only Mode

**NEVER EDIT ANY FILES during planning.** This command is strictly read-only except for writing the spec file to `.unitwork/specs/`.

Allowed operations:
- Reading files (Read, Glob, Grep)
- Running read-only bash commands (git log, gh commands, ls, cat)
- Spawning Explore subagents
- Writing ONLY to `.unitwork/specs/{date}-{feature}.md`

Forbidden operations:
- Editing any existing files
- Writing new files outside `.unitwork/specs/`
- Running code/tests
- Making any changes to the codebase

If the user asks to make changes during planning, remind them: "Planning is read-only. Once the spec is approved, use `/uw:work` to implement."

## Introduction

**Note: The current year is 2026.**

Unit Work planning combines interview and planning into a single phase. The goal is to co-write requirements with the user and break them into smallest verifiable units.

## Feature Description

<feature_description> #$ARGUMENTS </feature_description>

**If empty:** Ask the user: "What would you like to build? Describe the feature, bug fix, or improvement."

Do not proceed until you have a clear feature description.

---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before exploration. Before interviewing. Before anything else.**

Memory recall is the foundation of compounding. Without it, you lose all accumulated learnings from past planning sessions and may plan approaches that have already been tried.

> **If you skip this:** You may plan an approach that was already tried and failed, miss architectural decisions that constrain the solution, or duplicate work that already exists.

### Execute Memory Recall NOW

```bash
# MANDATORY: Recall relevant context BEFORE exploration (config override → git remote → worktree → pwd)
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory recall "$BANK" "location of code related to: <feature_description>" --budget mid --include-chunks
```

### Display Learnings

After recall, display relevant learnings:

```
**Relevant Learnings from Memory:**
- {past planning decision or constraint}
- {existing code location or pattern}
```

If no relevant learnings found: "Memory recall complete - no relevant learnings found for this feature type."

**DO NOT PROCEED to codebase exploration until memory recall is complete.**

---

## Phase 0.5: Linear Ticket Context (If Available)

Before interviewing the user, check for existing context from Linear tickets:

### 1. Get Current Branch Name

```bash
git branch --show-current
```

### 2. Check for Associated Linear Ticket

Parse the branch name for a ticket ID pattern and fetch ticket details:

1. Look for ticket ID in branch name (e.g., `myz96/PROJ-123-feature-name` → `PROJ-123`)
2. If ticket ID found, fetch ticket details:
   ```
   mcp__linear-server__get_issue(id: "PROJ-123", includeRelations: true)
   ```
3. Extract from ticket:
   - Title
   - Description
   - Comments (for additional context)
   - Labels
   - Related issues

### 3. Use Ticket Context

If a Linear ticket exists with a description:
- Use the ticket description as **initial context** for planning
- Skip or minimize interview questions that are already answered in the ticket
- Reference the ticket in the spec file

Example context extraction:
> "I found Linear ticket PROJ-123 associated with this branch. The ticket describes: [ticket description]. I'll use this as the starting point for planning. Let me know if anything has changed or if you'd like to add more details."

### 4. No Ticket Found

If no Linear ticket is associated:
- Proceed with normal interview workflow
- Optionally offer to create a Linear ticket after planning is complete

---

## Phase 1: Context Gathering

### Codebase Exploration

Based on memory results, use **memory-aware exploration agents** to preserve main thread context and compound exploration findings across sessions.

Spawn 3 exploration agents **in parallel** (single message, multiple Task tool calls) with specific focuses:

**Agent 1 - Feature-Related Code:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Feature context: <feature_description>

Explore this codebase to find code related to: <feature_description>
1. Find files that implement similar or related functionality
2. Identify the modules/directories where this feature should live
3. Document existing patterns for this type of feature
4. Note any integration points (APIs, services, models)

Report: relevant files, existing patterns, and integration points."
```

**Agent 2 - Test Patterns:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Feature context: <feature_description>

Explore this codebase to understand testing patterns for: <feature_description>
1. Find existing tests for similar functionality
2. Document test patterns and conventions used
3. Note edge case handling patterns in related code
4. Identify test fixtures and factories that could be reused

Report: test patterns, conventions, and edge case handling."
```

**Agent 3 - Existing Utilities:**
```
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Feature context: <feature_description>

Find existing utilities in this codebase that could help implement: <feature_description>
1. Search for helper functions, service objects, and shared modules
2. Find validation utilities, formatters, and data transformers
3. Locate any abstraction layers (API clients, database helpers, etc.)
4. Note which utilities have good test coverage (prefer tested utilities)
5. Document the import paths and usage patterns

Report: List of reusable utilities with their locations, what they do, and how to use them.
IMPORTANT: Only include utilities that are already tested and production-ready."
```

After agents complete, synthesize their findings before interviewing the user. The utilities discovered by Agent 3 should inform the implementation approach.

### Framework Documentation (Context7)

For any framework/library patterns needed for this feature, query Context7:

```
Step 1: Resolve library ID
mcp__unitwork_context7__resolve-library-id
  query: "<what you need to implement>"
  libraryName: "<framework name>"

Step 2: Query documentation
mcp__unitwork_context7__query-docs
  libraryId: "<id from step 1>"
  query: "<specific pattern or API>"
```

**Use Context7 when:**
- Feature involves unfamiliar framework APIs
- Need to verify best practices for implementation approach
- Want official documentation examples before planning

**Don't use for:**
- Project-specific patterns (Hindsight has those)
- Simple/well-known APIs you're confident about

### Hypothesis Formation (If Investigation Needed)

After synthesizing exploration findings, assess whether hypotheses should be formed about existing system behavior.

**Form hypotheses when ANY of these signals detected:**
- Exploration agents returned conflicting approaches for the same functionality
- Multiple valid implementation paths identified with no clear winner
- Feature modifies existing logic with unclear behavior (not purely additive)
- Exploration found code but couldn't determine why it works that way

**Skip hypothesis formation when ALL true:**
- Single clear pattern found to follow
- Feature is purely additive (new files, no modifications to existing logic)
- Exploration agents aligned on approach

#### Hypothesis Format

If investigation is needed, form 1-3 hypotheses:

```
**Pre-Planning Hypotheses:**

1. **{Hypothesis about how existing system works}**
   - Evidence: {what exploration found that supports this}
   - To verify during /uw:work: {which tests to run, what behavior to check}

2. **{Alternative hypothesis if first might be wrong}**
   - Evidence: {supporting evidence}
   - To verify during /uw:work: {verification approach}
```

#### Read-Only Verification

Verify hypotheses through analysis, not execution:
- Trace code paths by reading files
- Analyze test files to understand expected behavior (without running)
- Check git history for context on why code works this way
- Spawn additional exploration agents for deeper analysis if needed

#### Interview Integration

Before standard interview questions, confirm hypotheses with user:

```
"Before we discuss requirements, I'd like to confirm my understanding of how the existing system works:

**Hypotheses:**
1. {hypothesis}
2. {hypothesis}

Are these correct, or should I adjust my understanding?"
```

- **If user confirms:** Proceed to standard interview
- **If user rejects:** Ask clarifying questions, reform hypothesis, re-confirm

#### Spec Integration

Unverified hypotheses become assumptions in the spec. Add after "### Out of Scope":

```markdown
### Assumptions (To Verify During Implementation)
- **{Assumption}**: Verify by {approach during /uw:work}
- **{Assumption}**: Verify by {approach during /uw:work}

*These assumptions were formed during planning. /uw:work should validate before proceeding with dependent work.*
```

## Phase 2: Interview

See [interview-workflow.md](../skills/unitwork/references/interview-workflow.md) for the complete interview protocol including confidence-based depth assessment, question categories, and stop conditions.

**Rules for interviewing (kept inline for compliance):**

1. **Research before asking** - Check Hindsight, codebase, and web docs before asking user to explain
2. **Group related questions** - Batch related questions together using AskUserQuestion
3. **Push back on scope** - If something sounds like a separate feature, say: "That sounds like a separate feature - should we defer it?"
4. **Advocate once** - State recommendation with reasoning, then accept user decision
5. **No premature solutions** - Don't propose implementation during requirements gathering
6. **Confirm understanding** - Summarize requirements back before writing spec

### Confidence-Based Depth

Before starting interview, assess confidence to determine depth:

| Confidence | Depth | Rounds |
|------------|-------|--------|
| >80% (high) | Minimal | 1-2 targeted questions |
| 50-80% (medium) | Standard | 3-5 rounds |
| <50% (low) | Comprehensive | Up to 10 rounds |

### Interview Stop Condition

Continue interviewing until **no P1/P2 gaps remain**. To validate:

```
Task tool with subagent_type="unitwork:plan-review:gap-detector"
prompt: "Review current understanding of {feature} for information gaps..."
```

If gap-detector returns no P1/P2 findings, proceed to spec writing.

## Phase 3: Breakdown into Units

Break requirements into smallest verifiable units. Each unit should be:

- Independently testable
- Completable in one focused session
- Have clear verification criteria

For each unit, determine:
- What code changes are needed
- How the agent will self-verify (tests, API probing, browser automation)
- What the human QA checklist will be

### Confidence Assessment

For each unit, estimate confidence ceiling:
- **Backend/API only** - High confidence possible (95%+)
- **UI involved** - Lower confidence ceiling (70-80%)
- **Data migration** - Requires extra scrutiny (flag for human review)

## Phase 3.5: Plan Review

**Before presenting the plan to the user, validate it with specialized review agents.**

The goal is to catch gaps, missing utilities, and feasibility issues BEFORE the user sees the plan. All investigation should happen during planning, not during implementation.

### Conditional Plan Review

Before spawning review agents, count the implementation units in your draft plan.

**Threshold rationale:** Small plans (1-3 units) don't benefit from full review overhead, but gap detection remains valuable for catching missing information that would block implementation.

#### If >3 units: Full Review (3 agents in parallel)

Launch all 3 plan-review agents in parallel:

```
Task tool with subagent_type="unitwork:plan-review:gap-detector"
prompt: "Review this draft plan for information gaps:

<plan-content>

Analyze each unit for missing information that would require investigation during implementation."
```

```
Task tool with subagent_type="unitwork:plan-review:utility-pattern-auditor"
prompt: "Review this draft plan for reinvented wheels:

<plan-content>

Search the codebase for existing utilities that could be reused instead of building new ones."
```

```
Task tool with subagent_type="unitwork:plan-review:feasibility-validator"
prompt: "Review this draft plan for feasibility issues:

<plan-content>

Assess each unit for technical blockers, unclear verification, and hidden dependencies."
```

#### If <=3 units: Light Review (gap-detector only)

Launch only the gap-detector agent:

```
Task tool with subagent_type="unitwork:plan-review:gap-detector"
prompt: "Review this draft plan for information gaps:

<plan-content>

Analyze each unit for missing information that would require investigation during implementation."
```

### Finding Verification (Critical)

**Agents are not oracles.** Their findings are hypotheses that must be verified before acting.

For each finding from the agents:

1. **Check factual accuracy**: Does the claim hold up?
   - "Utility exists at X" → Actually read the file, confirm it exists and does what's claimed
   - "Pattern violation" → Verify the pattern actually applies to this context
   - "Gap in requirements" → Check if it was actually addressed elsewhere in the plan

2. **Check scope relevance**: Is this finding in-scope for the current work?
   - A real issue but unrelated to this feature → Dismiss (note for future)
   - A stylistic preference vs actual problem → Dismiss
   - Pre-existing issue not introduced by this plan → Dismiss (or note as tech debt)

3. **Classify the finding**:
   - **VERIFIED**: Factually correct and in-scope → Act on it
   - **DISMISSED**: False positive or out of scope → Document rationale, don't act

**Only VERIFIED findings count toward convergence.**

Document each finding's verification:
```markdown
### Finding: {original finding summary}
**Agent:** {gap-detector|utility-pattern-auditor|feasibility-validator}
**Original Severity:** P1/P2/P3
**Verification Status:** VERIFIED | DISMISSED
**Rationale:** {why this was verified or dismissed}
**Action:** {what will be done, or "none - dismissed"}
```

### Convergence Criteria

The plan is ready to present when:
1. <3 total verified findings combined
2. No verified P1 (BLOCKING) findings
3. No verified P2 (IMPORTANT) findings

### Loop Behavior

If convergence criteria NOT met:
1. For verified gaps requiring codebase search → Spawn Explore agents
2. For verified ambiguities → Ask user questions via AskUserQuestion
3. Revise the draft plan based on findings
4. Re-run plan-review agents on revised plan
5. Repeat until convergence

**Soft iteration limit:** After 5 rounds without convergence, escalate to user with remaining verified findings and ask whether to proceed or continue iterating.

**Dismissed findings are documented but don't block convergence.**

## Phase 4: Write Spec

Create the spec file:

```
.unitwork/specs/{DD-MM-YYYY}-{feature-name}.md
```

**Spec Template:**

```markdown
# {Feature Name}

## Linear Ticket
- **Ticket ID:** {PROJ-123 or "None"}
- **URL:** {linear_url or "N/A"}

## Purpose & Impact
- Why this feature exists
- Who it helps
- What success looks like

## Requirements

### Functional Requirements
- [ ] FR1: ...
- [ ] FR2: ...

### Non-Functional Requirements
- [ ] NFR1: ...

### Out of Scope
- Explicitly excluded items
- Noted refactors (tech debt for future)

### Assumptions (To Verify During Implementation)
- **{Assumption}**: Verify by {approach during /uw:work}

*These assumptions were formed during planning. /uw:work should validate before proceeding with dependent work.*

## Technical Approach
- Architectural decisions
- Key files/modules affected
- Integration points

## Implementation Units

### Unit 1: {name}
- **Changes:** Files to modify
- **Self-Verification:** How agent verifies
- **Human QA:** Checklist for human review
- **Confidence Ceiling:** X%

### Unit 2: {name}
...

## Verification Plan

### Agent Self-Verification
- What the agent will verify automatically
- Test strategy (thoughtful tests, not coverage fluff)

### Human QA Checklist
- [ ] Step-by-step verification steps
- [ ] Precursor state setup instructions
- [ ] Expected outcomes

## Spec Changelog
- {date}: Initial spec from interview
```

## Phase 5: Retain Learnings

Retain discoveries to Hindsight:

```bash
BANK=$(jq -re '.bankName // empty' .unitwork/.bootstrap.json 2>/dev/null || git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
hindsight memory retain "$BANK" "Planning <feature>: Discovered <files/patterns/decisions>. Key integration points: <details>." \
  --context "planning <feature>" \
  --doc-id "plan-<feature-name>" \
  --async
```

## Output

After writing the spec, present to user:

```
Spec written to: .unitwork/specs/{date}-{feature}.md

**Implementation Units:**
1. {Unit 1} - {verification approach} - {confidence}%
2. {Unit 2} - {verification approach} - {confidence}%
...

**Out of Scope (deferred):**
- {Item 1}
- {Item 2}

Ready to start implementation with /uw:work?
```

Use AskUserQuestion to confirm:
- **Start /uw:work** - Begin implementation
- **Revise plan** - Modify the spec
- **Defer** - Save for later
