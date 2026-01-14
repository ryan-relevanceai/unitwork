# Checkpoint: Update all 6 review agents

## Verification Strategy
Grep verification - ensuring no hardcoded `plugins/unitwork/standards/` paths remain in any agent file.

## Subagents Launched
None required - this is a text replacement operation across multiple files.

## Confidence Assessment
- Confidence level: 95%
- Rationale: Simple edit replacing file path reference with skill reference in all 6 agents. Grep confirms no old paths remain.

## Learnings
- All agents had identical pattern on line 11: `Reference plugins/unitwork/standards/issue-patterns.md`
- Batch editing across multiple files with the same pattern was straightforward

## Human QA Checklist

### Prerequisites
None - this checkpoint edits existing files.

### Verification Steps
- [ ] Grep for `plugins/unitwork/standards` in `plugins/unitwork/agents/review/` - should return 0 matches
- [ ] Verify each agent's "Taxonomy Reference" section now says "Use the `review-standards` skill"
  - [ ] type-safety.md
  - [ ] patterns-utilities.md
  - [ ] performance-database.md
  - [ ] architecture.md
  - [ ] security.md
  - [ ] simplicity.md
- [ ] Run `/uw:review` on a test branch to verify agents load the skill correctly

### Notes
All command and agent files now reference the skill. Unit 4 will clean up the now-empty old directory.
