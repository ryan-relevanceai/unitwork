# Code Review: Bootstrap Learnings Import

## Summary
- P1 Issues: 0
- P2 Issues: 2 (2 correctness, 0 cleanliness)
- P3 Issues: 4 (1 correctness, 3 cleanliness)

## P1 - Critical Issues

None found.

## P2 - Important Issues

### Correctness Issues

#### INJECTION_VULNERABILITY - Tier 1
**Location:** `plugins/unitwork/commands/uw-bootstrap.md:59` (and other BANK derivation locations)

**Issue:** Bank name derived from git remote URL is used without character validation. A maliciously crafted remote URL could potentially contain shell metacharacters.

**Risk:** P2 (not P1) because:
1. Attacker needs local git config access (already compromised)
2. sed commands provide some sanitization
3. Variables are properly quoted

**Fix:**
```bash
# After BANK derivation, add validation
if ! [[ "$BANK" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid bank name '$BANK'. Bank names must contain only alphanumeric characters, dashes, underscores, or dots."
    exit 1
fi
```

---

#### REDUNDANT_LOGIC - Tier 1
**Location:** `plugins/unitwork/commands/uw-bootstrap.md:229-236`

**Issue:** Learnings directory check uses both `-d` test AND find when the subsequent loop already handles empty case.

**Current:**
```bash
if [ -d ".unitwork/learnings" ] && [ "$(find .unitwork/learnings -name '*.md' 2>/dev/null | head -1)" ]; then
    LEARNINGS_EXIST="yes"
else
    LEARNINGS_EXIST="no"
fi
```

**Fix:** The loop at line 256 (`for file in .unitwork/learnings/*.md`) with `[ -f "$file" ] || continue` already handles missing directory gracefully. The existence check could use simpler bash glob:
```bash
shopt -s nullglob
FILES=(.unitwork/learnings/*.md)
LEARNINGS_EXIST=$([ ${#FILES[@]} -gt 0 ] && echo "yes" || echo "no")
```

### Cleanliness Issues

None at P2 level.

## P3 - Nice-to-Have

### Correctness Issues

#### PATH_TRAVERSAL (defense in depth) - Tier 1
**Location:** `plugins/unitwork/commands/uw-bootstrap.md:314-317`

**Issue:** File copy loop doesn't explicitly skip symlinks.

**Fix:**
```bash
for file in "${IMPORT_LIST[@]}"; do
    [ -L "$file" ] && continue  # Skip symlinks for security
    cp "$file" "$TEMP_DIR/"
done
```

### Cleanliness Issues

#### FILE_ORGANIZATION (step numbering) - Tier 2
**Location:** `plugins/unitwork/commands/uw-bootstrap.md:50-82, 222-358`

**Issue:** Fractional step numbering (1.5, 7.5) is unconventional and suggests organic growth rather than holistic design.

**Recommendation:** Consider renumbering all steps sequentially on next major revision. Not blocking.

---

#### FILE_ORGANIZATION (.bootstrap.json undocumented) - Tier 2
**Location:** New file `.unitwork/.bootstrap.json` not documented in SKILL.md

**Issue:** The `.unitwork/` directory structure in `SKILL.md` should be updated to include `.bootstrap.json`.

**Fix:** Update `plugins/unitwork/skills/unitwork/SKILL.md` directory structure.

---

#### PERFORMANCE_OPTIMIZATION (git calls) - Tier 1
**Location:** `plugins/unitwork/commands/uw-bootstrap.md:256-281`

**Issue:** Two `git log` calls per file in the filtering loop. Could short-circuit by checking author first (more likely to filter out files).

**Impact:** Low - typical learnings count is <20 files (400ms overhead at worst).

**Recommendation:** Note for future optimization if file counts grow significantly.

## Existing Code Issues (Informational)

None - all findings are in newly added code.

## What's Good

1. **Memory compliance:** Implementation correctly follows team learnings (worktree-safe bank derivation, async flag, incremental tracking)
2. **User agency:** Uses AskUserQuestion to let user choose between full setup, sync-only, or exit
3. **Incremental approach:** Timestamp tracking avoids re-importing already-imported learnings
4. **Defense in depth:** Checks both .unitwork dir AND Hindsight bank for existing setup detection
5. **Git-based filtering:** Uses git log for timestamps rather than filesystem mtime (more reliable)

## Review Status
- [x] All P1s resolved (none found)
- [ ] P2s addressed or explicitly deferred
- [ ] P3s documented for future consideration

## Patterns Found
- INJECTION_VULNERABILITY
- REDUNDANT_LOGIC
- PATH_TRAVERSAL
- FILE_ORGANIZATION
- PERFORMANCE_OPTIMIZATION
