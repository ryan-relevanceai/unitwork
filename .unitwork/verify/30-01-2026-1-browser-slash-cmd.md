# Verification: checkpoint(1) - Convert agent-browser skill to /uw:browser-test command

## Changes Made

1. **Created** `plugins/unitwork/commands/uw-browser-test.md` - All 705 lines from SKILL.md preserved with command frontmatter
2. **Deleted** `plugins/unitwork/skills/agent-browser/` directory
3. **Updated** `plugins/unitwork/commands/uw-work.md` line 185 - "agent-browser skill" -> "/uw:browser-test command"
4. **Updated** `plugins/unitwork/commands/uw-action-comments.md` line 209 - same reference update
5. **Updated** `plugins/unitwork/skills/unitwork/SKILL.md` line 178 - same reference update
6. **Updated** `plugins/unitwork/CLAUDE.md` - removed agent-browser from skills listing, added uw-browser-test and uw-investigate to commands listing, fixed command count (9->11), updated UI verification references
7. **Updated** `plugins/unitwork/.claude-plugin/plugin.json` - version 0.8.0->0.9.0, description "10 commands, 3 skills" -> "11 commands, 2 skills"

## AI-Verified

- [x] `plugins/unitwork/skills/agent-browser/` is deleted (directory does not exist)
- [x] `plugins/unitwork/commands/uw-browser-test.md` exists with 705 lines and command frontmatter
- [x] `grep -r "agent-browser.*skill" plugins/unitwork/` returns no matches (all references updated)
- [x] `plugin.json` shows version `0.9.0` with correct counts (11 commands, 2 skills)
- [x] Actual file counts match: 11 command files, 2 skill directories

## Human QA Checklist

(None required - all verification items are deterministic and AI-verified)

## Confidence: 100%

All changes are deterministic text replacements and file operations. Every verification check passes.
