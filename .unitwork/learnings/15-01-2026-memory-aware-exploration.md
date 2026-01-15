# Learnings: Memory-Aware Exploration Agent

Date: 15-01-2026
Spec: .unitwork/specs/15-01-2026-memory-aware-exploration.md

## Summary

Created a memory-aware-explore agent that integrates Hindsight memory into codebase exploration. The agent recalls prior exploration findings, validates key file locations (medium trust), and retains summarized findings including traversal strategies. Updated uw-plan and uw-bootstrap to use this agent instead of standard Explore.

## Gotchas & Surprises

- **CLAUDE.md documentation drift**: The review caught that CLAUDE.md was missing the `agents/plan-review/` directory even though it contained 3 agents. When adding new agent directories, check CLAUDE.md's directory tree AND Agent Organization sections. This was pre-existing but not caught until now.

- **Review skipped /uw:compound**: After running /uw:review and fixing P2 issues, I went straight to PR creation without running /uw:compound to capture learnings. The workflow says to trigger /uw:compound after review completion, but it's easy to skip when excited about creating the PR.

## Generalizable Patterns

- **Documentation duplication is often intentional**: When reviewing for CODE_DUPLICATION in markdown instruction files (not executable code), consider whether the "duplication" serves self-containment. DRY applies differently to docs - readers shouldn't need to jump between files to understand instructions. A one-liner bash command appearing 12 times in self-contained markdown files is acceptable.

- **Review-then-review pattern**: After fixing issues from code review, spawn a simplicity agent to independently verify the fixes weren't overengineered. This catches cases where you "fixed" a problem by adding unnecessary abstraction.

- **Accepting non-fixes as valid**: Sometimes the correct fix is to NOT change the code. Documenting why duplication is intentional is itself a fix - it closes the issue with clear reasoning.
