# Learnings: uw-pr Command + uw-plan Safety Constraint
Date: 13-01-2026
Spec: .unitwork/specs/13-01-2026-uw-pr-command.md

## Feature Paths Discovered
- `plugins/unitwork/commands/uw-pr.md`: New slash command for PR creation/updates
- `plugins/unitwork/commands/uw-plan.md`: Planning command that now has read-only constraint
- `plugins/unitwork/.claude-plugin/plugin.json`: Plugin metadata including version and component counts
- `CHANGELOG.md` and `README.md`: At project root, not inside plugin directory

## Architectural Decisions
- **Native Claude execution**: Commands run inside Claude Code, so no need to spawn `claude -p` subprocess like the original shell script did
- **Natural language arguments**: Instead of strict `--to TARGET` flags, let Claude parse intent from natural language (e.g., "to staging with context about login bug")
- **Lightweight utility pattern**: PR command doesn't need full checkpoint cycle - it's a simple utility like `uw-action-comments`
- **Read-only planning constraint**: Added explicit "CRITICAL" section at top of uw-plan to prevent file edits during planning phase

## Gotchas & Quirks
- **Metadata files location**: CHANGELOG.md and README.md are at project root (`/unitwork/`), not inside `plugins/unitwork/` directory
- **YAML frontmatter name format**: Commands use `uw:pr` format (with colon) in the `name` field, not `uw-pr`
- **Version bump rules**: Adding a new command is a MINOR version bump (0.1.1 → 0.2.0), documented in CLAUDE.md

## Verification Insights
- **Self-verified**: YAML frontmatter structure matches other commands
- **Self-verified**: All required plugin metadata updated (version, description count, changelog, readme)
- **Needs human QA**: Actually running `/uw:pr` in a real git repo with a feature branch
- **Needs human QA**: Testing the read-only constraint in `/uw:plan` actually prevents edits

## For Next Time
- Check where metadata files live (root vs plugin directory) before editing
- When converting shell scripts to slash commands, identify what can be simplified (subprocess calls, flag parsing)
- Safety constraints belong at the TOP of command files with "CRITICAL" header for visibility
- Use AskUserQuestion for scope clarification early - user added the uw-plan constraint during plan revision
