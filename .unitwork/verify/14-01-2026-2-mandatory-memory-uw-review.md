# Checkpoint: uw-review.md STEP 0 Memory Recall

## Verification Strategy
Manual file inspection to confirm structure ordering and routing table preservation.

## Subagents Launched
- None required (markdown documentation changes only)

## Confidence Assessment
- Confidence level: 95%
- Rationale: File structure verified by reading. STEP 0 appears after Introduction and before Required Reading. Routing table preserved in STEP 0. All required elements present.

## Learnings
- The routing table was a key piece to preserve from the original Context Recall section
- Review-specific failure mode example is different from work-specific one

## Human QA Checklist

### Prerequisites
Read the modified file at `plugins/unitwork/commands/uw-review.md`

### Verification Steps
- [ ] STEP 0 section appears after Introduction
- [ ] STEP 0 section appears BEFORE Required Reading
- [ ] Routing table (Memory Topic → Agent mapping) is preserved with all 7 rows
- [ ] `---` separators present before and after STEP 0
- [ ] Failure mode blockquote mentions "issues that caused bugs in past PRs"
- [ ] "DO NOT PROCEED" language present
- [ ] Old "## Context Recall" section is removed (no duplicate)

### Notes
The routing table is critical functionality for uw:review - memories get routed to specific agents by domain.
