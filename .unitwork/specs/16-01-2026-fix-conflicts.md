# uw:fix-conflicts Command

## Purpose & Impact
- Autonomously rebase current branch onto the default branch with intelligent conflict resolution
- Use multi-agent analysis (intent + impact) to understand what each branch was trying to achieve
- Leverage Hindsight memory for context about conflicted files
- Interview user when agent confidence is low or intent is muddied

## Requirements

### Functional Requirements
- [ ] FR1: Detect default branch via `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`
- [ ] FR2: Fetch latest changes with `git fetch origin` (no pull, use origin/branch directly)
- [ ] FR3: Handle pre-rebase states:
  - Dirty working tree → offer to stash changes first
  - Existing rebase in progress → offer to abort or continue
- [ ] FR4: Execute `git rebase origin/{default-branch}`
- [ ] FR5: For each conflict, spawn analysis agents in parallel:
  - **Intent Analyst**: Understand what each branch was trying to achieve
  - **Impact Explorer**: Analyze test impacts, downstream dependencies, behavior changes
- [ ] FR6: Coordinating logic reviews findings and proposes resolution
- [ ] FR7: Auto-resolve if agent confidence >80%, otherwise interview user
- [ ] FR8: If Intent Analyst reports conflicting goals AND independent verification confirms semantic conflict → always interview user
- [ ] FR9: After each conflict resolution, run `test-runner` agent for affected files
- [ ] FR10: If verification fails → ask user (1 attempt limit per conflict)
- [ ] FR11: After each `git rebase --continue` succeeds, create verification document

