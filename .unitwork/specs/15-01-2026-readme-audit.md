# README Audit and Workflow Documentation

## Purpose & Impact
- Update stale README to reflect current state of the plugin (v0.4.0)
- Document all 8 workflow commands with key phases and how they compound
- Help new users understand the full workflow and when to use each command
- Single source of truth - all workflow documentation in README

## Requirements

### Functional Requirements
- [ ] FR1: Update component counts table (12→13 agents, 7→8 commands, 1→2 skills)
- [ ] FR2: Add `/uw:fix-ci` command to Commands section
- [ ] FR3: Add `memory-aware-explore` agent to Agents section (new Exploration category)
- [ ] FR4: Add `review-standards` skill to Skills section with link to patterns
- [ ] FR5: Document workflow steps for all 8 commands (overview + 2-4 key phases each)
- [ ] FR6: Replace simple workflow diagram with expanded diagram showing full flow
- [ ] FR7: Add "what it does and how it compounds" explanation for the overall system

### Non-Functional Requirements
- [ ] NFR1: Keep README readable - overview + phases, not full step-by-step detail
- [ ] NFR2: Single source of truth - describe WHAT and WHEN, not implementation details
- [ ] NFR3: Follow existing README style (tables for listings, H2/H3 headers, bash code blocks)

### Out of Scope
- Adding example output (user explicitly declined)
- Troubleshooting section
- Changes to command files themselves
- Creating separate WORKFLOWS.md file

## Technical Approach
- Single file edit to README.md
- Preserve existing sections that are accurate
- Add new sections for expanded workflow documentation
- Update existing sections with missing components
- Reference sources: CLAUDE.md (structure), CHANGELOG.md (user-facing descriptions), command files (phases)

## Implementation Units

### Unit 1: Update component counts and add missing items to tables
- **Changes:**
  - Component counts table section
  - Add `/uw:fix-ci` to Utilities commands table
  - Add new "Exploration Agents (1)" subsection with header and table (after Plan Review Agents)
  - Add `review-standards` to Skills section (match unitwork format with bullet points)
- **Self-Verification:** Verify counts match actual files: 13 agents, 8 commands, 2 skills, 1 MCP
- **Human QA:**
  - [ ] Component counts match actual files in plugins/unitwork/
  - [ ] All 8 commands listed
  - [ ] All 13 agents listed with correct categories (4 categories)
  - [ ] Both skills documented with descriptions
- **Confidence Ceiling:** 95%

### Unit 2: Replace workflow diagram with expanded version
- **Changes:** Workflow section - replace simple diagram with expanded version
- **Diagram Structure:**
```
┌─────────────┐
│ uw:bootstrap│  (First-time setup)
└──────┬──────┘
       ▼
┌─────────────┐
│  uw:plan    │  (Create spec)
└──────┬──────┘
       ▼
┌─────────────┐
│  uw:work    │  (Implement with checkpoints)
└──────┬──────┘
       ▼
┌─────────────┐
│  uw:review  │───► uw:compound (auto-triggered)
└──────┬──────┘
       ▼
┌─────────────┐
│   uw:pr     │  (Create PR)
└──────┬──────┘
       │
  ┌────┴────┐
  ▼         ▼
uw:fix-ci  uw:action-comments
(CI fails)  (PR comments)
  │         │
  └────┬────┘
       ▼
    (Merge)
```
- **Self-Verification:** Verify diagram renders correctly in markdown preview
- **Human QA:**
  - [ ] Diagram shows all 8 commands
  - [ ] Flow is logical and readable
- **Confidence Ceiling:** 95%

### Unit 3: Document core workflow commands (plan, work, review, compound)
- **Changes:** Expand Commands section with workflow documentation for 4 core commands
- **Format per command:** Overview sentence + 2-4 key phases + compounding note
- **Reference sources:** CHANGELOG.md, command files in plugins/unitwork/commands/
- **Self-Verification:** Each command has overview + phases + compounding explanation
- **Human QA:**
  - [ ] plan: mentions interview, exploration, spec creation
  - [ ] work: mentions checkpoints, verification agents, confidence thresholds
  - [ ] review: mentions 6 parallel agents, finding verification, fix loop
  - [ ] compound: mentions Hindsight retention, learning extraction
- **Confidence Ceiling:** 95%

### Unit 4: Document utility commands (bootstrap, fix-ci, pr, action-comments)
- **Changes:** Continue Commands section with workflow documentation for 4 utility commands
- **Format per command:** Overview sentence + 2-4 key phases + compounding note (or "does not compound")
- **Reference sources:** CHANGELOG.md, command files in plugins/unitwork/commands/
- **Self-Verification:** Each command has overview + phases + compounding explanation
- **Human QA:**
  - [ ] bootstrap: mentions dependency check, Hindsight setup, codebase exploration
  - [ ] fix-ci: mentions analyze→fix→commit→push→verify loop, safety limits
  - [ ] pr: mentions draft PR creation, AI-generated description
  - [ ] action-comments: mentions comment categorization, lightweight verification
- **Confidence Ceiling:** 95%

### Unit 5: Add "How Unit Work Compounds" explanation
- **Changes:** Add section after Philosophy explaining the compounding mechanism
- **Content:** How each phase contributes to learning, role of Hindsight, memory types
- **Reference sources:** skills/unitwork/SKILL.md (philosophy), uw-compound.md
- **Self-Verification:** Explains learning flow without duplicating Hindsight Integration section
- **Human QA:**
  - [ ] Clearly explains what "compounding" means
  - [ ] Shows connection between phases and learning
  - [ ] Doesn't duplicate existing Hindsight Integration section details
- **Confidence Ceiling:** 95%

## Verification Plan

### Agent Self-Verification
- Count files in plugins/unitwork/ directories to verify component counts
- Verify all 8 commands documented
- Verify all 13 agents listed across 4 categories
- Verify both skills documented

### Human QA Checklist
- [ ] README renders correctly (check markdown formatting)
- [ ] Component counts are accurate (13 agents, 8 commands, 2 skills, 1 MCP)
- [ ] All commands have workflow documentation with phases
- [ ] Expanded diagram is clear and shows all 8 commands
- [ ] No duplicate information between sections
- [ ] Overall flow makes sense for new users

## Spec Changelog
- 15-01-2026: Initial spec from interview
  - Scope: Comprehensive audit with expanded workflow diagram
  - Format: Overview + key phases per command (not full step-by-step)
  - Examples: Explanation of what it does, not example output
  - Skills: Include review-standards with link to patterns
- 15-01-2026: Revised after plan review
  - Split Unit 3 into two units (core workflow + utilities) per feasibility review
  - Removed line number references per gap detector feedback
  - Added draft diagram structure per gap detector feedback
  - Added reference sources (CHANGELOG.md, CLAUDE.md) per utility auditor feedback
  - Clarified Exploration Agents needs new category section
