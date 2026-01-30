# Agentic Efficiency Improvements (Priority 2+3)

## Purpose & Impact
- **Why:** Investigation report identified sequential bottlenecks in verification workflows where parallelization patterns exist elsewhere in Unit Work
- **Who:** Unit Work users who run `/uw:work` and `/uw:review` commands
- **Success:** Verification subagents launch in parallel when changes span multiple types; finding verification reads happen in parallel for independent files

## Requirements

### Functional Requirements
- [ ] FR1: Verification subagents (test-runner, api-prober, agent-browser) launch in parallel when changes span multiple categories
- [ ] FR2: Safety flags (e.g., "NEVER run migrations", "flag for human") remain enforced within each verification type
- [ ] FR3: Finding verification in uw-review reads files in parallel when findings target different files

### Non-Functional Requirements
- [ ] NFR1: No change to confidence calculation logic (additive penalties work for parallel)
- [ ] NFR2: Existing IF-THEN structure in uw-work.md preserved (just add parallel dispatch instruction)

### Out of Scope
- Instrumentation/metrics (deferred by user)
- Prompt caching investigation (deferred)
- PR comment processing parallelization (kept sequential for checkpoint integrity)

## Technical Approach

### Files to Modify
1. `plugins/unitwork/skills/unitwork/references/verification-flow.md` - lines 7-44
2. `plugins/unitwork/commands/uw-work.md` - lines 172-191
3. `plugins/unitwork/commands/uw-review.md` - after line 235

### Pattern Reference
Existing parallel spawning pattern from `uw-review.md:158`:
```markdown
Launch all 7 review agents in parallel with the diff context.
```

This explicit "in parallel" instruction is the established pattern to follow.

## Implementation Units

### Unit 1: Parallel Verification Dispatch in verification-flow.md
- **Changes:** Replace sequential ASCII decision tree (lines 7-44) with parallel dispatch table
- **Details:**
  - Convert flowchart to table format: `| Change Type | Subagents | Safety Flags |`
  - Add explicit instruction: "When changes span multiple categories, launch ALL applicable subagents in parallel using multiple Task tool calls in the same response"
  - Preserve all safety caveats within each row (api-prober permissions, migration warnings, human flags)
- **Self-Verification:** Read the modified file, confirm table structure and parallel instruction present
- **Human QA:** Review table readability and safety flag preservation
- **Confidence Ceiling:** 95%

### Unit 2: Parallel Verification Instruction in uw-work.md
- **Changes:** Add parallel dispatch instruction at Step 2 (lines 172-191)
- **Details:**
  - Add instruction after line 174 ("Launch appropriate verification subagents based on what changed"):
    > "When changes span multiple categories below, launch all applicable agents in parallel using multiple Task tool calls in the same response."
  - Keep existing IF-THEN structure for each category unchanged
- **Self-Verification:** Read the modified file, confirm instruction added without disrupting existing structure
- **Human QA:** None needed - pure documentation change
- **Confidence Ceiling:** 100%

### Unit 3: Batch Finding Verification Guidance in uw-review.md
- **Changes:** Add guidance to Finding Verification section (after line 235)
- **Details:**
  - Insert new paragraph after "This verification step prevents wasting user time on false positives and ensures all presented findings are actionable."
  - Content: "Findings targeting different files can be verified in parallel. When multiple findings exist, read files for independent findings simultaneously using parallel tool calls before classifying."
- **Self-Verification:** Read the modified file, confirm paragraph added in correct location
- **Human QA:** None needed - pure documentation change
- **Confidence Ceiling:** 100%

## Verification Plan

### Agent Self-Verification
- Read each modified file after changes
- Confirm no unintended deletions or structural breaks
- Verify parallel instruction language matches established patterns

### Human QA Checklist
- [ ] Review verification-flow.md table format for clarity
- [ ] Confirm safety flags are still prominent and clear in new table format

## Spec Changelog
- 30-01-2026: Initial spec from interview. Scope: Priority 2+3 only (no instrumentation). User chose implicit guidance for batch finding verification. All verification types can parallelize with safety flags preserved.
