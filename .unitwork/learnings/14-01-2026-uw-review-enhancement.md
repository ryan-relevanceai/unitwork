# Learnings: UW Review Enhancement

Date: 14-01-2026
Spec: .unitwork/specs/14-01-2026-uw-review-enhancement.md

## Summary

Enhanced the `/uw:review` command with taxonomy-based code review using 47 issue patterns and a tier-based severity system where correctness always outranks cleanliness at the same P-level. Created reference files for patterns, standards, and checklists.

## What Deviated from Spec

The spec didn't anticipate user feedback during implementation triggering additional checkpoints:
- checkpoint(1.1): User requested direct Hindsight invocation instead of BANK_NAME variable
- checkpoint(1.2): User requested process improvements after noticing checkpoint was missed

**Learning for similar tasks:** When adapting code from another project, expect mid-implementation feedback on style/pattern preferences that weren't in the original spec. Build in slack for "style alignment" checkpoints.

## Gotchas & Surprises

- **Checkpoint process failure**: After implementing user's BANK_NAME feedback, I asked "Would you like me to commit?" instead of just checkpointing. The uw-work.md rules existed but weren't explicit enough. Fix: Added "CRITICAL" callouts and "NEVER ask permission" language in multiple places.

- **Documentation examples must follow their own rules**: The review caught that our type guard "GOOD" example used `as` casting - violating the very principle the document teaches. When writing documentation with code examples, review the examples against the standards being documented.

- **Shell variable collision**: Used `$PATH` in a bash example which is a reserved variable. Always use unique variable names like `$AREA_PATH` in documentation examples.

- **Duplication is sometimes intentional**: The review flagged duplication between issue-patterns.md and review-standards.md. We deferred the fix because they serve different audiences (reviewers vs developers). Document the rationale when intentional duplication exists.

## Generalizable Patterns

- **Tier-based severity**: Separating "correctness" from "cleanliness" at the tier level (not just severity) ensures bugs are always prioritized over style issues. Apply this when designing any prioritization system.

- **Redundancy for critical rules**: Rules that agents skip need stronger language AND multiple reinforcement points. A single rule statement isn't enough - add "CRITICAL" callouts, "NEVER" statements, and repeat in relevant sections.

- **Cross-reference don't duplicate**: When creating multiple reference documents, establish one as canonical and have others link to it. Reduces maintenance burden and drift.

## Verification Blind Spots

The parallel review agents caught issues the original implementation missed:
- Example code contradicting documented principles (casting in type guard example)
- Reserved shell variables in examples ($PATH)
- Duplication that could lead to drift

**For similar tasks:** Run the review tooling on the review tooling itself. Documentation that teaches standards must exemplify those standards.
