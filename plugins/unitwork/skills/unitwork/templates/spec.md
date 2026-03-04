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
- **Changes:** Files to modify
- **Self-Verification:** How agent verifies
- **Human QA:** Checklist for human review
- **Confidence Ceiling:** X%

## Verification Approach

**Success Metrics:**
- What measurable outcomes indicate success?
- Example: "All tests pass", "Bundle size < 500KB", "API response < 200ms"

**Measurement Method:**
- How will we measure? What tools/tests?
- Example: "Run `pnpm test`", "Use webpack-bundle-analyzer"

**Baseline Values:**
- Current state before changes (captured during planning)
- Example: "Current bundle: 650KB", "Current response: 350ms"

**Expected Outcome:**
- What we assert after implementation
- Example: "Bundle < 500KB", "Response < 200ms"

**E2E Testing:** (Y/N)
- If Y: What to check and how (browser automation, manual steps, etc.)

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
- {date}: Amendment - {reason for change} - {learning from this}
