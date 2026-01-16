# Changelog

All notable changes to the Unit Work plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.2] - 2026-01-16

### Added

- **hindsight-reference.md**: New reference document for Hindsight memory operations
  - Worktree-safe bank name derivation (uses remote origin URL)
  - ANSI color code stripping for programmatic output processing
  - Complete patterns for recall, retain, and reflect operations
  - Error handling and graceful degradation guidance
  - Context and doc-id conventions table

### Changed

- **memory-validation.md**: Added explicit Hindsight bash commands
  - References hindsight-reference.md for complete patterns
  - Includes ANSI stripping in recall command
  - Step-by-step instructions for bank name, recall, and error handling

- **SKILL.md**: Updated Hindsight Integration section
  - References hindsight-reference.md for complete patterns
  - Quick reference with ANSI stripping example

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
