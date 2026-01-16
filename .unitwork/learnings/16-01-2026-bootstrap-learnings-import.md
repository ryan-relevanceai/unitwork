# Learnings: Bootstrap Learnings Import
Date: 16-01-2026
Spec: .unitwork/specs/16-01-2026-bootstrap-learnings-import.md

## Summary
Added automatic import of team learnings to Hindsight memory during bootstrap, enabling new team members to benefit from accumulated knowledge immediately without re-discovering past gotchas and patterns.

## Gotchas & Surprises

- **Bank name validation needed:** When deriving shell variables from external sources (git remote URL), always validate the result against a safe character set before using in commands. Even with sed sanitization, shell metacharacters could slip through. Pattern: `if ! [[ "$VAR" =~ ^[a-zA-Z0-9._-]+$ ]]; then exit 1; fi`

- **find vs bash glob for existence checks:** Using `find ... | head -1` to check if files exist is slower and more complex than bash's `shopt -s nullglob` with array expansion. The glob approach is pure bash (no subprocess) and handles missing directories gracefully.

- **Git timestamps vs filesystem mtime:** For incremental operations comparing "when was this file last modified", prefer `git log -1 --format='%aI'` over filesystem mtime. Git timestamps are more reliable across clones and are not affected by file operations like cp.

## Generalizable Patterns

- **Fractional step numbering (1.5, 7.5):** When inserting steps into existing numbered procedures, fractional numbers avoid renumbering but signal organic growth. Consider full renumbering on major revisions for cleaner documentation.

- **State tracking for incremental operations:** When building features that shouldn't re-process already-handled items, use a state file (like `.bootstrap.json` with `lastLearningsImport`) rather than relying on external state. This makes the feature self-contained and predictable.

- **Two-filter pattern for team content:** When identifying "team content" (not authored by current user), combine: (1) author filtering via git blame/log, and (2) timestamp filtering for incrementality. Both filters must pass (AND logic).

## Verification Blind Spots

- **Changelog and version bump forgotten AGAIN:** Despite being a known gotcha from previous features, we still forgot to update CHANGELOG.md and bump version in plugin.json before creating the PR. This happens because these are "release steps" that feel separate from implementation. Must add explicit checklist item to /uw:pr or /uw:review workflow.