### Non-Functional Requirements
- [ ] NFR1: Memory recall before starting (past conflict patterns, file context)
- [ ] NFR2: Memory retain after completion (successful resolution approaches)
- [ ] NFR3: Follow existing checkpoint format from `checkpointing.md`
- [ ] NFR4: Use existing `test-runner` agent (don't reimplement)
- [ ] NFR5: Follow `interview-workflow.md` patterns for user questions

### Out of Scope
- Interactive rebase (pick/squash/edit commits)
- Merge-based conflict resolution (rebase only)
- Cherry-pick workflows
- Rebasing onto non-default branches (future enhancement)

## Technical Approach

### Command Structure
Follow `uw-fix-ci.md` as template:
1. YAML frontmatter with name, description, argument-hint
2. Mandatory memory recall (Step 0)
3. Pre-flight checks (dirty tree, existing rebase)
4. Main rebase loop with conflict handling
5. Cycle limits with user escalation
6. Memory retain on completion

### Agent Architecture
New agents in `plugins/unitwork/agents/conflict-resolution/`:

**conflict-intent-analyst.md**
- Reads git history for current branch (`git log origin/{default}..HEAD`)
- Reads git history for incoming changes (`git log HEAD..origin/{default}` relevant to conflicted files)
- Outputs: ours_intent, theirs_intent, conflicting_goals (boolean), confidence (0-100)

**conflict-impact-explorer.md**
- Identifies tests covering conflicted files (spawn `test-runner` in discovery mode)
- Finds downstream dependencies of changed functions/types
- Analyzes behavior changes from each resolution option
- Outputs: affected_tests, downstream_files, behavior_changes, resolution_recommendations

### Rebase State Machine
```
START
  |
  +-- git fetch origin
  |
  +-- Check pre-rebase state
  |     |
  |     +-- Dirty tree? -> Offer stash
  |     +-- Existing rebase? -> Offer abort/continue
  |
  +-- git rebase origin/{default-branch}
  |
  +-- LOOP: While rebase in progress
  |     |
  |     +-- Conflict detected?
  |     |     |
  |     |     +-- Spawn Intent Analyst + Impact Explorer (parallel)
  |     |     +-- Synthesize findings, calculate confidence
  |     |     +-- Confidence >80% AND no conflicting_goals? -> Auto-resolve
  |     |     +-- Otherwise -> Interview user
  |     |     +-- Apply resolution (edit conflict markers)
  |     |     +-- git add {resolved files}
  |     |     +-- Run test-runner for affected files
  |     |     +-- Tests pass? -> Continue
  |     |     +-- Tests fail? -> Ask user (1 attempt limit)
  |     |
  |     +-- git rebase --continue
  |     +-- Create verification document
  |
  +-- Rebase complete
  |
  +-- Memory retain (successful patterns)
  |
END
```

### Conflict Detection
```bash
# Check if in rebase state
if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ]; then
  # In rebase state
fi

# List conflicted files
git diff --name-only --diff-filter=U

# Check for conflict markers
grep -l "^<<<<<<<" {files}
```

### Confidence Calculation
Start at 100%, subtract:
- -20% if Intent Analyst reports conflicting_goals
- -15% if Impact Explorer finds >5 downstream dependencies
- -10% if no tests cover the conflicted code
- -10% per unresolved behavioral question

Threshold: >80% = auto-resolve, <=80% = interview user

### Integration Points
- `hindsight memory recall` - Context about conflicted files
- `Task tool with subagent_type="unitwork:verification:test-runner"` - Run affected tests
- `AskUserQuestion` - User decisions for low-confidence conflicts
- `hindsight memory retain` - Store successful resolution patterns

## Implementation Units

### Unit 1: Create command file structure
- **Changes:** New `plugins/unitwork/commands/uw-fix-conflicts.md` with YAML frontmatter
- **Self-Verification:** File exists, frontmatter parses correctly
- **Human QA:** Command appears in `/help`, can be invoked
- **Confidence Ceiling:** 95%

### Unit 2: Implement pre-rebase checks
- **Changes:** Sections in command for:
  - Default branch detection
  - `git fetch origin`
  - Dirty tree detection (`git status --porcelain`) + stash offer
  - Existing rebase detection (`.git/rebase-merge` or `.git/rebase-apply`) + abort/continue offer
- **Self-Verification:** Test each scenario manually (dirty tree, existing rebase, clean state)
- **Human QA:** Verify prompts are clear and handle edge cases
- **Confidence Ceiling:** 90%

### Unit 3: Create conflict-intent-analyst agent
- **Changes:** New `plugins/unitwork/agents/conflict-resolution/conflict-intent-analyst.md`
- **Self-Verification:** Agent can be spawned via Task tool, produces output with expected fields
- **Human QA:** Verify analysis quality on a sample conflict
- **Confidence Ceiling:** 75%

### Unit 4: Create conflict-impact-explorer agent
- **Changes:** New `plugins/unitwork/agents/conflict-resolution/conflict-impact-explorer.md`
- **Self-Verification:** Agent identifies tests and dependencies correctly
- **Human QA:** Verify comprehensive impact analysis
- **Confidence Ceiling:** 70%

### Unit 5: Implement rebase loop with agent coordination
- **Changes:** Main command loop:
  - Spawn both agents in parallel (single message, multiple Task tool calls)
  - Collect outputs, synthesize findings
  - Calculate confidence
  - Route to auto-resolve or interview based on confidence
- **Self-Verification:** Test with mock conflict scenario
- **Human QA:** Verify confidence thresholds work correctly
- **Confidence Ceiling:** 70%

### Unit 6: Implement interview flow for low-confidence conflicts
- **Changes:** AskUserQuestion patterns:
  - Present both versions with agent analysis
  - Options: Keep ours, Keep theirs, Merge both, Let me resolve manually
  - Handle muddied intent (conflicting_goals + semantic verification)
- **Self-Verification:** Verify question options are clear
- **Human QA:** Test interview flow with real conflict
- **Confidence Ceiling:** 85%

### Unit 7: Implement verification and checkpointing
- **Changes:**
  - Spawn `test-runner` agent after each resolution
  - Create verification documents at `.unitwork/verify/{DD-MM-YYYY}-conflict-{n}.md`
  - Handle test failures (ask user, 1 attempt limit)
- **Self-Verification:** Verification document created, tests run
- **Human QA:** Verify rollback capability works
- **Confidence Ceiling:** 85%

### Unit 8: Plugin versioning and documentation
- **Changes:**
  - Bump version in `.claude-plugin/plugin.json` (MINOR: new command + new agents)
  - Update `CHANGELOG.md`
  - Update `README.md` component counts
- **Self-Verification:** Version bumped, changelog entry exists
- **Human QA:** Verify documentation is accurate
- **Confidence Ceiling:** 95%

## Verification Plan

### Agent Self-Verification
- Pre-rebase checks: Each detection scenario tested
- Agents: Can be spawned, produce expected output structure
- Rebase loop: Handles single-conflict and multi-conflict scenarios
- Interview: AskUserQuestion works correctly
- Verification: test-runner runs, documents created

### Human QA Checklist
- [ ] Create a branch with intentional conflict
- [ ] Run `/uw:fix-conflicts`
- [ ] Verify default branch detection works
- [ ] Verify pre-rebase checks catch dirty tree
- [ ] Verify Intent Analyst produces useful analysis
- [ ] Verify Impact Explorer finds tests and dependencies
- [ ] Verify auto-resolution works for high-confidence conflicts
- [ ] Verify interview triggers for low-confidence/muddied conflicts
- [ ] Verify tests run after resolution
- [ ] Verify checkpoint documents created
- [ ] Verify memory retain captures patterns

## Spec Changelog
- 16-01-2026: Initial spec from interview
  - Multi-agent approach (Intent + Impact)
  - Synthesis coordination model
  - Confidence threshold (80%) for auto-resolution
  - 1-attempt limit per conflict
  - Rebase state machine documented
