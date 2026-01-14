# Mandatory Memory Recall Enhancement

## Purpose & Impact
- **Why:** Memory recall is the foundation of compounding, but agents skip it because it's not prominent enough
- **Who:** All agents executing /uw:work, /uw:review, /uw:plan commands
- **Success:** Agents NEVER skip memory recall - it becomes impossible to miss

## Requirements

### Functional Requirements
- [ ] FR1: Memory recall must be STEP 0 in /uw:work (before resume detection)
- [ ] FR2: Memory recall must be STEP 0 in /uw:review (before Required Reading)
- [ ] FR3: Memory recall must be STEP 0 in /uw:plan (strengthened with same treatment)
- [ ] FR4: SKILL.md must establish memory as non-negotiable core principle
- [ ] FR5: All memory sections must use visual separators, CRITICAL callouts, and "DO NOT PROCEED" language
- [ ] FR6: If memory recall returns empty or fails, proceed with explicit warning "No relevant learnings found"

### Non-Functional Requirements
- [ ] NFR1: Memory sections must be visually distinct (--- separators, bold CRITICAL text)
- [ ] NFR2: Each memory section must include a concrete failure mode example
- [ ] NFR3: Output format for displaying learnings must be consistent across all commands

### Out of Scope
- Adding memory recall to /uw:pr or /uw:action-comments (utility commands)
- Agent-specific memory (verification subagents, review agents getting individual memory)
- Memory routing enhancements beyond current patterns

## Technical Approach

### Pattern to Apply (from memory)
> "Rules that agents skip need stronger language AND multiple reinforcement points. A single rule statement isn't enough. Use 'CRITICAL' callouts, explicit 'NEVER' statements, and repeat in all relevant sections."

### Visual Format Template (for all commands)

```markdown
---

## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)

**This is the first thing you do. Before anything else.**

Memory recall is the foundation of compounding. Without it, you lose all accumulated learnings from past sessions.

> **If you skip this:** You will repeat mistakes that have already been documented, miss patterns the team learned, and break the compounding loop that makes each session smarter.

### Execute Memory Recall NOW

\`\`\`bash
hindsight memory recall "$(git config --get remote.origin.url ...)" "query" --budget mid --include-chunks
\`\`\`

### Display Learnings

After recall, display:

\`\`\`
**Relevant Learnings from Memory:**
- {learning 1}
- {learning 2}
\`\`\`

If no learnings found: "Memory recall complete - no relevant learnings found for this task."

**DO NOT PROCEED to the next step until memory recall is complete.**

---
```

### Key Files to Modify
1. `plugins/unitwork/commands/uw-work.md` - Add STEP 0, move before Resume Detection
2. `plugins/unitwork/commands/uw-review.md` - Add STEP 0, move before Required Reading
3. `plugins/unitwork/commands/uw-plan.md` - Rename/strengthen Memory Recall to STEP 0
4. `plugins/unitwork/skills/unitwork/SKILL.md` - Add to Core Philosophy and Memory Rules

### Failure Mode Examples (per command)

**uw-work.md:**
> "If you skip this: You may recreate bugs that were already fixed, miss patterns the team learned to avoid, or ignore cross-cutting concerns (like versioning rules) that are documented in memory."

**uw-review.md:**
> "If you skip this: You will miss reviewing for issues that caused bugs in past PRs. The review-standards skill has patterns, but memory has which ones your team actually hit."

**uw-plan.md:**
> "If you skip this: You may plan an approach that was already tried and failed, miss architectural decisions that constrain the solution, or duplicate work that already exists."

## Implementation Units

### Unit 1: Update uw-work.md
- **Changes:**
  - Add `---` separator after Spec Location section
  - Create "## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)" section
  - Move existing Context Recall content into STEP 0
  - Add failure mode example blockquote
  - Add "DO NOT PROCEED" language
  - Remove old "## Context Recall" section
- **Self-Verification:** Read file, confirm STEP 0 appears immediately after Spec Location and before Resume Detection
- **Human QA:** Language is compelling, failure example is specific
- **Confidence Ceiling:** 95%

### Unit 2: Update uw-review.md
- **Changes:**
  - Add `---` separator after Introduction
  - Create "## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)" section BEFORE Required Reading
  - Move existing Context Recall content (including routing table) into STEP 0
  - Add failure mode example blockquote (review-specific)
  - Add "DO NOT PROCEED" language
  - Remove old "## Context Recall" section
- **Self-Verification:** Read file, confirm STEP 0 appears before Required Reading, routing table preserved
- **Human QA:** Language matches uw-work, routing table intact
- **Confidence Ceiling:** 95%

### Unit 3: Update uw-plan.md
- **Changes:**
  - Add `---` separator before Memory Recall section
  - Rename "### Memory Recall" to "## STEP 0: Memory Recall (MANDATORY - DO NOT SKIP)"
  - Elevate from H3 to H2 heading
  - Add failure mode example blockquote (planning-specific)
  - Add "DO NOT PROCEED" language
- **Self-Verification:** Read file, confirm STEP 0 treatment matches other commands
- **Human QA:** Visual treatment consistent
- **Confidence Ceiling:** 95%

### Unit 4: Update SKILL.md
- **Changes:**
  - Add to Core Philosophy (after item 2): "3. **NEVER skip memory recall** - it's the foundation that makes compounding work"
  - Update Memory Rules: Add rule 0 "**NEVER skip memory recall at session start** - this is non-negotiable"
  - Add CRITICAL callout to Memory Rules section intro
- **Self-Verification:** Read file, confirm new principle in Core Philosophy and rule 0 in Memory Rules
- **Human QA:** Integration with existing content is natural
- **Confidence Ceiling:** 92%

### Unit 5: Version bump and changelog
- **Changes:**
  - Update `plugins/unitwork/.claude-plugin/plugin.json` version to 0.2.6
  - Update `CHANGELOG.md` with new entry for 0.2.6
- **Changelog Entry:**
  ```markdown
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
  ```
- **Self-Verification:** Read both files, confirm versions match (0.2.6)
- **Human QA:** Changelog entry is accurate and follows format
- **Confidence Ceiling:** 98%

## Verification Plan

### Agent Self-Verification
- Read each modified file after changes
- Confirm STEP 0 section exists with correct heading format
- Confirm `---` separators present
- Confirm failure mode blockquote included
- Confirm "DO NOT PROCEED" language present
- Confirm routing table in uw-review.md is preserved

### Human QA Checklist
- [ ] uw-work.md: STEP 0 appears after Spec Location, before Resume Detection
- [ ] uw-review.md: STEP 0 appears after Introduction, before Required Reading
- [ ] uw-review.md: Routing table (Memory Topic → Agent mapping) preserved
- [ ] uw-plan.md: STEP 0 has same visual treatment (separators, blockquote)
- [ ] SKILL.md: Core Philosophy now has "NEVER skip memory recall" principle
- [ ] SKILL.md: Memory Rules starts with rule 0 about mandatory recall
- [ ] All files: "DO NOT PROCEED" or equivalent language present
- [ ] Versions match: plugin.json and CHANGELOG.md both show 0.2.6

## Important Notes (from memory)

**Cross-cutting concern:** Remember to bump version and update changelog (this was missed on 4 commits after v0.2.0).

**Pre-commit checklist:**
1. Version bump in plugin.json
2. Changelog update
3. README component counts (if applicable - N/A for this change)

## Spec Changelog
- 14-01-2026: Initial spec from /uw:plan
- 14-01-2026: Updated after plan review - added concrete failure mode examples, clarified ordering (memory before Required Reading), specified empty result behavior
