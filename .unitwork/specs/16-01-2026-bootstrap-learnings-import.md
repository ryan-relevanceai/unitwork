# Bootstrap Learnings Import

## Purpose & Impact
- Enable bootstrap to populate existing team learnings into Hindsight memory
- Allow new team members to benefit from accumulated knowledge immediately
- For already-setup repos, skip re-exploration and focus on learnings sync
- Compound existing documentation into actionable memory

## Requirements

### Functional Requirements
- [ ] FR1: Detect if repo has any existing setup (.unitwork dir OR bank in Hindsight)
- [ ] FR2: If partial/full setup detected, ask user if they want full setup or just learnings sync
- [ ] FR3: Identify learnings not authored by the current user via git blame (exact email match)
- [ ] FR4: Prompt user before importing team learnings to memory
- [ ] FR5: Use `hindsight memory retain-files` for bulk import of learnings
- [ ] FR6: Track last import timestamp in `.unitwork/.bootstrap.json`
- [ ] FR7: Only import learnings modified after last import timestamp
- [ ] FR8: For first-time setup with existing learnings, import after standard bootstrap

### Non-Functional Requirements
- [ ] NFR1: Use `git config user.email` to identify current user (exact match only)
- [ ] NFR2: Import should use --async to avoid blocking
- [ ] NFR3: Graceful handling if no learnings exist

### Out of Scope
- Syncing learnings from memory back to files
- Editing or filtering learnings content before import
- Matching GitHub noreply addresses as user emails

## Technical Approach

### Detection Logic
```bash
# Check .unitwork dir
test -d .unitwork && UNITWORK_EXISTS="yes" || UNITWORK_EXISTS="no"

# Check bank exists
BANK=$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
BANK_EXISTS=$(hindsight bank list -o json 2>&1 | grep -q "\"bank_id\": \"$BANK\"" && echo "yes" || echo "no")
```

### Partial Setup Decision
If either `.unitwork` OR bank exists, use AskUserQuestion:
```
Question: "Existing setup detected. What would you like to do?"
Options:
- Full setup (re-run exploration and import learnings)
- Sync learnings only (skip exploration)
- Exit (keep current state)
```

### Import State Tracking
Store import state in `.unitwork/.bootstrap.json`:
```json
{
  "lastLearningsImport": "2026-01-16T12:00:00Z"
}
```

### Identifying Non-User Learnings
```bash
# Get current user email
CURRENT_USER=$(git config user.email)

# For each file in .unitwork/learnings/*.md
# Get original author email (exact match)
AUTHOR=$(git log --follow --diff-filter=A --format='%ae' -- "$file" | head -1)
# If author != CURRENT_USER, include in import list
```

### Incremental Import
```bash
# Read last import timestamp
LAST_IMPORT=$(jq -r '.lastLearningsImport // "1970-01-01T00:00:00Z"' .unitwork/.bootstrap.json 2>/dev/null)

# Find files modified after last import
find .unitwork/learnings -name "*.md" -newermt "$LAST_IMPORT"
```

### Import Flow
```bash
# Import filtered learnings (files to temp directory, import, cleanup)
# OR import all and rely on incremental filtering
hindsight memory retain-files "$BANK" "$FILTERED_PATH" \
  --recursive \
  --context "unitwork team learnings" \
  --async
```

### Key Files to Modify
- `plugins/unitwork/commands/uw-bootstrap.md` - Main bootstrap command

## Implementation Units

### Unit 1: Add setup detection and branching
- **Changes:** Add Step 1.5 after dependency checks. Detect .unitwork dir and bank existence. If either exists, prompt user for action choice.
- **Self-Verification:** Run bootstrap on this repo, verify prompt appears with correct options
- **Human QA:** Confirm detection output and prompt options are clear
- **Confidence Ceiling:** 95%

### Unit 2: Add .bootstrap.json tracking
- **Changes:** Create/update `.unitwork/.bootstrap.json` with lastLearningsImport timestamp
- **Self-Verification:** Run import, verify JSON file created/updated with valid timestamp
- **Human QA:** Check file contents are correct JSON
- **Confidence Ceiling:** 95%

### Unit 3: Add git blame filtering for non-user learnings
- **Changes:** Add logic to identify learnings not authored by current user (exact email match)
- **Self-Verification:** Run filtering on existing learnings, verify correct files identified
- **Human QA:** Check output excludes user's own learnings
- **Confidence Ceiling:** 90%

### Unit 4: Add incremental import (modified since last import)
- **Changes:** Filter learnings to only those modified after lastLearningsImport timestamp
- **Self-Verification:** Set timestamp to yesterday, verify only recent files selected
- **Human QA:** Confirm incremental logic works correctly
- **Confidence Ceiling:** 85%

### Unit 5: Add user prompt and retain-files import
- **Changes:** Add AskUserQuestion before import. Call hindsight memory retain-files with filtered learnings.
- **Self-Verification:** Run bootstrap, verify prompt and import work
- **Human QA:** Verify learnings appear in Hindsight recall after import
- **Confidence Ceiling:** 90%

### Unit 6: Integrate into first-time and existing setup flows
- **Changes:** Wire up both paths - full setup includes learnings at end, sync-only skips to learnings
- **Self-Verification:** Test both flows work correctly
- **Human QA:** Test full bootstrap and sync-only both work
- **Confidence Ceiling:** 85%

## Verification Plan

### Agent Self-Verification
- Run bootstrap on already-setup repo (this one), verify detection and prompt
- Run git blame filtering, verify correct files identified
- Check .bootstrap.json after import for valid timestamp
- Check Hindsight memory after import with recall

### Human QA Checklist
- [ ] Run `/uw:bootstrap` on already-setup repo
- [ ] Verify prompt appears asking about full setup vs sync
- [ ] Select "Sync learnings only" and verify exploration is skipped
- [ ] Verify prompt appears before importing learnings
- [ ] After import, run `hindsight memory recall muscat "learnings"` and verify learnings appear
- [ ] Check `.unitwork/.bootstrap.json` has valid timestamp
- [ ] Run bootstrap again, verify only learnings modified since last import are considered

## Spec Changelog
- 16-01-2026: Initial spec from interview
- 16-01-2026: Added .bootstrap.json tracking for incremental imports
- 16-01-2026: Clarified partial setup handling with user prompt
- 16-01-2026: Specified exact email match for author filtering
