# Changelog

All notable changes to the Unit Work plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.12.0] - 2026-02-26

### Added

- **uw:momentic**: New command for Momentic E2E testing integration
  - Run existing Momentic test suites with video recording
  - Create new test YAMLs following Momentic schema conventions
  - Debug failing tests by analyzing results, screenshots, and console logs
  - Upload results to Momentic Cloud
  - List available tests across project
  - Manages Momentic app server lifecycle and Chromium process cleanup

## [0.11.0] - 2026-02-16

### Added

- **uw:park**: Park current work session with full context to a GitHub PR comment for multi-device handoff
  - Commits uncommitted changes with "park: WIP" prefix
  - Creates draft PR if none exists, or uses existing PR
  - Posts structured parking comment with progress, next steps, blockers
  - Machine-readable `<!-- uw:park -->` marker for round-trip parsing
- **uw:resume**: Resume a parked work session by reading PR parking comments and local artifacts
  - Finds latest parking comment on current branch's PR
  - Reads local `.unitwork/` artifacts (specs, verify, review)
  - Presents synthesized context summary with discrepancy detection
  - Suggests appropriate next action based on parked state

## [0.10.0] - 2026-02-02

### Added

- **uw:harvest**: New command to scrape PR review insights from GitHub repos
  - Accepts one or more `owner/repo` arguments
  - Fetches merged PRs from previous business day using GitHub Search API
  - Collects inline review comments and review bodies per PR
  - Filters out bot comments and trivial feedback (<20 chars)
  - Synthesizes comments into actionable insights across 5 categories
  - Stores insights into each source repo's Hindsight bank
  - Optional `--since YYYY-MM-DD` override for custom date ranges

### Changed

- **plugin.json**: Updated version (0.9.0 → 0.10.0), command count (11 → 12)
- **CLAUDE.md**: Added uw-harvest to directory structure and command naming list
- **README.md**: Added uw:harvest to commands table with detailed description, fixed command count (9 → 12)

## [0.7.2] - 2026-01-20

### Added

- **uw:investigate**: New read-only investigation command
  - Deep codebase exploration without modifying production code
  - Goal transformation converts write-oriented tasks to investigation form
  - Memory-aware exploration with Hindsight integration
  - Hypothesis verification via test-runner and temporary scripts
  - Bulletproof temp script cleanup in `/tmp/uw-investigate-*/`
  - In-conversation summary output (no file artifacts)

### Changed

- **plugin.json**: Updated command count (9 → 10)

## [0.7.1] - 2026-01-16

### Added

- **uw-bootstrap.md**: Team learnings import capability
  - Detect existing setup (.unitwork dir or Hindsight bank) and offer sync-only mode
  - Filter learnings by git author to import only team content
  - Track last import timestamp in `.unitwork/.bootstrap.json` for incremental imports
  - Validate bank names against safe character set (security hardening)
  - Uses `hindsight memory retain-files` with `--async` for bulk import

### Changed

- **uw-bootstrap.md**: Simplified learnings directory check using bash glob vs find

## [0.7.0] - 2026-01-16

### Added

- **uw:fix-conflicts**: New command for intelligent conflict resolution during rebase
  - Detects default branch via `gh` CLI with fallbacks
  - Pre-rebase checks: dirty tree (stash offer), existing rebase (abort/continue)
  - Multi-agent analysis spawns Intent Analyst + Impact Explorer in parallel
  - Confidence-based auto-resolution (>80% → auto, ≤80% → interview user)
  - Test verification after each resolution via test-runner agent
  - Verification documents at `.unitwork/verify/{date}-conflict-resolution.md`
  - Cycle limits: 10 conflicts max, 5 interviews per session

- **conflict-intent-analyst.md**: New agent for understanding branch intents
  - Reads git history for both branches touching conflicted files
  - Determines if goals are parallel (can merge) or conflicting (need decision)
  - Outputs: ours_intent, theirs_intent, conflicting_goals, confidence

- **conflict-impact-explorer.md**: New agent for analyzing resolution impact
  - Identifies test coverage for conflicted files
  - Maps downstream dependencies
  - Analyzes behavior changes for each resolution option
  - Outputs: affected_tests, downstream_files, behavior_changes, recommendations

