# Changelog

All notable changes to the Unit Work plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
