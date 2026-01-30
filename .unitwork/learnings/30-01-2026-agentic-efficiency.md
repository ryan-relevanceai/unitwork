# Learnings: Agentic Efficiency Improvements
Date: 30-01-2026
Spec: .unitwork/specs/30-01-2026-agentic-efficiency.md

## Summary
Added parallel verification dispatch instructions across three Unit Work documentation files, replacing a 38-line ASCII decision tree with a 9-line markdown table while preserving all safety flags.

## Gotchas & Surprises
- **Reviewers flag intentional duplication**: When the spec required keeping uw-work.md's IF-THEN structure unchanged (for inline use during execution) while also updating verification-flow.md (the reference), reviewers flagged this as CODE_DUPLICATION. Future specs that require content in multiple places should explicitly document "intentional duplication" rationale to speed up review verification.

## Generalizable Patterns
- **Table format for decision trees**: ASCII flowcharts can be replaced with markdown tables (Change Type | Subagents | Safety Flags) for better scannability while preserving the same information. Tables are 4x more compact and easier to parse.
- **Parallel dispatch wording**: The established pattern is "launch all applicable agents in parallel using multiple Task tool calls in the same response" - this explicit instruction ensures Claude spawns agents in a single message.
