# Changelog

All notable changes to the Unit Work plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
  - Required reading step loads reference files before review

- **Hindsight integration**: Fixed bank name derivation for git worktrees
  - Changed from `git rev-parse --show-toplevel` to `git config --get remote.origin.url`
  - All worktrees now share the same memory bank
  - Fallback chain: remote URL → main worktree name → directory name

- **uw-work**: Added mandatory checkpoint rules
  - CRITICAL: Never ask "would you like me to commit?" - just commit
  - All code changes get checkpointed, including follow-up fixes
  - Added "When to Checkpoint (Mandatory)" section

## [0.2.2] - 2026-01-14

### Changed

- **uw-work**: Added Context Recall section before implementation
  - Recalls gotchas and learnings from Hindsight at start of work
  - Surfaces actionable reminders (e.g., versioning rules) without requiring them in every spec
  - Ensures past mistakes inform current work automatically

## [0.2.1] - 2026-01-14

### Added

- **install_deps.sh**: New installation script for automated dependency setup
  - Checks prerequisites (Docker, Node.js 18+)
  - Installs Hindsight CLI (brew on macOS, curl on Linux)
  - Installs agent-browser via npm
  - Prints Docker container setup instructions

### Changed

- **README.md**: Enhanced Requirements section with clearer installation docs
  - Added Prerequisites section (Docker, Node.js 18+)
  - Restructured Hindsight setup into 3 clear steps
  - Changed Docker command to detached mode (-d) with named container
  - Added recommended presets (OpenRouter + Gemini 3 Flash)
  - Added container management commands (stop/start/logs)

- **learnings template**: Refactored to capture implementation journey rather than duplicate spec
  - Focus on gotchas, decisions, and advice for next time
  - Removed redundant requirements recap

## [0.2.0] - 2026-01-13

### Added

- **uw-pr**: New command to create or update GitHub PRs with AI-generated descriptions
  - Creates draft PRs with concise, well-formatted descriptions
  - Updates existing PR descriptions when new commits are pushed
  - Supports natural language arguments for target branch and extra context
  - Handles large diffs (>2000 lines) gracefully
  - Excludes codegen/generated files from diff analysis

### Changed

- **uw-plan**: Added strict read-only mode constraint
  - Planning phase now explicitly forbids editing any files
  - Only allowed to write spec file to `.unitwork/specs/`
  - Clear instructions to redirect users to `/uw:work` for implementation

## [0.1.1] - 2026-01-13

### Changed

- **uw-bootstrap**: Use Explore subagents (2 agents) for codebase exploration (preserves main thread context)
- **uw-plan**: Use Explore subagents (3 agents) for codebase exploration (preserves main thread context)
  - Agent 1: Feature-related code
  - Agent 2: Test patterns
  - Agent 3: Existing utilities (finds tested, reusable utilities for implementation)
- **uw-plan**: Enhanced interview phase with extensive question categories (implementation, edge cases, testing, dependencies, UI/UX)
- **uw-plan**: Added confidence gate - continue interviewing until high confidence in requirements

### Fixed

- **uw-bootstrap**: Fixed Hindsight `disposition` command - disposition is auto-inferred from background, not manually set
- **uw-plan**: Fixed Hindsight `recall` flag - use `--include-chunks` not `--include-entities`
- **decision-trees.md**: Fixed recall flag reference

### Removed

- **uw-bootstrap**: Removed .gitignore handling - `.unitwork/` is now always version controlled

## [0.1.0] - 2026-01-13

### Added

- Initial release of Unit Work plugin

#### Commands (6)
- `/uw:plan` - Interview user, explore codebase, create spec with implementation units
- `/uw:work` - Execute plan with checkpoints at verifiable boundaries
- `/uw:review` - Spawn 6 parallel review agents for exhaustive code review
- `/uw:compound` - Extract and store learnings to Hindsight + local files
- `/uw:bootstrap` - First-time setup: check deps, configure Hindsight, explore codebase
- `/uw:action-comments` - Bulk resolve GitHub PR comments

#### Agents (9)

Verification Agents:
- `test-runner` - Execute test suites and report structured results
- `api-prober` - Make API calls to verify endpoints (read-only unless permitted)
- `browser-automation` - UI verification via agent-browser

Review Agents:
- `type-safety` - Review for casting, guards, nullability issues
- `patterns-utilities` - Check for existing solutions and pattern violations
- `performance-database` - Find N+1 queries, missing indexes, parallelization opportunities
- `architecture` - Verify file locations, coupling, boundary adherence
- `security` - Scan for injection, auth bypasses, data exposure
- `simplicity` - Identify over-engineering and YAGNI violations

#### Skills (1)
- `unitwork` - Core skill with philosophy, decision trees, and templates

#### Templates
- Spec template for feature specifications
- Verify template for checkpoint verification documents
- Learnings template for compound phase output

#### Documentation
- README with full component documentation
- CLAUDE.md with development guidelines
- Decision trees reference for key workflows
