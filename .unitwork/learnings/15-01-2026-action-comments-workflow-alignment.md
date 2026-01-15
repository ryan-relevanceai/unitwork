# Learnings: Action Comments Workflow Alignment
Date: 15-01-2026
Spec: .unitwork/specs/15-01-2026-action-comments-workflow-alignment.md

## Summary
Consolidated checkpoint logic into a single reference file (`checkpointing.md`) and aligned `uw-action-comments` with the standard Unit Work checkpoint workflow. Reduced duplication across command files while maintaining the emphasis on mandatory Memory Recall.

## Gotchas & Surprises
- **Documentation drift is real**: The architecture review agent caught that CLAUDE.md's directory tree didn't include the new `checkpointing.md`. This validates the team's prior learning about documentation drift. When adding ANY new file to the plugin structure, check CLAUDE.md's directory tree immediately.

- **Confidence calculation is duplicated 4+ places**: The consolidation goal was partially achieved - checkpoint commit format is now single-sourced, but confidence calculation remains in uw-action-comments, uw-work, checkpointing.md, and SKILL.md. Future consolidation work should tackle this.

- **Memory routing matters for reviews**: The architecture agent found the CLAUDE.md issue specifically because the review prompt included the team memory about documentation drift. This validates the pattern of routing domain-specific memories to relevant review agents.

## Generalizable Patterns
- **Reference file consolidation**: When multiple command files share identical protocol content (like checkpoint format), create a `references/` file and have commands reference it. Keep context-specific examples inline but reference the authoritative source for formats and protocols.

- **Intentional duplication for emphasis**: Memory Recall (STEP 0) is duplicated across 5 command files. This is intentional - critical steps that agents tend to skip need CRITICAL callouts, NEVER language, and repetition. The redundancy is a feature, not a bug.

- **Prompted vs automatic phase transitions**: Compound phase at end of uw-action-comments is prompted ("Run /uw:compound?") rather than automatic. This pattern works better than automatic transitions for optional steps where user may want to skip or defer.

## Verification Blind Spots
- **CLAUDE.md directory tree**: Automated verification didn't initially catch the missing entry. The review agent caught it only because team memory was routed to the architecture agent. For features adding new files to the plugin structure, explicitly verify CLAUDE.md during checkpoint (not just during review).
