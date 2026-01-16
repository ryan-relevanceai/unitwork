# Interview Workflow Extraction & Memory Validation Agent

## Purpose & Impact
- **Why**: Interview logic is embedded in uw-plan.md and cannot be reused. Implementations forget to apply learnings from memory because no review agent validates against them.
- **Who it helps**: Agents executing uw-plan, uw-work, uw-review get consistent interview behavior. PR reviewers get validation against team learnings.
- **Success**: Interview workflow is reusable across commands. Memory-validation agent catches violations of documented learnings.

## Requirements

### Functional Requirements
- [ ] FR1: Create `interview-workflow.md` as single source of truth for interview protocols
- [ ] FR2: Interview workflow supports confidence-based depth (high/medium/low → minimal/standard/comprehensive)
- [ ] FR3: Interview stops when no P1/P2 gaps remain (validated by gap-detector)
- [ ] FR4: Interview is invocable from uw-plan (Phase 2), uw-work (Step 0.5), uw-review (fix loop)
- [ ] FR5: Memory-validation agent recalls all learnings and validates PR against them
- [ ] FR6: Memory-validation severity inherits from learning's original context
- [ ] FR7: Memory-validation skips silently if Hindsight unavailable

### Non-Functional Requirements
- [ ] NFR1: Follow verification-flow.md pattern for reference file structure
- [ ] NFR2: Follow existing review agent structure (type-safety.md as template)
- [ ] NFR3: Follow memory-aware-explore.md pattern for Hindsight integration

### Out of Scope
- New taxonomy patterns for memory-validation (reuse generic LEARNING_VIOLATION pattern)
- Changes to other review agents (they continue receiving filtered memories)
- Review-standards skill updates (memory-validation is additive)

## Technical Approach
- **interview-workflow.md**: New reference file at `plugins/unitwork/skills/unitwork/references/`
- **memory-validation.md**: New agent at `plugins/unitwork/agents/review/`
- **SKILL.md update**: Add link to new interview-workflow.md reference
- **Memory routing**: Memory-validation receives ALL memories, other agents continue receiving filtered subsets

## Implementation Units

### Unit 1: Create interview-workflow.md
- **Changes**:
  - New file: `plugins/unitwork/skills/unitwork/references/interview-workflow.md`
  - Content: Confidence-based depth assessment, question categories (5), stop conditions, AskUserQuestion patterns
  - Structure: ASCII decision trees like verification-flow.md
- **Self-Verification**: File exists with required sections
- **Human QA**: Review content completeness
- **Confidence Ceiling**: 95%

### Unit 2: Update uw-plan.md
- **Changes**:
  - Replace embedded Phase 2 Interview with reference to interview-workflow.md
  - Keep interview rules inline (6 rules) for compliance
  - Add cross-reference: `[interview-workflow.md](../skills/unitwork/references/interview-workflow.md)`
- **Self-Verification**: Grep for reference link, verify Phase 2 section updated
- **Human QA**: Verify interview flow still makes sense
- **Confidence Ceiling**: 90%

### Unit 3: Update uw-work.md Step 0.5
- **Changes**:
  - Add interview loop when gap-detector finds P1/P2 gaps
  - After interview, re-run gap-detector to validate gaps addressed
  - Stop when no P1/P2 gaps remain
  - Reference interview-workflow.md for depth assessment
- **Self-Verification**: Grep for interview reference, verify loop structure
- **Human QA**: Verify flow doesn't create infinite loops
- **Confidence Ceiling**: 90%

### Unit 4: Update uw-review.md fix loop
- **Changes**:
  - Add interview trigger: "When agent can't determine fix approach (before implementing)"
  - Reference interview-workflow.md for question patterns
  - Insert before Context7 research step in fix loop
- **Self-Verification**: Grep for interview reference in fix loop section
- **Human QA**: Verify integration with existing fix loop flow
- **Confidence Ceiling**: 85%

### Unit 5: Create memory-validation.md agent
- **Changes**:
  - New file: `plugins/unitwork/agents/review/memory-validation.md`
  - Follow type-safety.md structure (YAML frontmatter, output format)
  - Hindsight integration pattern from memory-aware-explore.md
  - Bank name derivation, recall pattern, graceful degradation
  - Output format: `### [LEARNING_VIOLATION] - Severity: P1/P2/P3 - Tier: 1`
  - Severity inherited from learning context (detect "critical", "security", "P1" keywords → P1)
- **Self-Verification**: File exists with required sections, YAML valid
- **Human QA**: Review Hindsight integration logic
- **Confidence Ceiling**: 90%

### Unit 6: Update uw-review.md agent spawning
- **Changes**:
  - Add memory-validation as 7th parallel agent
  - Update spawn section to include memory-validation
  - Update memory routing table: memory-validation receives ALL memories
  - Other agents continue receiving filtered memories (additive, not replacement)
- **Self-Verification**: Grep for memory-validation in spawn section and routing table
- **Human QA**: Verify 7 agents spawned correctly
- **Confidence Ceiling**: 95%

### Unit 7: Update SKILL.md
- **Changes**:
  - Add link to interview-workflow.md in references section
  - Update Review Agents table to include memory-validation (7 agents)
- **Self-Verification**: Grep for new references
- **Human QA**: None needed
- **Confidence Ceiling**: 95%

## Verification Plan

### Agent Self-Verification
- Grep for interview-workflow.md references across updated commands
- Verify memory-validation.md exists and has valid YAML
- Check uw-review.md spawns 7 agents (not 6)

### Human QA Checklist
- [ ] Review interview-workflow.md for completeness (confidence levels, stop conditions)
- [ ] Verify uw-work Step 0.5 interview loop doesn't create infinite loops
- [ ] Verify uw-review fix loop interview trigger is correctly placed
- [ ] Review memory-validation agent's Hindsight integration logic

## Spec Changelog
- 16-01-2026: Initial spec from interview
