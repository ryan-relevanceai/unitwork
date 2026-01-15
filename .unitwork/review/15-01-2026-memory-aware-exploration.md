# Code Review: Memory-Aware Exploration Feature

## Summary
- P1 Issues: 0
- P2 Issues: 2 (1 correctness, 1 cleanliness)
- P3 Issues: 3

## P1 - Critical Issues

None.

## P2 - Important Issues

### Correctness Issues

### [FILE_ORGANIZATION] - Severity: P2 - Tier: 1

**Location:** `plugins/unitwork/CLAUDE.md:24-98`

**Issue:** The `agents/plan-review/` directory (containing 3 agents: feasibility-validator.md, gap-detector.md, utility-pattern-auditor.md) is not documented in CLAUDE.md. The directory structure tree and Agent Organization sections are both missing this directory.

**Why:** CLAUDE.md is the authoritative guide for plugin structure. Missing documentation makes it unclear where plan-review agents exist or how they relate to the plugin's workflows. This affects correctness because developers will not understand the plugin's component inventory.

**Fix:**

In the directory tree (around line 30), add:
```
├── agents/
│   ├── exploration/             # Memory-aware codebase exploration
│   │   └── memory-aware-explore.md
│   ├── plan-review/             # Plan validation specialists
│   │   ├── feasibility-validator.md
│   │   ├── gap-detector.md
│   │   └── utility-pattern-auditor.md
│   ├── verification/            # Verification subagents
```

In Agent Organization section (after exploration/), add:
```markdown
### plan-review/
Plan validation specialists for `/uw:plan`:
- `feasibility-validator.md` - Validate implementation feasibility
- `gap-detector.md` - Detect gaps in plan coverage
- `utility-pattern-auditor.md` - Audit for reusable patterns
```

### Cleanliness Issues

### [CODE_DUPLICATION] - Severity: P2 - Tier: 2 - **RESOLVED: Accepted as Intentional**

**Location:** Multiple files

**Issue:** The bank name derivation pattern is duplicated 12 times across the codebase (9 in this diff).

**Resolution:** After analysis, this duplication is **accepted as intentional** for the following reasons:

1. **Documentation ≠ Code** - DRY applies differently to docs; self-contained instructions have value
2. **One-liner** - The command is a single line; extracting adds indirection for minimal benefit
3. **Reader experience** - Developers reading uw-work.md shouldn't need to jump to another file
4. **Low maintenance cost** - Global search-replace is trivial if the pattern changes
5. **Context matters** - Each occurrence has slightly different surrounding context

**Decision:** No code changes. The duplication serves a purpose (self-contained docs).

## P3 - Nice-to-Have

### [REDUNDANT_LOGIC] - Severity: P3 - Tier: 2

**Location:** `plugins/unitwork/commands/uw-plan.md:316-350` and `plugins/unitwork/commands/uw-review.md:174-208`

**Issue:** The "Finding Verification (Critical)" section is duplicated between uw-plan.md and uw-review.md with ~90% identical content.

**Why:** Same logic expressed in multiple places creates maintenance burden. However, this duplication may be intentional for self-contained documentation.

**Fix:** Could extract to shared reference file or keep as-is if intentional.

---

### [REMOVE_UNUSED_CODE] - Severity: P3 - Tier: 2

**Location:** `plugins/unitwork/agents/exploration/memory-aware-explore.md:59-66`

**Issue:** The "Calculate staleness" formula and percentage thresholds are defined but don't influence agent behavior.

**Why:** The staleness percentage is reported but never changes behavior - the agent always proceeds with exploration regardless.

**Fix:** Either remove the staleness calculation (just report confirmed/stale counts) or add behavior changes based on thresholds.

---

### [CONSOLIDATE_LOGIC] - Severity: P3 - Tier: 2

**Location:** `plugins/unitwork/agents/plan-review/*.md` and `plugins/unitwork/commands/uw-plan.md:248-320`

**Issue:** The three plan-review agents exist as separate files (~443 lines total) while uw-plan.md Phase 3.5 contains inline prompts that duplicate this content.

**Why:** This creates two sources of truth. However, verification shows this is **intentional design**: uw-plan.md uses `subagent_type="general-purpose"` with role prompts, using the agent files as reference documentation rather than the actual agent type.

**Fix:** No fix required - design is intentional. The agent files serve as expanded documentation/reference for what the general-purpose agents do.

## Existing Code Issues (Informational)

None - all issues above are from this diff.

## What's Good

1. **Type safety in examples** - No casting violations in code examples
2. **Security** - All bash commands properly quote variables and use controlled values
3. **Performance** - Agents correctly spawned in parallel where independent
4. **Memory operations** - Properly use `--async` for retains
5. **Consistent patterns** - New agents follow established YAML frontmatter structure
6. **Validation strategy** - memory-aware-explore limits validation to 3-5 files for performance

## Review Status
- [x] All P1s resolved (none found)
- [x] P2s addressed:
  - FILE_ORGANIZATION: Fixed CLAUDE.md to include plan-review directory
  - CODE_DUPLICATION: Accepted as intentional (self-contained docs)
- [x] P3s documented for future consideration

## Verification Log

### Finding: plan-review agents use general-purpose instead of specialized type
**Agent:** simplicity
**Original Severity:** P2
**Verification Status:** DISMISSED
**Rationale:** This is intentional design per the spec. The agent files exist as reference documentation, while uw-plan.md uses general-purpose agents with inline role prompts.
**Action:** none - dismissed

### Finding: CLAUDE.md missing plan-review directory
**Agent:** architecture
**Original Severity:** P2
**Verification Status:** VERIFIED
**Rationale:** Confirmed via file read - CLAUDE.md lacks plan-review/ in both directory tree and Agent Organization sections.
**Action:** Fix required

### Finding: Bank name derivation duplicated
**Agent:** patterns-utilities
**Original Severity:** P2
**Verification Status:** VERIFIED
**Rationale:** Confirmed 12 occurrences across codebase, 9 in this diff.
**Action:** Consider extracting to reference or accept as intentional
