# Learnings: Mandatory Memory Recall Enhancement

Date: 14-01-2026
Spec: .unitwork/specs/14-01-2026-mandatory-memory-recall.md

## Summary

Made memory recall STEP 0 (mandatory first action) in all workflow commands (uw-work, uw-review, uw-plan) and added memory as a core principle in SKILL.md. Additionally improved verification templates to maximize AI verification and minimize human review.

## Gotchas & Surprises

- **Self-demonstrating failure**: The feature was triggered when I (the agent) skipped memory recall while checking git log vs changelog. This proved the problem was real - agents do skip optional-seeming steps even when documented.

- **Feature creep is good sometimes**: While implementing the memory changes, user feedback led to two additional improvements (checkpoints 6 and 7) that weren't in the original spec:
  1. "AI-Verified (100% Confidence)" section in verify templates - maximizes what agent verifies, minimizes human review
  2. Review found plugin.json still said "9 agents" when we have 12 - documentation drift is real

- **Templates need to stay in sync**: The inline template in uw-work.md drifted from the canonical verify.md template. When templates exist in multiple places, they diverge.

## Generalizable Patterns

- **STEP 0 pattern**: When a step must never be skipped, call it "STEP 0" not "Step 1" - the numbering makes it psychologically harder to skip. Add visual separators (---), CRITICAL callouts, and "DO NOT PROCEED" language.

- **Failure mode examples**: Instead of just saying "don't skip this", show what goes wrong. Context-specific failure examples are more compelling than generic warnings.

- **AI-Verified section**: For verification documents, explicitly list what the agent verified with 100% certainty (grep, read, test output). Reserve Human QA Checklist only for things requiring human judgment (visual design, UX, edge cases). Don't waste human time re-verifying verifiable items.

- **Documentation drift detection**: Plugin descriptions (agent counts, command counts) drift from reality. Review should check that counts match actual files.

## Verification Blind Spots

- **Agent count**: Review agents caught that plugin.json said "9 agents" but we have 12. This wasn't caught during the feature implementation because I was focused on the memory changes, not peripheral documentation.

- **Template synchronization**: The inline template in uw-work.md was missing Prerequisites and Notes sections that exist in verify.md. Multiple sources of truth diverge.
