# uw:investigate - Read-Only Codebase Investigation Command

## Purpose & Impact
- **Why:** Enable deep investigative exploration of codebases without risk of modifying production data or code. Fills the gap between `/uw:plan` (which focuses on planning implementation) and ad-hoc exploration.
- **Who it helps:** Developers debugging issues, investigating performance bottlenecks, or needing comprehensive understanding before deciding on next steps.
- **Success looks like:** User gets a thorough investigation report with evidence, can run tests/scripts to confirm hypotheses, and findings are retained in memory for future sessions.

## Requirements

### Functional Requirements
- [ ] FR1: Accept an investigation goal as argument (e.g., "why is the API slow when fetching users")
- [ ] FR2: Transform write-sounding goals into investigation form internally (e.g., "fix bug X" becomes "investigate why bug X occurs")
- [ ] FR3: Use memory-aware-explore agents to investigate the codebase with memory integration
- [ ] FR4: Allow running existing tests via test-runner agent to confirm hypotheses
- [ ] FR5: Allow creating temporary test scripts to verify findings (scripts must be deleted after investigation)
- [ ] FR6: Produce in-conversation summary (no local file artifact)
- [ ] FR7: Retain findings to Hindsight memory at investigation end
- [ ] FR8: Never modify real code or data - strictly read-only except for temporary verification scripts

### Non-Functional Requirements
- [ ] NFR1: Follow existing command structure (YAML frontmatter, STEP 0 memory recall, etc.)
- [ ] NFR2: Match existing naming convention (`uw-investigate.md` in `plugins/unitwork/commands/`)
- [ ] NFR3: Support argument-hint in frontmatter for CLI help

### Out of Scope
- Writing investigation reports to `.unitwork/investigations/` (user requested in-conversation only)
- Creating new permanent test files
- Making code changes of any kind
- Running mutating API requests (POST/PUT/DELETE)

## Technical Approach

### Architecture
- New command file: `plugins/unitwork/commands/uw-investigate.md`
- Reuses existing agents: `memory-aware-explore`, `test-runner`
- Follows the Commands -> Agents -> Skills dependency pattern

### Key Files Affected
- `plugins/unitwork/commands/uw-investigate.md` (new)
- `plugins/unitwork/.claude-plugin/plugin.json` (update command count)

### Goal Transformation Logic
When the goal contains write-oriented language, detect and transform:

**Write-Oriented Keywords:**
- "fix", "implement", "add", "create", "update", "delete", "remove", "refactor", "change", "modify", "build"

**Transformation Examples:**
| User Input | Transformed Goal |
|------------|------------------|
| "fix the login bug" | "investigate why the login bug occurs and what causes it" |
| "add pagination to users list" | "investigate what would be needed to add pagination to users list" |
| "refactor the auth module" | "investigate the current auth module structure and identify what refactoring would involve" |
| "create a new API endpoint" | "investigate existing API patterns and what creating a new endpoint would require" |
| "delete unused code" | "investigate which code is unused and the impact of removing it" |

**Detection Logic:**
1. Check if first word is a write-oriented keyword
2. OR check if goal starts with imperative verb suggesting modification
3. If detected: Report transformation to user and proceed with investigation form
4. If not detected: Proceed with original goal

**User Message:** "This sounds like a write task. I'll investigate first: '{transformed goal}'. Use `/uw:plan` or `/uw:work` to implement changes after investigation."

### Temporary Script Handling
Temporary scripts enable hypothesis verification without modifying the codebase.

**When to Use Temporary Scripts:**
- When existing tests don't cover the specific hypothesis
- When you need to reproduce a bug with specific input
- When you need to measure performance with specific data
- When no test file exists for the code under investigation

**Script Lifecycle:**
```
1. mkdir -p /tmp/uw-investigate-$(date +%s)
2. Write script to /tmp/uw-investigate-{ts}/test_hypothesis.{ext}
3. chmod +x /tmp/uw-investigate-{ts}/test_hypothesis.{ext}
4. Execute and capture output
5. rm -rf /tmp/uw-investigate-{ts}  # IMMEDIATELY after execution
```

**Cleanup Guarantee:**
- Delete in same bash command chain: `./script.sh; rm -rf /tmp/uw-investigate-*`
- On script error: Still delete (use `||` to ensure cleanup)
- Never leave temp directories behind

**Script Constraints:**
- Read-only operations only (no DB writes, no file modifications outside /tmp)
- Max 50 lines
- Must complete within 30 seconds
- Must not require user input

## Implementation Units

### Unit 1: Create uw-investigate.md command file
- **Changes:** Create `plugins/unitwork/commands/uw-investigate.md` with:
  - YAML frontmatter (name, description, argument-hint)
  - CRITICAL: Read-Only Mode section
  - STEP 0: Memory Recall (mandatory)
  - Goal validation and transformation logic
  - Investigation phases using memory-aware-explore agents
  - Hypothesis verification using test-runner + temporary scripts
  - Summary generation
  - Memory retention at end
- **Self-Verification:** Read the file, verify structure matches other commands
- **Human QA:** Review the command flow makes sense
- **Confidence Ceiling:** 90% (follows established patterns)

### Unit 2: Update plugin.json
- **Changes:** Update command count in `plugins/unitwork/.claude-plugin/plugin.json`
- **Self-Verification:** Verify JSON is valid, count is accurate
- **Human QA:** None needed
- **Confidence Ceiling:** 95%

## Verification Plan

### Agent Self-Verification
- Read uw-investigate.md and verify:
  - Has YAML frontmatter with name, description, argument-hint
  - Has CRITICAL: Read-Only Mode section
  - Has STEP 0: Memory Recall
  - Contains goal transformation logic
  - Uses memory-aware-explore agent
  - Uses test-runner agent for hypothesis verification
  - Has temporary script handling with cleanup
  - Has memory retention at end
  - Matches structural patterns of other commands (uw-plan.md, uw-fix-ci.md)

### Human QA Checklist
- [ ] Review the goal transformation logic - does it handle edge cases well?
- [ ] Verify the temporary script cleanup is bulletproof
- [ ] Test with a real investigation scenario

## Spec Changelog
- 20-01-2026: Initial spec from interview
