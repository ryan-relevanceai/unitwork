# Plan Review Agents: Eliminating Investigation Units

## Purpose & Impact
- **Why:** "Investigation" units in specs indicate incomplete planning. All investigation should happen during the plan phase, not during implementation.
- **Who:** Users of the Unit Work plugin who want higher-quality specs with fewer surprises during implementation
- **Success:** Plans presented to users have been validated by specialized agents; no "investigation" units exist; gaps are filled before spec approval

## Requirements

### Functional Requirements
- [ ] FR1: Create 3 specialized plan-review agents that run in parallel after draft plan creation
- [ ] FR2: Gap Detector agent identifies missing information requiring investigation
- [ ] FR3: Utility & Pattern Auditor agent identifies reinvented wheels and missed utilities
- [ ] FR4: Feasibility Validator agent assesses technical feasibility and verification clarity
- [ ] FR5: Main planner spawns Explore subagents to fill gaps (not agents themselves)
- [ ] FR6: Consensus threshold: No verified P1 or P2 findings before presenting to user
- [ ] FR7: Loop until all agents report <3 verified findings (confidence-based convergence)
- [ ] FR8: Update uw-plan.md to include plan-review phase between draft and user presentation
- [ ] FR9: **Main planner must independently verify each finding before acting on it**
- [ ] FR10: Update uw:review to also verify findings before presenting to user

### Non-Functional Requirements
- [ ] NFR1: Agents follow existing agent pattern (YAML frontmatter, model: inherit)
- [ ] NFR2: Findings use standardized format (severity, description, suggested action)
- [ ] NFR3: Plan-review phase should add minimal latency (parallel execution)

### Out of Scope
- User-configurable thresholds per project (can add later)
- Automatic plan revision (agents report, main planner revises)
- Integration with external validation services

## Technical Approach

### New Workflow

**Current workflow:**
```
Context Gathering → Interview → Draft Plan → Present to User → Approval
```

**New workflow:**
```
Context Gathering → Interview → Draft Plan → Plan Review (parallel agents) →
  Verify Findings (main planner checks each claim) →
    If verified gaps: Additional exploration → Revise draft → Loop
    If consensus (<3 verified findings, no verified P1/P2): Present to User → Approval
```

### Finding Verification (Critical)

**Agents are not oracles.** Their findings are hypotheses that must be verified before acting.

For each finding, the main planner must:

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

**Only VERIFIED findings count toward convergence criteria.**

**Verification output format:**
```markdown
### Finding: {original finding summary}
**Agent:** {gap-detector|utility-pattern-auditor|feasibility-validator}
**Original Severity:** P1/P2/P3
**Verification Status:** VERIFIED | DISMISSED
**Rationale:** {why this was verified or dismissed}
**Action:** {what will be done, or "none - dismissed"}
```

### Agent Architecture

#### Agent 1: gap-detector
**Location:** `plugins/unitwork/agents/plan-review/gap-detector.md`

**What it detects:**
- Units that mention needing to "investigate" or "explore" something
- Unclear API contracts (mentions integration without specifying contract)
- Ambiguous requirements (multiple interpretations possible)
- Edge cases mentioned but handling not specified
- Missing error handling strategy
- Unclear data formats or schemas

**Severity levels:**
- **P1 BLOCKING:** Would halt implementation (unknown API, missing critical info)
- **P2 IMPORTANT:** Would require user clarification mid-implementation
- **P3 MINOR:** Could be decided by implementer autonomously

**Output format:**
```markdown
### GAP: {description} - Severity: P1/P2/P3

**Location:** Unit N: {unit name}

**Gap Type:** [API_CONTRACT|REQUIREMENT_AMBIGUITY|EDGE_CASE|ERROR_HANDLING|DATA_FORMAT]

**Why it matters:** {impact on implementation}

**Suggested resolution:**
- Ask user: "{specific question}"
- OR explore: "{what to search for in codebase}"
```

