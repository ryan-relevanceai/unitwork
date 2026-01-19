# Code Review: uw:investigate Command and Multiple Plugin Enhancements

**Date:** 20-01-2026
**Branch:** ryan-relevanceai/san-antonio
**Base:** main
**Files Changed:** 124 files, +9419/-547 lines

## Summary

- P1 Issues: 0
- P2 Issues: 1 (1 correctness, 0 cleanliness)
- P3 Issues: 4 (1 correctness, 3 cleanliness)

## Scope

This branch contains significant updates to the unitwork plugin:
- New command: `uw:investigate` for read-only codebase investigation
- New agents: conflict-resolution (2), memory-validation (1)
- New references: hindsight-reference.md, interview-workflow.md, verification-flow.md, checkpointing.md
- Shell script improvements: install_deps.sh
- Documentation updates: README.md, CHANGELOG.md, plugin.json

## P1 - Critical Issues

None found.

## P2 - Important Issues

### Correctness Issues

#### [SENSITIVE_DATA_EXPOSURE] - Severity: P2 - Tier: 1

**Location:** `install_deps.sh:142`

**Issue:** API key is printed to terminal in plain text when suggesting user add it to shell config.

**Why:** Terminal history, screen recordings, shoulder surfing, and logging software could capture the credential. The key remains visible until terminal is cleared.

**Code:**
```bash
# Line 142
echo "  export HINDSIGHT_API_LLM_API_KEY=$api_key"
```

**Fix:**
```bash
# Option 1: Redact the key
echo "  export HINDSIGHT_API_LLM_API_KEY=<your-api-key>"

# Option 2: Show only last 4 chars
echo "  export HINDSIGHT_API_LLM_API_KEY=...${api_key: -4}"
```

### Cleanliness Issues

None at P2.

## P3 - Nice-to-Have

### [NULL_HANDLING] - Severity: P3 - Tier: 1

**Location:** `install_deps.sh:151-157`

**Issue:** Docker run command uses unquoted environment variables. While functional in this context (values are controlled and don't come from untrusted input), quoting is shell script best practice.

**Code:**
```bash
# Lines 151-157
docker run -d --name hindsight --pull always -p 8888:8888 -p 9999:9999 \
    -e HINDSIGHT_API_LLM_API_KEY=$HINDSIGHT_API_LLM_API_KEY \
    ...
    -v $HOME/.hindsight-docker:/home/hindsight/.pg0 \
```

**Fix:**
```bash
docker run -d --name hindsight --pull always -p 8888:8888 -p 9999:9999 \
    -e "HINDSIGHT_API_LLM_API_KEY=$HINDSIGHT_API_LLM_API_KEY" \
    ...
    -v "$HOME/.hindsight-docker:/home/hindsight/.pg0" \
```

### [CONSOLIDATE_LOGIC] - Severity: P3 - Tier: 2

**Location:** Multiple command files (7+)

**Issue:** The "STEP 0: Memory Recall (MANDATORY)" section is nearly identical across 7 command files (~280 lines total). Each contains the same bash command for bank derivation and recall.

**Assessment:** This is intentional for agent execution - commands need the full pattern inline so agents can execute without cross-file lookups. The `hindsight-reference.md` serves as human documentation. Not a blocking issue.

### [CONSOLIDATE_LOGIC] - Severity: P3 - Tier: 2

**Location:** `uw-action-comments.md:~line 20` and other commands

**Issue:** The bank name derivation bash command is duplicated 9+ times. The `hindsight-reference.md` was created as single source of truth but commands still inline the full command.

**Assessment:** Same reasoning as above - intentional for agent-native documentation. Minor inconsistency between using `$BANK` variables vs inline command substitution.

### [REMOVE_COMMENT] - Severity: P3 - Tier: 2

**Location:** `uw-action-comments.md`

**Issue:** Meta-commentary "(kept inline for compliance)" in "Rules for interviewing" doesn't add value for documentation readers.

**Fix:**
```markdown
# Before
**Rules for interviewing (kept inline for compliance):**

# After
**Interview Rules:**
```

## Existing Code Issues (Informational)

None identified - all findings are in code added/modified by this change.

## What's Good

1. **Excellent architecture organization:**
   - New agents properly placed in `agents/conflict-resolution/`, `agents/exploration/`, `agents/plan-review/`
   - Standards appropriately relocated to `skills/review-standards/references/`
   - Commands follow `uw-{verb}` naming convention

2. **Template drift prevention:**
   - Previously inline templates replaced with references to canonical sources
   - `checkpointing.md`, `hindsight-reference.md`, `verification-flow.md` serve as single sources of truth
   - Commands now reference templates instead of duplicating

3. **Team learnings reinforced:**
   - "STEP 0" pattern consistently applied for mandatory steps
   - Workflow symmetry - memory recall added to ALL commands that need it
   - Memory routing table correctly implemented in uw-review.md
   - Finding verification steps added to ensure review findings are validated

4. **Documentation quality:**
   - Code examples in documentation follow documented standards
   - New commands well-documented with clear purpose
   - CHANGELOG and README properly updated

## Review Status

- [x] All P1s resolved (none found)
- [x] P2s addressed or explicitly deferred (1 deferred - user accepted risk)
- [x] P3s documented for future consideration (4 noted)

## Deferred Issues

### P2 - SENSITIVE_DATA_EXPOSURE (Deferred)
**Reason:** User accepted. The API key echo is intentional UX - helps users persist the key to their shell config. The user just typed the key so it's already visible. Local dev script, not production deployment.
