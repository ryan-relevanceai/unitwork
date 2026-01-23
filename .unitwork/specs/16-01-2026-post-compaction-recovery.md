# Post-Compaction Context Recovery for uw:work

## Purpose & Impact
- **Why**: When Claude Code's context compacts during long /uw:work sessions, the agent loses recalled memories, spec details, and progress context - leading to confusion and inconsistent work
- **Who**: Any user running long implementation sessions with /uw:work
- **Success**: Agent automatically recognizes compaction occurred, re-fetches context in correct order (memories → spec → git status), and continues seamlessly with brief announcement

## Requirements

### Functional Requirements
- [ ] FR1: Agent recognizes when context starts with a compaction summary rather than the full STEP 0 sequence
- [ ] FR2: On recognition, agent executes recovery sequence: memory recall → spec re-read → git status → announcement
- [ ] FR3: Recovery announcement shows what was recovered (memories, spec name, progress)
- [ ] FR4: Agent continues from detected progress point without user intervention

### Non-Functional Requirements
- [ ] NFR1: Recovery should be fast - not block work for extended periods
- [ ] NFR2: Recovery should be idempotent - safe to run even if compaction didn't actually occur

### Out of Scope
- Preventing compaction (not controllable)
- Modifying Claude Code's compaction behavior
- Storing full context outside the conversation

## Technical Approach

### Detection Logic
The agent recognizes compaction by observing that the conversation starts with a summarized context rather than the original detailed STEP 0 sequence. Indicators include:
- Conversation beginning with a summary message (typically contains words like "summary", "compaction", or "context was summarized")
- Absence of the detailed "**Relevant Learnings from Memory:**" output from STEP 0
- Absence of detailed spec content that would have been read

This is prompt-based recognition, not programmatic detection. The agent naturally reads the conversation and identifies the pattern.

### Recovery Sequence
When compaction is recognized, execute in order:

1. **Memory Recall (FIRST)** - Most important, provides cross-cutting learnings
   ```bash
   hindsight memory recall "$BANK" "gotchas and learnings for <feature-type>" --budget mid --include-chunks
   ```

2. **Read Spec (SECOND)** - Provides requirements and unit breakdown
   - Check `.unitwork/specs/` for spec files
   - Use most recently modified, OR derive from current branch name if naming convention matches

3. **Git Status (THIRD)** - Provides progress context
   ```bash
   git log --oneline | grep "checkpoint(" | head -5
   git status --short
   ```

4. **Brief Announcement (FOURTH)** - Confirm recovery to user
   ```
   Context recovered after compaction:
   - Recalled {N} learnings from memory
   - Loaded spec: {spec-filename}
   - Progress: {N} checkpoints complete, working on Unit {X}
   Continuing...
   ```

### Key Files Affected
- `plugins/unitwork/commands/uw-work.md` - Add recovery section

## Implementation Units

### Unit 1: Add Context Recovery Section to uw-work.md
- **Changes:** Add new section "## Context Recovery (Post-Compaction)" to uw-work.md after Resume Detection, containing:
  - Recognition instructions explaining what compaction looks like
  - Recovery sequence with exact commands
  - Announcement format template
- **Self-Verification:** Read the file, confirm section exists with all required content
- **Human QA:**
  - [ ] Run a long /uw:work session until compaction occurs
  - [ ] Verify agent recognizes compaction and runs recovery
  - [ ] Verify announcement shows recovered context
- **Confidence Ceiling:** 85% (depends on real-world compaction behavior being as expected)

## Verification Plan

### Agent Self-Verification
- Read uw-work.md and verify:
  - New section exists after Resume Detection
  - Contains recognition instructions
  - Contains recovery sequence with memory recall → spec read → git status order
  - Contains announcement format
- Grep for key phrases to confirm presence

### Human QA Checklist
- [ ] Start a /uw:work session with a multi-unit spec
- [ ] Work until context compacts (or manually run /compact)
- [ ] Observe agent recognizes compaction
- [ ] Verify recovery sequence runs in correct order: memories FIRST, spec SECOND, git status THIRD
- [ ] Verify announcement shows recovered information
- [ ] Verify agent continues working on correct unit

## Spec Changelog
- 16-01-2026: Initial spec from interview
