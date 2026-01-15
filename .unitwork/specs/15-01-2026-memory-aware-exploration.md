# Memory-Aware Exploration Agent

## Purpose & Impact

**Why this feature exists:**
Currently, Explore agents perform codebase exploration without leveraging Hindsight memory. Each session repeats the same exploration work - finding auth code, locating models, discovering test patterns. This is wasteful because:
1. Exploration results aren't retained to memory
2. No recall of past explorations happens before exploring
3. Traversal strategies (how to find things) are lost between sessions

**Who it helps:**
- Users who work across multiple sessions on the same codebase
- Agents that need to understand unfamiliar code areas
- Any workflow that spawns Explore subagents (uw-plan, uw-bootstrap)

**What success looks like:**
- First exploration of "auth code" documents findings to memory
- Second exploration of similar area starts with memory recall, validates key files still exist, and extends findings
- Exploration time reduced on subsequent sessions
- Traversal strategies documented ("auth is in /src/auth, discovered via grep for 'authenticate'")

---

## Requirements

### Functional Requirements
- [ ] FR1: Create new `memory-aware-explore` agent in `plugins/unitwork/agents/exploration/`
- [ ] FR2: Agent performs memory recall before exploration with feature-specific query
- [ ] FR3: Agent validates recalled file locations still exist (medium trust - verify key files, not all)
- [ ] FR4: Agent extends findings with newly discovered items
- [ ] FR5: Agent retains summarized findings at end of exploration (not during)
- [ ] FR6: Retained findings include both file locations AND traversal strategy (how to find similar things)
- [ ] FR7: Update uw-plan.md to use `unitwork:exploration:memory-aware-explore` instead of `Explore`
- [ ] FR8: Update uw-bootstrap.md to use `unitwork:exploration:memory-aware-explore` instead of `Explore`

### Non-Functional Requirements
- [ ] NFR1: Memory operations should not significantly slow exploration (use `--async` for retain)
- [ ] NFR2: Agent should work gracefully if Hindsight is not configured (proceed with warning, skip retain)

