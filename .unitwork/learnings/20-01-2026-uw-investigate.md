# Learnings: uw:investigate Command

Date: 20-01-2026
Spec: .unitwork/specs/20-01-2026-uw-investigate.md

## Summary

Added a read-only codebase investigation command (`uw:investigate`) that enables deep exploration without modifying code. Transforms write-oriented goals into investigation form, uses memory-aware-explore agents, and retains findings to Hindsight.

## Gotchas & Surprises

- **Branch accumulation scope creep**: This branch accumulated multiple features before review (124 files, +9419 lines). The review covered far more than just uw:investigate - it included conflict-resolution agents, memory-validation agent, hindsight-reference.md, and install script changes from prior features. Consider running `/uw:review` more frequently to keep scope focused.

- **Security severity is context-dependent**: The security agent flagged echoing an API key as P2, but in a local dev installer script where the user just typed the key, the risk profile is different than production code. The same pattern would be P1 in production - context matters when triaging security findings.

- **Intentional duplication for agent-native docs**: The review agents flagged "STEP 0: Memory Recall" being duplicated across 7 commands (~280 lines). This is intentional - AI agents need full context inline to execute without cross-file lookups. What looks like DRY violation to traditional review is actually correct agent-native architecture.

## Generalizable Patterns

- **Agent-native documentation pattern**: When documentation is executed by AI agents rather than humans, inline the full pattern rather than referencing other files. Agents operate better with complete context in one place, even if it means "duplication" from a human perspective.

- **Transform-then-proceed pattern**: For commands that might be misused (write tasks given to read-only command), detect the mismatch, transform to appropriate form, and explain the transformation to the user rather than refusing. "This sounds like X. I'll do Y instead. Use Z for X."

- **Review frequency scales with branch complexity**: Multi-feature branches need review before each merge, not just at the end. The review document should match the feature scope - a review covering 124 files suggests the branch sat too long before review.
