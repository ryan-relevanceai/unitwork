# Checkpoint: Create memory-aware-explore agent

## Verification Strategy
Read file to verify YAML frontmatter structure and location.

## AI-Verified (100% Confidence)
- [x] File exists at `plugins/unitwork/agents/exploration/memory-aware-explore.md`
- [x] YAML frontmatter has `name: memory-aware-explore`
- [x] YAML frontmatter has `description:` with examples
- [x] YAML frontmatter has `model: inherit`
- [x] Agent instructions include 5-step workflow (Recall, Validate, Explore, Synthesize, Retain)
- [x] Bank name derivation uses `git config --get remote.origin.url` (worktree-safe)
- [x] Retain uses `--async` flag
- [x] Graceful degradation section handles Hindsight unavailability

## Confidence Assessment
- Confidence level: 95%
- Rationale: Agent structure is verifiable. Instructions follow spec. Human review recommended for instruction clarity and completeness.

## Learnings
- Agent format requires examples in description within YAML (escaped newlines)
- Traversal strategy documentation is key differentiator from standard Explore

## Human QA Checklist (if desired)
- [ ] Review agent instructions for clarity
- [ ] Verify memory recall query format is sensible
- [ ] Check retain format captures traversal strategy adequately
