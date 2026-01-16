# Learnings: Fix Conflicts Command

Date: 16-01-2026
Spec: .unitwork/specs/16-01-2026-fix-conflicts.md

## Summary

Added `/uw:fix-conflicts` command that autonomously rebases onto the default branch with multi-agent conflict resolution using intent analysis and impact exploration. This creates a workflow where high-confidence conflicts are auto-resolved while low-confidence or conflicting-goals scenarios prompt user interviews.

## Gotchas & Surprises

- **New agent files missing YAML frontmatter**: The spec described creating new agents but didn't mention YAML frontmatter requirements. Review caught that both `conflict-intent-analyst.md` and `conflict-impact-explorer.md` were missing the `---` frontmatter that ALL other 14 agents have. When adding new agents, always include YAML frontmatter with `name`, `description`, and `model: inherit`.

- **CLAUDE.md multi-section drift**: Adding new components (agents, reference files) causes drift in MULTIPLE locations of CLAUDE.md simultaneously:
  1. Directory tree (missing reference files)
  2. Agent Organization section (missing new agent category)
  3. Component counts (6 vs 7 review agents)
  4. Component lists (missing memory-validation.md)

  A single feature addition cascaded into 4 separate P2 findings. When adding new plugin components, check ALL sections of CLAUDE.md systematically.

- **Review caught spec-invisible requirements**: The spec listed 8 implementation units but didn't include "add YAML frontmatter to new agents" - this was an implicit requirement that only review caught. Specs should explicitly call out structural requirements like frontmatter when creating new files.

## Generalizable Patterns

- **New agent checklist**: When creating agents, always verify:
  1. YAML frontmatter present (`name`, `description`, `model: inherit`)
  2. CLAUDE.md directory tree updated
  3. CLAUDE.md Agent Organization section updated
  4. Any component counts updated (plugin.json, README, CLAUDE.md prose)

- **Documentation drift is multiplicative**: Each new component type (agent, command, skill, reference) creates drift in multiple documentation locations. The pattern isn't "update CLAUDE.md" - it's "update 4+ specific sections of CLAUDE.md plus plugin.json plus README".

- **Review agents find implicit requirements**: The 7 review agents caught 4 P2 issues that weren't in the spec. Plan-review agents catch issues BEFORE implementation; review agents catch issues AFTER. Both are necessary but serve different purposes.

## Verification Blind Spots

- **Structural conformance not in spec**: The spec's Human QA Checklist (lines 208-220) didn't include "verify YAML frontmatter present" or "verify CLAUDE.md sections updated". These were caught only by review agents, not by spec-defined verification. Future specs for new components should include structural verification in the Human QA Checklist.