### Out of Scope
- Modifying the base Explore subagent_type (it's a system type)
- Adding memory to plan-review agents (separate feature)
- Real-time memory updates during exploration (only at end)

---

## Technical Approach

### Architecture
The memory-aware-explore agent is a custom subagent that:
1. Takes an exploration prompt with feature context
2. Performs memory recall at start to get prior exploration results
3. Validates key recalled locations still exist (medium trust)
4. Explores the codebase using standard tools (Glob, Grep, Read)
5. Synthesizes findings including both recalled and new discoveries
6. Retains summarized findings to Hindsight at end

### Agent Invocation
Custom agents in `plugins/unitwork/agents/exploration/memory-aware-explore.md` become available as:
```
subagent_type="unitwork:exploration:memory-aware-explore"
```

### Key Files to Create/Modify
1. **NEW:** `plugins/unitwork/agents/exploration/memory-aware-explore.md` - The agent definition
2. **MODIFY:** `plugins/unitwork/commands/uw-plan.md` - Replace `Explore` with `unitwork:exploration:memory-aware-explore`
3. **MODIFY:** `plugins/unitwork/commands/uw-bootstrap.md` - Replace `Explore` with `unitwork:exploration:memory-aware-explore`
4. **MODIFY:** `plugins/unitwork/.claude-plugin/plugin.json` - Update agent count (12 → 13)
5. **MODIFY:** `plugins/unitwork/CLAUDE.md` - Document new agents/exploration/ directory

### Memory Context Labels
- **Context pattern:** `exploration: <feature-type>` (e.g., "exploration: authentication code")
- **Doc-ID pattern:** `explore-<feature-type>` (e.g., "explore-auth")

### Validation Strategy (Medium Trust)
When recalled memory says "auth code is at /src/auth/middleware.ts":
1. Use Glob to verify the file exists
2. If exists: Include in findings with "verified" status
3. If missing: Note as "stale" and explore to find current location
4. Report staleness percentage in final summary

### Graceful Degradation (NFR2)
If `hindsight` command fails or is not found:
1. Log warning: "Hindsight not available - proceeding without memory"
2. Skip recall step, proceed with standard exploration
3. Skip retain step at end
4. Still produce useful exploration results

---

## Implementation Units

### Unit 1: Create memory-aware-explore agent definition
**Changes:** Create `plugins/unitwork/agents/exploration/memory-aware-explore.md`

**Agent Structure:**
```markdown
---
name: memory-aware-explore
description: "Use this agent for codebase exploration with memory integration..."
model: inherit
---

[Agent instructions for memory-aware exploration]
```

**Self-Verification:**
- Read the file, verify YAML frontmatter has name, description, model fields
- Verify file is in correct location (`agents/exploration/`)

**Human QA:**
- Review agent instructions for clarity
- Verify memory recall query format is sensible
- Check retain format captures traversal strategy

**Confidence Ceiling:** 95%

---

### Unit 2: Update uw-plan.md to use memory-aware-explore
**Changes:** Modify `plugins/unitwork/commands/uw-plan.md` - replace 3 Explore agent spawns

**Before:**
```markdown
Task tool with subagent_type="Explore"
prompt: "Explore this codebase to find..."
```

**After:**
```markdown
Task tool with subagent_type="unitwork:exploration:memory-aware-explore"
prompt: "Feature context: <feature_description>
Explore this codebase to find..."
```

**Self-Verification:**
- Grep for `unitwork:exploration:memory-aware-explore` in uw-plan.md
- Verify count is 3 (Agent 1, Agent 2, Agent 3)
- Verify no remaining `subagent_type="Explore"` references

**Human QA:**
- Review prompt formatting
- Verify feature context is passed correctly

**Confidence Ceiling:** 95%

---

### Unit 3: Update uw-bootstrap.md to use memory-aware-explore
**Changes:** Modify `plugins/unitwork/commands/uw-bootstrap.md` - replace Explore agent spawns

**Self-Verification:**
- Grep for `unitwork:exploration:memory-aware-explore` in uw-bootstrap.md
- Verify all Explore usages are replaced

**Human QA:**
- Review prompt formatting
- Verify bootstrap context is passed correctly

**Confidence Ceiling:** 95%

---

### Unit 4: Update plugin.json and CLAUDE.md
**Changes:**
1. Update `plugins/unitwork/.claude-plugin/plugin.json` agent count: "12 agents" → "13 agents"
2. Update `plugins/unitwork/CLAUDE.md` to document new `agents/exploration/` directory

**Self-Verification:**
- Count actual agent files: `ls plugins/unitwork/agents/**/*.md | wc -l`
- Verify count matches plugin.json description
- Verify CLAUDE.md mentions exploration directory

**Human QA:** None needed (mechanical)

**Confidence Ceiling:** 100%

---

## Verification Plan

### Agent Self-Verification
- [ ] Agent file exists at correct path and has valid YAML frontmatter
- [ ] uw-plan.md uses `unitwork:exploration:memory-aware-explore` (grep)
- [ ] uw-bootstrap.md uses `unitwork:exploration:memory-aware-explore` (grep)
- [ ] plugin.json agent count matches actual file count
- [ ] CLAUDE.md documents exploration directory

### Human QA Checklist
- [ ] Review agent instructions in memory-aware-explore.md
- [ ] Verify memory recall query format is sensible for codebase exploration
- [ ] Check retain format captures both file locations AND traversal strategy
- [ ] Test exploration in a fresh session to verify memory recall works
- [ ] Test exploration after prior session to verify findings are recalled

---

## Important Notes (from Hindsight)
- Plugin description counts drift from reality - verify counts after adding agent
- Use `git config --get remote.origin.url` for bank name (handles worktrees)
- Use `--async` for retain to avoid blocking
- Follow existing agent format pattern from `agents/review/*.md`

---

## Spec Changelog
- 15-01-2026: Initial spec from interview
  - Architecture: Custom agent in `agents/exploration/`
  - Trust level: Medium (validate key files, not all)
  - Retain timing: End of exploration only
  - Context labels: Feature-specific ("exploration: <type>")
