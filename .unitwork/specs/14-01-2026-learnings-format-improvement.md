# Learnings Format Improvement

## Purpose & Impact
- Learnings documents currently duplicate spec content instead of capturing the journey
- The purpose of learnings is to help future /plan and /work sessions understand what went differently than expected
- Learnings should be generalizable patterns, not implementation details

## Requirements

### Functional Requirements
- [ ] FR1: Learnings template should focus on deviations from spec, not repeat spec content
- [ ] FR2: Learnings should include brief summary (1-2 sentences) + focus on journey
- [ ] FR3: uw-compound command should guide extraction of generalizable insights
- [ ] FR4: Learnings should document what deviated from spec and why

### Non-Functional Requirements
- [ ] NFR1: Learnings should be useful when recalled for a different but related task
- [ ] NFR2: Pattern: "For task X, we learned Y" not "For task X, we did Y"

### Out of Scope
- Updating existing learnings files (leave as-is)
- Changing spec template format
- Modifying Hindsight retain patterns

## Technical Approach
- Update `plugins/unitwork/skills/unitwork/templates/learnings.md`
- Update `plugins/unitwork/commands/uw-compound.md` to guide better extraction

## Implementation Units

### Unit 1: Update learnings template
- **Changes:** `plugins/unitwork/skills/unitwork/templates/learnings.md`
- **Self-Verification:** Read template, verify sections focus on journey not duplication
- **Human QA:** Review that template clearly communicates the distinction
- **Confidence Ceiling:** 95%

### Unit 2: Update uw-compound command
- **Changes:** `plugins/unitwork/commands/uw-compound.md`
- **Self-Verification:** Verify guidance emphasizes generalizable learnings over implementation details
- **Human QA:** Run /uw:compound on a future feature to test new guidance
- **Confidence Ceiling:** 95%

## Verification Plan

### Agent Self-Verification
- Template avoids sections that encourage spec duplication
- Command guidance explicitly contrasts learnings vs spec

### Human QA Checklist
- [ ] Read updated template - does it make clear what learnings should NOT include?
- [ ] Read updated command - does the extraction guidance focus on journey?
- [ ] On next feature, run /uw:compound and check if output follows new format

## Spec Changelog
- 14-01-2026: Initial spec from interview
