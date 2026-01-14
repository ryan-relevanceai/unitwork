# Fix Hindsight Bank Name Derivation for Git Worktrees

## Purpose & Impact
- **Why:** Currently, Hindsight bank names are derived from `git rev-parse --show-toplevel` which returns the worktree path, not the repo name. This causes each worktree to create a separate memory bank, fragmenting learnings.
- **Who:** Developers using Unit Work with git worktrees
- **Success:** All worktrees of the same repo share a single Hindsight memory bank

## Requirements

### Functional Requirements
- [x] FR1: Bank name derivation must return the same value for all worktrees of a repo
- [x] FR2: Must handle repos with remotes (primary case)
- [x] FR3: Must handle repos without remotes (fallback to main worktree name)
- [x] FR4: Update all Hindsight invocations in unitwork commands

### Non-Functional Requirements
- [x] NFR1: Command should be a one-liner for inline use
- [x] NFR2: No BANK_NAME variable (per user preference from earlier in this session)

### Out of Scope
- Merging the existing `calgary` and `unitwork` banks (manual cleanup)
- Handling submodules

## Technical Approach

### Current (Broken) Pattern
```bash
$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))
```
- Returns worktree directory name, not repo name
- Each worktree gets its own bank

### New (Fixed) Pattern
```bash
$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
```

**Derivation logic:**
1. **Primary:** Extract repo name from remote origin URL (works for all worktrees)
2. **Fallback 1:** Get basename of main worktree (for repos without remotes)
3. **Fallback 2:** Current directory name (last resort)

### Files to Update
1. `plugins/unitwork/commands/uw-bootstrap.md` - 3 locations
2. `plugins/unitwork/commands/uw-plan.md` - 2 locations
3. `plugins/unitwork/commands/uw-work.md` - 3 locations
4. `plugins/unitwork/commands/uw-compound.md` - 1 location

## Implementation Units

### Unit 1: Update uw-bootstrap.md
- **Changes:** Replace 3 instances of the old bank name derivation
- **Self-Verification:** Grep for the old pattern, confirm 0 matches
- **Human QA:** N/A - simple search/replace
- **Confidence Ceiling:** 99%

### Unit 2: Update uw-plan.md
- **Changes:** Replace 2 instances
- **Self-Verification:** Grep for old pattern
- **Human QA:** N/A
- **Confidence Ceiling:** 99%

### Unit 3: Update uw-work.md
- **Changes:** Replace 3 instances
- **Self-Verification:** Grep for old pattern
- **Human QA:** N/A
- **Confidence Ceiling:** 99%

### Unit 4: Update uw-compound.md
- **Changes:** Replace 1 instance
- **Self-Verification:** Grep for old pattern
- **Human QA:** N/A
- **Confidence Ceiling:** 99%

### Unit 5: Verify fix works
- **Changes:** None (verification only)
- **Self-Verification:** Run the new command from worktree, confirm it returns `unitwork`
- **Human QA:** Test from both main worktree and this worktree
- **Confidence Ceiling:** 95%

## Verification Plan

### Agent Self-Verification
```bash
# Verify no old pattern remains
grep -r "basename.*git rev-parse.*show-toplevel" plugins/unitwork/commands/

# Verify new pattern works from worktree
git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//'
# Should return: unitwork
```

### Human QA Checklist

#### Prerequisites
1. Be in a worktree (e.g., calgary)

#### Verification Steps
- [ ] Run `/uw:work` on a test spec
- [ ] Verify Hindsight recall queries the `unitwork` bank, not `calgary`
- [ ] Verify Hindsight retain stores to the `unitwork` bank

## Spec Changelog
- 14-01-2026: Initial spec from problem discovery
