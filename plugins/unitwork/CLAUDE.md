# Unit Work Plugin Development

## Versioning Requirements

Every change to this plugin MUST include updates to:

1. **`.claude-plugin/plugin.json`** - Bump version using semver
2. **`CHANGELOG.md`** - Document changes using Keep a Changelog format
3. **`README.md`** - Verify/update component counts and tables

### Version Bumping Rules

- **MAJOR** (1.0.0 -> 2.0.0): Breaking changes, major reorganization
- **MINOR** (0.1.0 -> 0.2.0): New agents, commands, or skills
- **PATCH** (0.1.0 -> 0.1.1): Bug fixes, doc updates, minor improvements

### Pre-Commit Checklist

- [ ] Version bumped in `.claude-plugin/plugin.json`
- [ ] CHANGELOG.md updated with changes
- [ ] README.md component counts verified
- [ ] plugin.json description matches current counts

## Directory Structure

```
unitwork/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata
├── agents/
│   ├── conflict-resolution/     # Rebase conflict analysis
│   │   ├── conflict-intent-analyst.md
│   │   └── conflict-impact-explorer.md
│   ├── exploration/             # Memory-aware codebase exploration
│   │   └── memory-aware-explore.md
│   ├── plan-review/             # Plan validation specialists
│   │   ├── feasibility-validator.md
│   │   ├── gap-detector.md
│   │   └── utility-pattern-auditor.md
│   ├── verification/            # Verification subagents
│   │   ├── test-runner.md
│   │   └── api-prober.md
│   └── review/                  # Code review specialists
│       ├── type-safety.md
│       ├── patterns-utilities.md
│       ├── performance-database.md
│       ├── architecture.md
│       ├── security.md
│       ├── simplicity.md
│       └── memory-validation.md
├── commands/                    # Slash commands (12)
│   ├── uw-plan.md
│   ├── uw-work.md
│   ├── uw-review.md
│   ├── uw-compound.md
│   ├── uw-bootstrap.md
│   ├── uw-pr.md
│   ├── uw-action-comments.md
│   ├── uw-fix-ci.md
│   ├── uw-fix-conflicts.md
│   ├── uw-investigate.md
│   ├── uw-browser-test.md
│   └── uw-harvest.md
├── skills/
│   ├── review-standards/
│   │   └── ...
│   └── unitwork/
│       ├── SKILL.md
│       ├── references/
│       │   ├── checkpointing.md
│       │   ├── decision-trees.md
│       │   ├── hindsight-reference.md
│       │   ├── interview-workflow.md
│       │   └── verification-flow.md
│       └── templates/
│           ├── spec.md
│           ├── verify.md
│           └── learnings.md
├── README.md
├── CLAUDE.md
├── CHANGELOG.md
└── LICENSE
```

## Command Naming Convention

Commands use `uw:` prefix to namespace all Unit Work commands:
- `/uw:plan` - Planning phase
- `/uw:work` - Implementation phase (with self-correcting review cycles)
- `/uw:review` - Review phase
- `/uw:compound` - Learning extraction
- `/uw:bootstrap` - First-time setup
- `/uw:pr` - Create/update GitHub PRs
- `/uw:action-comments` - PR comment resolution
- `/uw:fix-ci` - Autonomously fix failing CI
- `/uw:fix-conflicts` - Intelligent rebase conflict resolution
- `/uw:investigate` - Read-only codebase investigation
- `/uw:browser-test` - Browser automation for UI verification
- `/uw:harvest` - Scrape PR review insights from GitHub repos into Hindsight

## Agent Organization

Agents are organized by purpose:

### exploration/
Memory-aware codebase exploration for `/uw:plan` and `/uw:bootstrap`:
- `memory-aware-explore.md` - Explore with Hindsight memory integration

### plan-review/
Plan validation specialists for `/uw:plan`:
- `feasibility-validator.md` - Validate implementation feasibility
- `gap-detector.md` - Detect gaps in plan coverage
- `utility-pattern-auditor.md` - Audit for reusable patterns

### conflict-resolution/
Conflict analysis agents for `/uw:fix-conflicts`:
- `conflict-intent-analyst.md` - Analyze intent behind each branch's changes
- `conflict-impact-explorer.md` - Assess downstream impact of resolutions

### verification/
Subagents for automated verification during `/uw:work`:
- `test-runner.md` - Execute tests
- `api-prober.md` - Probe API endpoints

**Note:** UI verification is now handled by the `/uw:browser-test` command instead of a subagent.

### review/
Parallel specialists for `/uw:review`:
- `type-safety.md`
- `patterns-utilities.md`
- `performance-database.md`
- `architecture.md`
- `security.md`
- `simplicity.md`
- `memory-validation.md`

## Skill Compliance

The unitwork skill must follow these requirements:

### YAML Frontmatter

- [ ] `name:` matches directory name (lowercase)
- [ ] `description:` uses third person ("This skill should be used...")

### Reference Links

- [ ] All files in `references/` are linked as `[filename.md](./references/filename.md)`
- [ ] All files in `templates/` are linked as `[filename.md](./templates/filename.md)`
- [ ] No bare backtick references

## Key Concepts

### Checkpoint-Based Development

Work is divided into verifiable units. Each unit:
1. Has clear success criteria
2. Can be independently tested
3. Results in a checkpoint commit with verification document

### Confidence Assessment

Confidence determines whether to continue or pause:
- >= 95%: Continue to next unit
- < 95%: Pause for human review

### Hindsight Integration

Memory operations:
- **recall**: Retrieve relevant context (cheap, use freely)
- **retain**: Store learnings (expensive, always async)
- **reflect**: Reason about decisions (uses disposition)

### Verification Subagents

Two specialized agents + one command for verification:
1. **test-runner**: Execute and parse tests
2. **api-prober**: Make API calls (read-only safe)
3. **/uw:browser-test** (command): UI verification with screenshots

### Review Agents

Seven parallel specialists for code review:
1. Type Safety
2. Patterns & Utilities
3. Performance & Database
4. Architecture
5. Security
6. Simplicity
7. Memory Validation

## Testing Changes

Test locally before committing:

```bash
# Install the plugin
claude /plugin marketplace add /path/to/project_unitwork
claude /plugin install unitwork

# Test commands
/uw:bootstrap
/uw:plan "test feature"
```

## Commit Conventions

Include the Claude Code footer:

```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```
