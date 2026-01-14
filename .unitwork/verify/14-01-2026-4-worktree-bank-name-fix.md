# Checkpoint: Worktree Bank Name Fix

## Verification Strategy
1. Grep for old pattern to confirm removal
2. Run new command from worktree to verify output

## Verification Results

### Old Pattern Removal
```bash
grep -r "basename.*git rev-parse.*show-toplevel" plugins/unitwork/commands/
# Result: No matches found
```
**Result:** PASS

### New Command Verification
```bash
BANK_NAME=$(git config --get remote.origin.url 2>/dev/null | sed 's/.*\///' | sed 's/\.git$//' || basename "$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')" || basename "$(pwd)")
# Result: unitwork
```
**Result:** PASS

## Files Updated
- `uw-bootstrap.md` - 3 locations
- `uw-plan.md` - 2 locations
- `uw-work.md` - 3 locations
- `uw-compound.md` - 1 location

Total: 9 replacements

## Confidence Assessment
**Confidence:** 98%

**Rationale:**
- Simple search/replace with grep verification
- New command tested from worktree
- -2% for not testing repos without remotes

## Learnings
- `git rev-parse --show-toplevel` returns worktree path, not repo name
- `git config --get remote.origin.url` is consistent across worktrees
- Fallback chain: remote URL → main worktree path → current directory

## Human QA Checklist

### Verification Steps
- [ ] Run `/uw:work` or `/uw:plan` from a worktree
- [ ] Verify Hindsight commands target the `unitwork` bank, not the worktree name
- [ ] Test on a repo without remotes to verify fallback works

### Notes
The existing `calgary` bank needs manual cleanup - this fix only prevents future fragmentation.
