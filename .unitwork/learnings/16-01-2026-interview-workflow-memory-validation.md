# Learnings: Interview Workflow & Memory Validation

Date: 16-01-2026
Spec: .unitwork/specs/16-01-2026-interview-workflow-memory-validation.md

## Summary

Extracted interview logic into reusable `interview-workflow.md` reference and created `memory-validation` review agent that validates PRs against all team learnings from Hindsight. This enables cross-command interview consistency and institutional knowledge enforcement during code review.

## Gotchas & Surprises

- **Component counts drift silently**: Adding a new agent (memory-validation) without updating plugin.json description caused a P2 review finding. When adding new agents/commands/skills, immediately update all places that track counts (plugin.json, README, CLAUDE.md). This compounds across multiple features in a branch.

- **SKILL.md command list incompleteness**: The SKILL.md had 6 commands listed but there are 8. Easy to miss when commands are added incrementally across specs. Verify lists match reality during review.

- **Review agents scope to PR changes**: Security agent flagged issues in `install_deps.sh` but the file wasn't in the diff. Agent was reviewing file content, not diff content. Findings on unchanged files should be dismissed as "existing code, not PR change" unless the PR explicitly modifies them.

## Generalizable Patterns

- **Verification immediacy**: When adding new components (agents, commands), update metadata files (plugin.json, README counts) in the same checkpoint that adds the component. Batching metadata updates to the end causes drift.

- **Cross-reference consolidation**: When extracting reusable content (like interview-workflow), use the move-then-reference pattern: create the canonical reference first, then update each consumer to link to it. This maintains self-contained documentation while eliminating duplication.

- **Review agent scope verification**: Before accepting a review finding, verify the issue exists in the diff (added/modified lines), not just in context lines or unchanged files. Use `git diff main...HEAD -- <file>` to confirm.

## Addendum: Hindsight Reference (checkpoint 15)

### Additional Gotchas

- **Hindsight ANSI output breaks parsing**: Hindsight CLI outputs colored text with ANSI escape sequences like `[38;2;0;117;214m`. When capturing output to variables or processing programmatically, these break text parsing. Always pipe through `sed 's/\x1b\[[0-9;]*m//g'` to strip them.

- **Reference file timing**: We had Hindsight patterns duplicated across 13+ files before consolidating into hindsight-reference.md. Should have created the reference file when the pattern appeared in 3+ places, not 13+.

### Additional Patterns

- **STEP numbering for bash procedures**: Using explicit STEP 1, STEP 2, STEP 3 with bash code blocks in agent instructions ensures procedures aren't skipped. Agents tend to skip undifferentiated prose; numbered steps with code force compliance.
