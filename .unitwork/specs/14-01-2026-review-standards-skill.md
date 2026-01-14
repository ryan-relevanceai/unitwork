# Review Standards Skill Migration

## Purpose & Impact
- **Why:** The uw-review command and review agents fail to read standards files because they use hardcoded relative paths like `plugins/unitwork/standards/issue-patterns.md` that don't resolve when the plugin runs from the Claude cache directory
- **Who:** Anyone using /uw:review command
- **Success:** Standards content is accessible via skill natural language reference, no more "Error reading file" failures

## Requirements

### Functional Requirements
- [ ] FR1: Create a new skill `review-standards` that contains the review taxonomy and standards
- [ ] FR2: Update uw-review.md to reference the skill instead of file paths
- [ ] FR3: Update all 6 review agents to reference the skill instead of file paths
- [ ] FR4: Delete the old `plugins/unitwork/standards/` directory

### Non-Functional Requirements
- [ ] NFR1: Standards remain a single source of truth (no duplication)
- [ ] NFR2: Natural language reference works (e.g., "use the review-standards skill")

### Out of Scope
- Documentation files in `.unitwork/` that reference the old paths (these are historical records)
- Any other path resolution issues in other commands

## Technical Approach

### Current Structure
```
plugins/unitwork/
├── agents/review/
│   ├── type-safety.md       # References plugins/unitwork/standards/issue-patterns.md
│   ├── patterns-utilities.md
│   ├── performance-database.md
│   ├── architecture.md
│   ├── security.md
│   └── simplicity.md
├── commands/
│   └── uw-review.md         # References all 3 standards files
├── standards/               # TO BE DELETED
│   ├── issue-patterns.md
│   ├── review-standards.md
│   └── checklists.md
└── skills/
    └── unitwork/
        └── SKILL.md
```

### New Structure
```
plugins/unitwork/
├── agents/review/
│   └── *.md                 # Updated to reference review-standards skill
├── commands/
│   └── uw-review.md         # Updated to reference review-standards skill
└── skills/
    ├── unitwork/
    │   └── SKILL.md
    └── review-standards/    # NEW
        ├── SKILL.md         # Main skill file with description
        └── references/
            ├── issue-patterns.md
            ├── review-standards.md
            └── checklists.md
```

### Skill Reference Pattern
Instead of:
```markdown
Reference `plugins/unitwork/standards/issue-patterns.md` for pattern definitions.
```

Use:
```markdown
Use the review-standards skill for pattern definitions, team standards, and checklists.
```

The skill's SKILL.md will include the standards content (or reference its local files) so they're loaded when the skill is invoked.

## Implementation Units

### Unit 1: Create review-standards skill
- **Changes:**
  - Create `plugins/unitwork/skills/review-standards/SKILL.md` with skill metadata and content organization
  - Move `plugins/unitwork/standards/issue-patterns.md` → `plugins/unitwork/skills/review-standards/references/issue-patterns.md`
  - Move `plugins/unitwork/standards/review-standards.md` → `plugins/unitwork/skills/review-standards/references/review-standards.md`
  - Move `plugins/unitwork/standards/checklists.md` → `plugins/unitwork/skills/review-standards/references/checklists.md`
- **Self-Verification:** File existence check, skill structure validation
- **Human QA:** Verify skill shows up in Claude's available skills list
- **Confidence Ceiling:** 95%

### Unit 2: Update uw-review.md command
- **Changes:**
  - Update `plugins/unitwork/commands/uw-review.md` lines 17-21 to reference the review-standards skill instead of file paths
  - Change from "read these reference files" to "load the review-standards skill"
- **Self-Verification:** Read file and verify no hardcoded `plugins/unitwork/standards/` paths remain
- **Human QA:** Run /uw:review and verify it doesn't produce "Error reading file"
- **Confidence Ceiling:** 95%

### Unit 3: Update all 6 review agents
- **Changes:** Update these files to reference skill instead of file path:
  - `plugins/unitwork/agents/review/type-safety.md` (line 11)
  - `plugins/unitwork/agents/review/patterns-utilities.md` (line 11)
  - `plugins/unitwork/agents/review/performance-database.md` (line 11)
  - `plugins/unitwork/agents/review/architecture.md` (line 11)
  - `plugins/unitwork/agents/review/security.md` (line 11)
  - `plugins/unitwork/agents/review/simplicity.md` (line 11)
- **Self-Verification:** Grep for `plugins/unitwork/standards/` in agents directory - should return 0 results
- **Human QA:** Run /uw:review and verify agents can access taxonomy patterns
- **Confidence Ceiling:** 95%

### Unit 4: Delete old standards directory
- **Changes:** Remove `plugins/unitwork/standards/` directory and its contents
- **Self-Verification:** Directory no longer exists
- **Human QA:** Verify plugin still works without the old directory
- **Confidence Ceiling:** 98%

## Verification Plan

### Agent Self-Verification
- Grep for `plugins/unitwork/standards/` in commands and agents directories - expect 0 matches
- Verify new skill directory exists with all 3 reference files
- Verify old standards directory is deleted

### Human QA Checklist
- [ ] Run `/uw:review` on a test branch
- [ ] Verify "Error reading file" no longer appears
- [ ] Verify review agents spawn successfully
- [ ] Verify agents reference the taxonomy patterns correctly in their output
- [ ] Check that the review-standards skill appears in the skills list

## Spec Changelog
- 14-01-2026: Initial spec from interview