### Changed

- **plugin.json**: Updated counts (14→16 agents, 8→9 commands)

## [0.6.0] - 2026-01-16

### Added

- **memory-validation.md**: New review agent (14 agents total)
  - Validates code against ALL team learnings from Hindsight memory
  - Severity inherits from learning context (production bug → P1, convention → P2)
  - Graceful degradation when Hindsight unavailable
  - Spawned as 7th parallel agent in uw-review

- **interview-workflow.md**: New reference document for interview protocols
  - Confidence-based depth (high/medium/low → minimal/standard/comprehensive)
  - Stop conditions: no P1/P2 gaps remaining
  - 5 question categories with AskUserQuestion patterns
  - Reusable from uw-plan, uw-work, uw-review

- **verification-flow.md**: New reference document consolidating verification protocols
  - Decision tree for which verification subagent to use
  - Confidence calculation rules
  - Self-correcting review protocol for fix checkpoints

- **hindsight-reference.md**: New reference document for Hindsight memory operations
  - Worktree-safe bank name derivation (uses remote origin URL)
  - ANSI color code stripping for programmatic output processing
  - Complete patterns for recall, retain, and reflect operations
  - Error handling and graceful degradation guidance

### Changed

- **uw-plan.md**: Interview workflow integration
  - Phase 2 Interview references interview-workflow.md
  - Retains 6 interview rules inline for compliance

- **uw-work.md**: Interview loop and minimal plan-verify
  - Step 0.5: Interview loop when gap-detector finds P1/P2 gaps
  - Re-runs gap-detector after interview to validate gaps addressed
  - Minimal plan-verify step before implementation

- **uw-review.md**: Interview trigger and memory-validation
  - Auto-detects current PR from git branch
  - Interview trigger in fix loop (before Context7 research)
  - Spawns 7 review agents (added memory-validation)
  - Memory routing: memory-validation receives ALL memories

- **uw-action-comments.md**: Aligned with plan/work flow
  - Uses same checkpoint workflow as uw-work
  - Self-correcting review after fix checkpoints

- **SKILL.md**: Updated references and Hindsight integration
  - Links to interview-workflow.md, verification-flow.md, hindsight-reference.md
  - Quick reference with ANSI stripping example
  - Command list now shows all 8 commands

- **plugin.json**: Agent count 13→14

### Fixed

- **install_deps.sh**: Fixed broken agent-browser installation
  - Changed package from non-existent `@anthropic/agent-browser` to `agent-browser`
  - Added `--with-deps` flag for Linux to install browser system dependencies
  - Added architecture detection for macOS Hindsight CLI download (arm64 vs amd64)

- **README.md**: Fixed installation documentation
  - Corrected agent-browser npm package name
  - Added Linux note for `--with-deps` flag

## [0.5.1] - 2026-01-15

### Changed

- **README**: Comprehensive audit and workflow documentation
  - Updated component counts (12→13 agents, 7→8 commands, 1→2 skills)
  - Expanded workflow diagram showing all 8 commands including feedback loops
  - Added detailed workflow documentation for all commands (phases + compounding notes)
  - Added "How Unit Work Compounds" section explaining the learning loop
  - Added Exploration Agents section with memory-aware-explore
  - Added review-standards skill with link to issue patterns

## [0.5.0] - 2026-01-15

### Added

- **checkpointing.md**: New consolidated reference document for checkpoint protocols
  - Single source of truth for checkpoint commit format
  - PR comment fix numbering: `checkpoint(pr-{PR}-{n})`
  - Self-correcting review protocol (risk assessment, selective agents, cycle limits)
  - References to decision-trees.md and templates/verify.md

### Changed

- **uw-action-comments**: Aligned with full Unit Work checkpoint workflow
  - Added STEP 0: Memory Recall (mandatory)
  - Per-fix checkpointing with `checkpoint(pr-{PR}-{n})` format
  - Self-correcting review after each fix checkpoint
  - Compound phase prompt at end (user chooses whether to run /uw:compound)

- **uw-work.md**: Reduced duplication by referencing checkpointing.md
  - Removed ~120 lines of inline checkpoint/verification content
  - References checkpointing.md for protocol details

