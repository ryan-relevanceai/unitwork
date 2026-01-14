# Learnings: Review Standards Skill Migration

Date: 14-01-2026
Spec: .unitwork/specs/14-01-2026-review-standards-skill.md

## Summary

Migrated hardcoded file path references to a skill-based architecture to solve path resolution failures when Claude runs plugins from cache directories. Changed from `plugins/unitwork/standards/*.md` paths to "use the review-standards skill" references across 1 command and 6 review agents.

## Gotchas & Surprises

- **Relative links in skills work correctly**: Skills have proper path resolution, so `./references/file.md` works where `plugins/unitwork/standards/file.md` failed. This was confirmed during checkpoint 1 - the existing checklists.md already used relative links and needed no modification.

- **Skill description format matters**: The review caught that skill descriptions should follow the pattern "This skill should be used when..." to match existing conventions. Easy to miss when creating new skills.

## Generalizable Patterns

- **Skills solve plugin path resolution**: When a plugin runs from Claude's cache directory, hardcoded relative paths fail. Skills with their references/ subdirectory provide stable path resolution. Use skills for any content that agents or commands need to reference.

- **Commands → Agents → Skills dependency direction**: This migration reinforced the inward dependency pattern. Commands load agents, agents load skills. Skills should never reference commands or agents.

- **Review-then-fix for P2 issues**: The review found a P2 cleanliness issue that was immediately fixed in checkpoint 5. The spec's 5-checkpoint structure (create, update command, update agents, delete old, review fix) worked cleanly.
