# Changelog

All notable changes to the Unit Work plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
