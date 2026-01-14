# Learnings: uw:work Context Recall
Date: 14-01-2026
Spec: N/A (emerged from versioning mistake)

## Feature Paths Discovered
- `plugins/unitwork/commands/uw-work.md`: The work command now has a "Context Recall" section after Resume Detection
- `plugins/unitwork/CLAUDE.md`: Contains pre-commit checklist that was being missed

## Architectural Decisions
- **Memory recall at work start, not in every spec**: Learnings like versioning rules belong in Hindsight memory, recalled at work time, not duplicated in every spec
- **Separate resume detection from context recall**: Resume detection uses `--budget low` for quick progress check; context recall uses `--budget mid` for richer learnings

## Gotchas & Quirks
- **CHANGELOG and version bump required for EVERY commit**: The `plugins/unitwork/CLAUDE.md` has a pre-commit checklist that must be followed. Easy to forget when focused on implementation.
- **Hindsight memory compounds over time**: The more gotchas retained, the more valuable context recall becomes. Early sessions may have sparse recalls.

## Verification Insights
- **Human caught the versioning miss**: The 6-agent review didn't catch missing CHANGELOG updates because it reviews code, not process. Process compliance requires human oversight or explicit tooling.
- **Memory is the safety net**: Retaining the gotcha means future sessions will be reminded via context recall.

## For Next Time
- After every feature implementation, mentally run through CLAUDE.md pre-commit checklist
- Consider adding a pre-commit hook or explicit checklist step to uw:work completion
- Gotchas about workflow/process should be retained immediately when discovered
