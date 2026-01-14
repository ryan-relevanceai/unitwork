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

## Phase 1: Context Gathering

### Memory Recall

First, recall relevant memories from Hindsight:

```bash
# Recall relevant context (handles worktrees - all worktrees share same bank)
hindsight memory recall "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "location of code related to: <feature_description>" --budget mid --include-chunks
```

### Codebase Exploration

Based on memory results, use **Explore subagents** to preserve main thread context.

Spawn 3 Explore agents **in parallel** (single message, multiple Task tool calls) with specific focuses:

**Agent 1 - Feature-Related Code:**
```
Task tool with subagent_type="Explore"
prompt: "Explore this codebase to find code related to: <feature_description>
1. Find files that implement similar or related functionality
2. Identify the modules/directories where this feature should live
3. Document existing patterns for this type of feature
4. Note any integration points (APIs, services, models)

Report: relevant files, existing patterns, and integration points."
```

**Agent 2 - Test Patterns:**
```
Task tool with subagent_type="Explore"
prompt: "Explore this codebase to understand testing patterns for: <feature_description>
1. Find existing tests for similar functionality
2. Document test patterns and conventions used
3. Note edge case handling patterns in related code
4. Identify test fixtures and factories that could be reused

Report: test patterns, conventions, and edge case handling."
```

**Agent 3 - Existing Utilities:**
```
Task tool with subagent_type="Explore"
prompt: "Find existing utilities in this codebase that could help implement: <feature_description>
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

## Phase 2: Interview

**Rules for interviewing:**

1. **Research before asking** - Check Hindsight, codebase, and web docs before asking user to explain
2. **Group related questions** - Batch related questions together using AskUserQuestion
3. **Push back on scope** - If something sounds like a separate feature, say: "That sounds like a separate feature - should we defer it?"
4. **Advocate once** - State recommendation with reasoning, then accept user decision
5. **No premature solutions** - Don't propose implementation during requirements gathering
6. **Confirm understanding** - Summarize requirements back before writing spec

### Interview Questions

The interview should be **extensive**, covering non-obvious implementation details that cannot be discovered through codebase exploration. Continue until you have **high confidence** in all implementation details - there is no arbitrary minimum number of rounds.

Use AskUserQuestion to clarify across these categories:

#### 1. Implementation Details
Questions that affect how code will be written:
- "How should errors be surfaced to the user?"
- "What data format should X use?"
- "Should this operation be sync or async?"
- "What's the expected latency/performance requirement?"
- "How should this integrate with existing X?"

#### 2. Edge Cases
Questions about boundary conditions and error states:
- "What happens when X is empty or null?"
- "How should we handle partial failures?"
- "What's the behavior at size/rate limits?"
- "What if the user cancels mid-operation?"
- "How should concurrent requests be handled?"

#### 3. Testing Strategy
Questions about verification approach:
- "What edge cases need explicit test coverage?"
- "Should we mock X or use real instances?"
- "Is integration testing needed for this?"
- "What's the acceptance criteria for 'done'?"
- "Are there existing test fixtures we should use?"

#### 4. Dependencies & Integration
Questions about external factors:
- "Are there external services involved?"
- "What happens if a dependency fails?"
- "Are there rate limits or quotas to consider?"
- "Does this need backwards compatibility?"

#### 5. UI/UX (only when feature involves UI)
Skip these for backend-only changes:
- "What should the loading state look like?"
- "How should validation errors be displayed?"
- "Is there existing UI we should match?"
- "What's the mobile/responsive behavior?"

### Confidence Gate

Continue interviewing until you have **high confidence** (>90%) that you understand:
- All functional requirements
- Key edge cases and how to handle them
- Testing approach
- Integration points

Do not proceed to spec writing with unresolved ambiguities about implementation details.

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

### Spawn Plan Review Agents (Parallel)

Launch 3 plan-review agents in parallel with the draft plan:

**Agent 1 - Gap Detector:**
```
Task tool with subagent_type="general-purpose"
prompt: "You are acting as a gap-detector plan-review agent.

Read the draft plan at: <plan-content>

Analyze each unit for information gaps that would require investigation during implementation:
- Investigation language ('investigate', 'explore', 'determine', 'research')
- Unclear API contracts (integration without specified contract)
- Ambiguous requirements (multiple interpretations possible)
- Edge cases mentioned but handling not specified
- Missing error handling strategy
- Unclear data formats

For each gap found, report:
### GAP: {description} - Severity: P1/P2/P3
**Location:** Unit N: {unit name}
**Gap Type:** [INVESTIGATION_LANGUAGE|API_CONTRACT|REQUIREMENT_AMBIGUITY|EDGE_CASE|ERROR_HANDLING|DATA_FORMAT]
**Quote:** '{exact text}'
**Why it matters:** {impact}
**Suggested resolution:** {ask user / explore codebase / clarify in spec}"
```

**Agent 2 - Utility Pattern Auditor:**
```
Task tool with subagent_type="general-purpose"
prompt: "You are acting as a utility-pattern-auditor plan-review agent.

Read the draft plan at: <plan-content>

For each unit that proposes implementing something, search the codebase for:
- Existing utilities that do the same thing
- Established patterns that should be followed
- Infrastructure the framework already provides

For each finding, report:
### UTILITY: {existing solution} - Severity: P1/P2/P3
**Location:** Unit N: {unit name}
**Finding Type:** [EXISTING_UTILITY|PATTERN_VIOLATION|MISSED_SEARCH|REINVENTING_INFRASTRUCTURE]
**Plan proposes:** '{what the plan says}'
**Existing solution:** {file path, function/class, usage}
**Suggested plan revision:** {use existing utility / follow pattern}"
```

**Agent 3 - Feasibility Validator:**
```
Task tool with subagent_type="general-purpose"
prompt: "You are acting as a feasibility-validator plan-review agent.

Read the draft plan at: <plan-content>

Assess each unit for:
- Technical impossibilities or blockers
- Unclear verification strategy
- Hidden dependencies (external services, permissions, data)
- Unrealistic confidence estimates
- Units too large for one session

For each concern, report:
### FEASIBILITY: {concern} - Severity: P1/P2/P3
**Location:** Unit N: {unit name}
**Concern Type:** [IMPOSSIBILITY|UNCLEAR_VERIFICATION|HIDDEN_DEPENDENCY|UNREALISTIC_CONFIDENCE|UNIT_TOO_LARGE|SCOPE_CREEP]
**Quote:** '{relevant text}'
**Why this is a concern:** {explanation}
**Suggested resolution:** {investigate / split unit / add dependency / adjust confidence}"
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
hindsight memory retain "$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")" "Planning <feature>: Discovered <files/patterns/decisions>. Key integration points: <details>." \
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
