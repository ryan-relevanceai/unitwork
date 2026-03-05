# Learnings: Vibe-Flow Ports to Unit Work Plugin
Date: 05-03-2026
Spec: .unitwork/specs/04-03-2026-port-vibe-flow-concepts.md

## Summary
Ported 7 concepts from vibe-flow skills into the unitwork plugin: triviality gate, rich PR descriptions, AI smell detector agent, approach sanity check, CLAUDE.md rule injection, Plan PR flow, and a new /uw:pr-review command. 15 checkpoints across 11 files, 1,285 lines changed.

## What Deviated from Spec
- **Gemini adversarial review was added then removed** (checkpoints 5 and 9): The Gemini review step in uw:plan was implemented but then removed because it duplicated the existing plan-review agent workflow without adding clear value. Lesson: when porting features from one system to another, evaluate whether the target system already covers the capability differently.
- **uw:pr-review was not in original spec**: It was added as a follow-up spec (05-03-2026-pr-review-command.md) after the initial 7 units were complete. This is fine — the original spec was a port of existing concepts, and the new command emerged as a natural extension.

## Gotchas & Surprises
- **Template drift between inline and standalone templates**: When a command file (uw-plan.md) contains an inline copy of a template that also exists as a standalone file (templates/spec.md), they WILL drift. The review caught that spec.md was missing "Linear Ticket" and "Assumptions" sections that existed in the inline version. When adding sections to inline templates, always check the standalone template too.
- **Review agents produce many false positives on markdown instruction files**: Security agents flagged bash snippets as shell injection vulnerabilities, but these are instructional templates for AI agents, not executed scripts. The entire threat model is different. When reviewing markdown command files, dismiss security findings about bash variable expansion — the AI agent constructs commands at runtime.
- **Self-contained markdown commands can't be deduplicated**: Multiple agents flagged ~200 lines duplicated between uw-pr-review.md and uw-review.md. But markdown command files have no import mechanism — each file must be self-contained. Cross-references like "Same as /uw:review" are the best you can do.

## Generalizable Patterns
- **SKILL.md as documentation checklist**: When adding a new command, always update SKILL.md's Commands section. This was caught during review — easy to forget.
- **Adapt, don't copy, when porting between review/external-review**: The uw:pr-review command adapts the approach sanity check to post as a finding (reviewer reports) rather than halt (author fixes). When creating "external" variants of "internal" commands, identify the key behavioral differences upfront.
- **Triviality gating saves planning overhead**: The pre-gate in uw:plan uses git diff analysis (file count, risk signals like "migration", "schema") to skip unnecessary planning for simple changes. This pattern applies to any multi-step workflow that's overkill for trivial changes.
