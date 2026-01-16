# Learnings: Plan-Work Flow Modifications

Date: 16-01-2026
Spec: .unitwork/specs/16-01-2026-plan-work-flow-modifications.md

## Summary

Modified Unit Work commands to share verification flows, conditionally spawn plan-review agents based on scope, and auto-detect PR by branch. Created verification-flow.md as single source of truth for verification protocols.

## Gotchas & Surprises

- **Plan-review agents caught scope issues early**: During planning, gap-detector identified that creating a separate pr-detection.md file was too trivial (2-line pattern), and uw-pr.md already had auto-detect. These units were removed BEFORE implementation started, preventing wasted effort. Lesson: The plan-review step genuinely catches issues that would otherwise surface mid-implementation.

- **Intentional duplication vs accidental**: Review agents flagged PR auto-detect pattern appearing in 4 files. This was dismissed because it was an explicit design decision during planning. Lesson: When dismissing review findings, document WHY - "known design decision from planning" is valid rationale.

## Generalizable Patterns

- **MOVE-then-reference consolidation**: When consolidating documentation across multiple files, MOVE content to a single source of truth, then update original files with cross-references. This pattern preserves anchor links from external documentation while eliminating duplication.

- **Scope-based agent spawning**: Instead of spawning all agents unconditionally, add a threshold check. For Unit Work: >3 implementation units = full review (3 agents), <=3 units = light review (gap-detector only). This reduces overhead for small changes without losing critical gap detection.

- **Inline rationale comments**: When a threshold or magic number appears in documentation (like ">3 units"), include a brief rationale comment. Future maintainers shouldn't need to hunt through specs to understand why.
