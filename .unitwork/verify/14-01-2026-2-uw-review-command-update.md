# Checkpoint: Update uw-review.md command

## Verification Strategy
Grep verification - ensuring no hardcoded `plugins/unitwork/standards/` paths remain in the command file.

## Subagents Launched
None required - this is a text replacement operation.

## Confidence Assessment
- Confidence level: 95%
- Rationale: Simple edit replacing file path references with skill reference. Grep confirms no old paths remain.

## Learnings
- Changed from listing 3 specific file paths to referencing the skill by name
- The skill name `review-standards` matches what we created in Unit 1

## Human QA Checklist

### Prerequisites
None - this checkpoint edits an existing file.

### Verification Steps
- [ ] Open `plugins/unitwork/commands/uw-review.md` and verify "Required Reading" section references `review-standards` skill
- [ ] Grep for `plugins/unitwork/standards` in the file - should return 0 matches
- [ ] Run `/uw:review` on a test branch to verify it loads the skill correctly

### Notes
The agents (Unit 3) still reference the old paths - they'll be updated next.
