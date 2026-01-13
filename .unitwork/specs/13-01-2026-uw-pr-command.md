# uw-pr Command + uw-plan Safety Constraint

## Purpose & Impact
- Converts existing `openPr.sh` shell script into a native Claude Code slash command
- Enables creating/updating GitHub PRs with AI-generated descriptions directly from Claude Code
- Benefits users who frequently create PRs and want consistent, well-formatted descriptions
- Adds safety constraint to uw-plan to prevent accidental file edits during planning

## Requirements

### Functional Requirements
- [ ] FR1: Create new draft PRs with AI-generated descriptions
- [ ] FR2: Update existing PR descriptions when new commits are pushed
- [ ] FR3: Support natural language arguments for target branch and extra context
- [ ] FR4: Show confirmation with commits, files, and diff size before proceeding
- [ ] FR5: Handle large diffs (>2000 lines) gracefully with appropriate messaging
- [ ] FR6: Exclude codegen/generated files from diff analysis
- [ ] FR7: Preserve custom headers/sections when updating existing PRs
- [ ] FR8: Assign current user to the PR
- [ ] FR9: Ask user whether to open PR in browser after creation/update
- [ ] FR10: uw-plan must NEVER edit files - planning is read-only (only writes spec file)

### Non-Functional Requirements
- [ ] NFR1: Use Claude natively (no subprocess spawning)
- [ ] NFR2: Follow unitwork command patterns (YAML frontmatter, markdown body)
- [ ] NFR3: Lightweight utility pattern (no checkpoint cycle)

### Out of Scope
- Full unitwork verification flow (specs, checkpoints)
- PR review functionality (separate concern)
- Multi-PR creation (one at a time)

## Technical Approach
- Create `/plugins/unitwork/commands/uw-pr.md` following existing command patterns
- Use natural language argument parsing (Claude interprets user intent)
- Use `gh` CLI for GitHub operations
- Generate PR descriptions inline (no subprocess)
- Follow PR description format from original script

## Implementation Units

### Unit 1: Create uw-pr.md command file
- **Changes:** `/plugins/unitwork/commands/uw-pr.md` (new file)
- **Self-Verification:** Review file structure matches other commands, YAML frontmatter is valid
- **Human QA:** Run `/uw-pr` in a test repo and verify it works
- **Confidence Ceiling:** 95%

### Unit 2: Add read-only constraint to uw-plan.md
- **Changes:** `/plugins/unitwork/commands/uw-plan.md` - add prominent "NEVER EDIT FILES" instruction
- **Self-Verification:** Verify constraint is clearly visible and unambiguous
- **Human QA:** Run `/uw:plan` and verify it refuses to edit files
- **Confidence Ceiling:** 99%

### Unit 3: Plugin metadata updates
- **Changes:**
  - `/plugins/unitwork/.claude-plugin/plugin.json` - version bump
  - `/plugins/unitwork/CHANGELOG.md` - add entry
  - `/plugins/unitwork/README.md` - update command count
- **Self-Verification:** Check version follows semver, changelog follows Keep a Changelog
- **Human QA:** Verify plugin loads correctly after changes
- **Confidence Ceiling:** 99%

## Verification Plan

### Agent Self-Verification
- Validate YAML frontmatter syntax
- Confirm command follows unitwork patterns
- Check all required sections are present

### Human QA Checklist
- [ ] Run `/uw-pr` in a git repo with uncommitted changes on a feature branch
- [ ] Verify confirmation dialog shows commits and files
- [ ] Verify PR is created as draft with correct description format
- [ ] Test updating an existing PR with new commits
- [ ] Test the browser open prompt works correctly
- [ ] Test with natural language like `/uw-pr to staging with context about fixing the login bug`
- [ ] Run `/uw:plan` and verify it only writes to `.unitwork/specs/` and never edits existing code

## Spec Changelog
- 13-01-2026: Initial spec from interview
- 13-01-2026: Added uw-plan read-only constraint (FR10, Unit 2)