#### Agent 2: utility-pattern-auditor
**Location:** `plugins/unitwork/agents/plan-review/utility-pattern-auditor.md`

**What it detects:**
- Units describing functionality that likely exists in codebase
- Pattern violations (not following established conventions)
- Missing utility search (should have found X but didn't)
- Reinventing existing infrastructure

**Severity levels:**
- **P1 BLOCKING:** Major utility exists that makes unit unnecessary
- **P2 IMPORTANT:** Utility exists that simplifies unit significantly
- **P3 MINOR:** Minor pattern deviation, acceptable

**Output format:**
```markdown
### UTILITY: {existing solution} - Severity: P1/P2/P3

**Location:** Unit N: {unit name}

**Finding Type:** [EXISTING_UTILITY|PATTERN_VIOLATION|MISSED_SEARCH]

**Existing solution:**
- File: `{path}`
- Function/Class: `{name}`
- Usage: `{how to use}`

**Suggested plan revision:**
- Use existing utility instead of implementing
- OR follow pattern from `{example file}`
```

#### Agent 3: feasibility-validator
**Location:** `plugins/unitwork/agents/plan-review/feasibility-validator.md`

**What it detects:**
- Technical impossibilities or major blockers
- Units with unclear verification strategy
- Unidentified dependencies (external services, permissions, etc.)
- Confidence ceilings that seem unrealistic
- Units too large to be "one focused session"

**Severity levels:**
- **P1 BLOCKING:** Technical impossibility or major unidentified blocker
- **P2 IMPORTANT:** Unclear verification makes unit hard to complete
- **P3 MINOR:** Suggestion to split large unit

**Output format:**
```markdown
### FEASIBILITY: {concern} - Severity: P1/P2/P3

**Location:** Unit N: {unit name}

**Concern Type:** [IMPOSSIBILITY|UNCLEAR_VERIFICATION|HIDDEN_DEPENDENCY|SCOPE_CREEP|UNIT_TOO_LARGE]

**Why this is a concern:** {explanation}

**Suggested resolution:**
- Investigate: "{what to verify}"
- OR split unit: "{how to break down}"
- OR add dependency: "{what's missing}"
```

### Consensus Mechanism

**Convergence criteria (applied to VERIFIED findings only):**
1. <3 total verified findings combined
2. No verified P1 (BLOCKING) findings
3. No verified P2 (IMPORTANT) findings

**Loop behavior:**
- After each round, main planner:
  1. Collects findings from all agents
  2. **Verifies each finding** (factual accuracy + scope relevance)
  3. For verified gaps: Spawns Explore agents for codebase search
  4. For verified ambiguities: Asks user questions
  5. Revises draft plan based on verified findings
  6. Re-runs plan-review agents on revised plan
- Loop continues until convergence criteria met on verified findings

**Dismissed findings are documented but don't block convergence.**

**Soft iteration limit:** After 5 rounds without convergence, escalate to user with remaining verified findings and ask whether to proceed or continue iterating.

### Integration Points

**Modified files:**
- `plugins/unitwork/commands/uw-plan.md` - Add Phase 3.5: Plan Review
- `plugins/unitwork/agents/plan-review/` - New directory with 3 agents

**Interaction with existing phases:**
- Phase 1 (Context Gathering): Unchanged
- Phase 2 (Interview): Unchanged
- Phase 3 (Breakdown): Creates draft plan
- **Phase 3.5 (Plan Review): NEW - Validates draft plan**
- Phase 4 (Write Spec): Only runs after plan review passes
- Phase 5 (Retain Learnings): Unchanged

## Implementation Units

### Unit 1: Create plan-review agent directory structure
- **Changes:** Create `plugins/unitwork/agents/plan-review/` directory
- **Self-Verification:** `ls` to confirm directory exists
- **Human QA:** Verify directory in correct location
- **Confidence Ceiling:** 99%

### Unit 2: Create gap-detector agent
- **Changes:** Write `plugins/unitwork/agents/plan-review/gap-detector.md`
- **Self-Verification:** Read file, verify YAML frontmatter and all sections present
- **Human QA:** Review detection categories for completeness
- **Confidence Ceiling:** 85%

### Unit 3: Create utility-pattern-auditor agent
- **Changes:** Write `plugins/unitwork/agents/plan-review/utility-pattern-auditor.md`
- **Self-Verification:** Read file, verify YAML frontmatter and all sections present
- **Human QA:** Review utility detection patterns
- **Confidence Ceiling:** 85%

### Unit 4: Create feasibility-validator agent
- **Changes:** Write `plugins/unitwork/agents/plan-review/feasibility-validator.md`
- **Self-Verification:** Read file, verify YAML frontmatter and all sections present
- **Human QA:** Review feasibility concerns list
- **Confidence Ceiling:** 85%

### Unit 5: Update uw-plan.md with Plan Review phase
- **Changes:**
  - Add Phase 3.5: Plan Review between Breakdown and Write Spec
  - Document the 3 parallel agents and their prompts
  - Add Finding Verification step (factual accuracy + scope relevance)
  - Add convergence criteria and loop behavior
  - Add guidance on handling verified findings (Explore for gaps, user questions for ambiguities)
- **Self-Verification:** Read file, verify new phase documented including verification step
- **Human QA:** Run /uw:plan and verify plan-review loop activates with verification
- **Confidence Ceiling:** 80% (workflow changes need real-world testing)

### Unit 6: Update uw-review.md with Finding Verification
- **Changes:**
  - Add verification step after agents report findings
  - Main planner must verify each finding before presenting to user
  - Document VERIFIED vs DISMISSED classification
  - Only verified findings appear in final review output
- **Self-Verification:** Read file, verify verification step documented
- **Human QA:** Run /uw:review and verify findings are verified before presentation
- **Confidence Ceiling:** 85%

## Verification Plan

### Agent Self-Verification
- File existence checks for all new files
- Content verification for required sections (YAML frontmatter, detection patterns, output format)
- Grep for key phrases in uw-plan.md ("Phase 3.5", "Plan Review", "convergence")

### Human QA Checklist

#### Prerequisites
1. Have a feature idea ready to plan
2. Ensure Hindsight is available for memory operations

#### Verification Steps
- [ ] Run `/uw:plan` with a moderately complex feature
- [ ] Verify 3 plan-review agents spawn after draft plan creation
- [ ] Check that findings are categorized with severity levels
- [ ] **Verify main planner independently verifies each finding**
- [ ] **Confirm VERIFIED vs DISMISSED classification is documented**
- [ ] Verify Explore subagents spawn for verified gaps
- [ ] Test that loop continues until convergence (<3 verified findings, no verified P1/P2)
- [ ] Confirm final spec has no "investigation" units
- [ ] Verify user is not asked about issues agents could resolve
- [ ] Run `/uw:review` and verify findings are verified before presentation

#### Edge Cases to Test
- [ ] Simple feature (should converge in 1 round)
- [ ] Complex feature with multiple unknowns (should loop)
- [ ] Feature requiring external API (should surface as P1 gap)
- [ ] **Agent reports false positive (should be DISMISSED with rationale)**
- [ ] **Agent reports out-of-scope issue (should be DISMISSED, noted for future)**

### Notes
- The 3-agent architecture mirrors the 6-agent code review pattern but scoped to plan validation
- Agents are intentionally scoped narrowly - each has one job
- **Agents are not oracles** - their findings are hypotheses requiring verification
- Soft iteration limit (5 rounds) prevents infinite loops while maintaining quality focus

## Spec Changelog
- 14-01-2026: Initial spec from interview
- 14-01-2026: Added Finding Verification requirement (FR9, FR10) - agent findings must be independently verified before acting; applies to both plan-review and uw:review