- **SKILL.md**: Consolidated checkpoint section
  - "Checkpoint Commit Format" → "Checkpoint Protocol"
  - References checkpointing.md and related docs

## [0.4.0] - 2026-01-15

### Added

- **uw-fix-ci**: New command to autonomously fix failing CI
  - Requires existing PR (fail-fast if no PR)
  - Cycles: analyze failure → fix → commit → push → wait for CI → repeat
  - Limited workflow parsing (extracts `run:` steps only)
  - Local verification for standard package managers (npm/yarn/pnpm/pip/cargo/go)
  - Polling-based CI monitoring (30s intervals, 15min timeout)
  - Hard limit: 5 cycles, stops on 3 consecutive same errors
  - Gap collection presents all missing info together

- **Self-correcting review cycles**: Fix checkpoints in uw-work now trigger automatic re-review
  - Risk assessment determines review intensity (no review / light / full)
  - Selective agent spawning based on fix type (matches Re-Review Protocol)
  - Scope-guard prevents review agents from suggesting additional refactoring
  - Hard limit: 3 cycles per fix

## [0.3.0] - 2026-01-15

### Added

- **memory-aware-explore**: New exploration agent with Hindsight memory integration
  - Recalls prior exploration findings before exploring
  - Validates key recalled file locations (medium trust)
  - Retains summarized findings including traversal strategies
  - Graceful degradation when Hindsight unavailable

### Changed

- **uw-plan**: Replaced `Explore` with `unitwork:exploration:memory-aware-explore` (3 agents)
  - Exploration findings now compound across sessions
  - Added feature context to each exploration prompt

- **uw-bootstrap**: Replaced `Explore` with `unitwork:exploration:memory-aware-explore` (2 agents)
  - Bootstrap exploration now retained to memory
  - Added feature context ("codebase architecture", "testing and utilities")

## [0.2.7] - 2026-01-14

### Changed

- **Verification documents**: Added "AI-Verified (100% Confidence)" section to template
  - Agent verifies items it can confirm with certainty (grep, read, test output)
  - Human QA Checklist reserved for items genuinely requiring human judgment
  - Follows "minimal human review" philosophy - don't waste human time on verifiable items

## [0.2.6] - 2026-01-14

### Changed

- **uw-work, uw-review, uw-plan**: Made memory recall STEP 0 (mandatory first action)
  - Added visual separators and CRITICAL callouts
  - Added failure mode examples explaining what goes wrong when skipped
  - Added "DO NOT PROCEED" language to enforce execution
  - Ensures agents never skip the foundation of compounding

- **SKILL.md**: Added memory as core principle
  - New Core Philosophy principle: "NEVER skip memory recall"
  - New Memory Rule 0: "NEVER skip memory recall at session start"

## [0.2.5] - 2026-01-14

### Changed

- **review-standards**: Migrated from `standards/` directory to skill-based architecture
  - Created `review-standards` skill with `references/` subdirectory
  - Fixes path resolution failures when plugin runs from Claude's cache directory
  - Updated uw-review command and all 6 review agents to load skill instead of hardcoded paths

### Removed

- **standards/**: Directory deleted (files moved to `skills/review-standards/references/`)

## [0.2.4] - 2026-01-14

### Changed

- **uw-review**: Added Context Recall section before review
  - Recalls past review learnings and mistakes from Hindsight before spawning agents
  - Routes domain-specific memories to appropriate agents (e.g., type safety learnings → type-safety agent)
  - Ensures past mistakes inform current reviews without relying on agent knowledge alone

## [0.2.3] - 2026-01-14

### Added

- **standards/**: New taxonomy reference files for code review
  - `issue-patterns.md`: 47 issue patterns with frequency data, detection criteria, and fixes
  - `review-standards.md`: Language-agnostic best practices (type safety, null handling, etc.)
  - `checklists.md`: Pre/during/post implementation checklists

### Changed

- **uw-review**: Enhanced with taxonomy-based findings and tier system
  - Multi-origin support: branch diff (default), PR number, codebase area audit
  - Tier-based severity: Tier 1 (Correctness) always outranks Tier 2 (Cleanliness)
  - Review agents reference issue patterns taxonomy
