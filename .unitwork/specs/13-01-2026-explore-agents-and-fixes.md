# Explore Agents, Interview Enhancement, and Documentation Fixes

## Purpose & Impact
- **Why**: Preserve main thread context by offloading codebase exploration to subagents; ensure thorough requirement gathering through extensive interviews; fix incorrect CLI documentation
- **Who**: All users of the Unit Work plugin
- **Success**: All codebase exploration uses Explore subagents with specific focuses; interviews dig deep into implementation details until high confidence; Hindsight CLI commands work correctly; .unitwork is version controlled

## Requirements

### Functional Requirements
- [x] FR1: Remove .gitignore handling for .unitwork directory - always track in version control
- [x] FR2: Use Explore subagents (up to 2 in parallel) for all codebase exploration, each with specific focuses
- [x] FR3: Fix Hindsight `disposition` command - it's read-only, inferred from background
- [x] FR4: Fix Hindsight `recall` command - use `--include-chunks` not `--include-entities`
- [x] FR5: Enhance interview phase to ask extensive non-obvious questions until high confidence

### Non-Functional Requirements
- [x] NFR1: Documentation changes only (no code)
- [x] NFR2: Maintain consistency across all affected files

### Out of Scope
- Adding new Explore agent definitions (reuse existing system Explore agent type)
- Changes to other Hindsight commands not mentioned

## Technical Approach
- Edit markdown files in `plugins/unitwork/`
- Update bootstrap, plan, and decision-trees documentation
- All changes are documentation/configuration - no runtime code

## Implementation Units

### Unit 1: Fix Hindsight CLI Commands
**Changes:**
- `plugins/unitwork/commands/uw-bootstrap.md`: Remove `hindsight bank disposition` with flags (line 73)
- `plugins/unitwork/commands/uw-plan.md`: Change `--include-entities` to `--include-chunks` (line 34)
- `plugins/unitwork/skills/unitwork/references/decision-trees.md`: Change `--include-entities` to `--include-chunks` (line 82)

**Self-Verification:** Read modified files to confirm syntax matches `hindsight --help` output
**Human QA:** Run `hindsight memory recall` and `hindsight bank disposition` commands manually
**Confidence Ceiling:** 98%

### Unit 2: Remove .gitignore Handling
**Changes:**
- `plugins/unitwork/commands/uw-bootstrap.md`: Remove line 141 about adding .unitwork to .gitignore

**Self-Verification:** Grep for "gitignore" in plugins/unitwork - should return no results
**Human QA:** Verify bootstrap instructions no longer mention gitignore
**Confidence Ceiling:** 99%

### Unit 3: Add Explore Subagents for Codebase Exploration
**Changes:**
- `plugins/unitwork/commands/uw-bootstrap.md`: Add Task tool with Explore subagents for Step 5 exploration
  - Agent 1 focus: Entry points, configuration, and architecture patterns
  - Agent 2 focus: Tests, existing utilities, and naming conventions
- `plugins/unitwork/commands/uw-plan.md`: Add Task tool with Explore subagents for Phase 1 codebase exploration
  - Agent 1 focus: Files related to feature, existing implementations
  - Agent 2 focus: Test patterns, related utilities, edge case handling
- Update instructions to spawn both agents in parallel with a single message

**Self-Verification:** Read modified files to confirm Explore agent usage with specific focuses is documented
**Human QA:** Run /uw:bootstrap or /uw:plan and verify Explore agents spawn with distinct focuses
**Confidence Ceiling:** 95%

### Unit 4: Enhance Interview Phase
**Changes:**
- `plugins/unitwork/commands/uw-plan.md`: Expand Phase 2 Interview section to include:
  - Extensive non-obvious questions about implementation details (API design, data structures, error handling)
  - Edge case questions (error states, empty states, boundary conditions)
  - Testing strategy questions (what to test, mocking approach, coverage expectations)
  - UI/UX questions only when feature involves UI components
  - Continue interviewing until agent has high confidence in all implementation details
  - No arbitrary minimum rounds - confidence-based gate

**Interview question categories to add:**
1. **Implementation details**: "How should errors be surfaced?", "What data format for X?", "Should this be sync or async?"
2. **Edge cases**: "What happens when X is empty?", "How to handle partial failures?", "What's the behavior at limits?"
3. **Testing**: "What edge cases need test coverage?", "Should we mock X or use real?", "Integration test needed?"
4. **Dependencies**: "Any external services involved?", "What happens if dependency fails?"

**Self-Verification:** Read uw-plan.md to confirm interview expansion
**Human QA:** Run /uw:plan and verify agent asks thorough questions before writing spec
**Confidence Ceiling:** 92%

## Verification Plan

### Agent Self-Verification
- Read all modified files after changes
- Grep for removed patterns (gitignore, --include-entities, disposition flags)
- Confirm Explore agent instructions with specific focuses are present
- Confirm interview expansion with question categories is documented

### Human QA Checklist
- [ ] Run `hindsight memory recall "unitwork" "test query" --budget mid --include-chunks` - should work
- [ ] Run `hindsight bank disposition "unitwork"` - should show current disposition (read-only)
- [ ] Verify no mention of .gitignore in bootstrap command
- [ ] Run /uw:bootstrap on a test project - verify 2 Explore agents spawn with different focuses
- [ ] Run /uw:plan on a test project - verify 2 Explore agents spawn with different focuses
- [ ] Run /uw:plan and verify agent asks implementation, edge case, and testing questions
- [ ] Verify agent continues interviewing until confident (not arbitrary rounds)

## Spec Changelog
- 13-01-2026: Initial spec from interview - 3 units covering Hindsight fixes, gitignore removal, and Explore agent addition
- 13-01-2026: Added Unit 4 for interview enhancement - extensive non-obvious questions, confidence-based gating
- 13-01-2026: Updated Unit 3 to specify distinct agent focuses for parallel exploration
