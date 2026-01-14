# UW Review Enhancement: Taxonomy-Based Review with Priority Tiers

## Purpose & Impact
- **Why:** The current `uw:review` has good agents but lacks the structured taxonomy and reference files that make reviews consistent and actionable
- **Who:** Developers using Unit Work for code review before PR submission
- **Success:** Reviews surface issues with clear categorization, frequency-based guidance, and tier-based prioritization where correctness always trumps cleanliness

## Requirements

### Functional Requirements
- [ ] FR1: Create `plugins/unitwork/standards/` directory with taxonomy reference files
- [ ] FR2: Create `issue-patterns.md` with ~47 generic patterns derived from relevance data (removing relevance-specific language)
- [ ] FR3: Create `review-standards.md` with language-agnostic best practices
- [ ] FR4: Create `checklists.md` with pre-implementation, during-implementation, and pre-submission checklists
- [ ] FR5: Update `uw:review` command to support multiple review origins (branch diff, PR, codebase area)
- [ ] FR6: Update review agents to reference the taxonomy files
- [ ] FR7: Implement tier-based severity ranking (correctness issues > cleanliness issues)
- [ ] FR8: Add required reading step that loads reference files before review

### Non-Functional Requirements
- [ ] NFR1: Reference files should be language-agnostic (TypeScript/Python/Ruby examples where needed)
- [ ] NFR2: Severity definitions must clearly separate tiers
- [ ] NFR3: Patterns should include frequency data for guidance

### Out of Scope
- Creating codebase-specific area guidelines (like relevance's analytics/notifications areas)
- Real-time frequency tracking from actual PR data
- Integration with GitHub PR comments API for posting findings

## Technical Approach

### File Structure
```
plugins/unitwork/standards/
├── issue-patterns.md      # 47 patterns with frequency, detection, fixes
├── review-standards.md    # Team standards (type safety, null handling, etc.)
└── checklists.md          # Pre/during/post implementation checklists
```

### Tier-Based Severity System

**Tier 1 - Correctness (Always Higher Priority)**
Issues that affect whether code works correctly:
- Security vulnerabilities (injection, auth bypass)
- Architecture problems (wrong boundaries, circular deps)
- Implementation bugs (incorrect logic, runtime errors)
- Type safety violations (casting that hides bugs)
- Functionality gaps (missing error handling, edge cases)

**Tier 2 - Cleanliness (Lower Priority)**
Issues that affect maintainability but not correctness:
- Naming clarity
- File organization
- Code duplication (when not causing bugs)
- Comment quality
- Import style consistency

### Severity Within Tiers

```
P1 CRITICAL - Must fix before merge
  Tier 1: Security vuln, arch causing bugs, runtime errors
  Tier 2: (Rarely P1 - only if cleanliness issue causes confusion leading to bugs)

P2 IMPORTANT - Should fix before merge
  Tier 1: Type casting, incomplete guards, boundary violations
  Tier 2: Significant code duplication, wrong file location

P3 NICE-TO-HAVE - Can defer
  Tier 1: Minor edge cases, defensive code improvements
  Tier 2: Naming nits, comment additions, style consistency
```

### Review Origin Support

The command will support multiple origins:
1. **Branch diff** (default): `git diff main...HEAD`
2. **PR review**: `gh pr diff <number>`
3. **Codebase area**: Specific directory/pattern audit

### Key Integration Points
- Review agents in `plugins/unitwork/agents/review/`
- Command definition in `plugins/unitwork/commands/uw-review.md`
- Skill references in `plugins/unitwork/skills/unitwork/`

## Implementation Units

### Unit 1: Create Standards Directory Structure
- **Changes:** Create `plugins/unitwork/standards/` directory
- **Self-Verification:** `ls` to confirm directory exists
- **Human QA:** Verify directory created in correct location
- **Confidence Ceiling:** 99%

### Unit 2: Create issue-patterns.md
- **Changes:** Write `plugins/unitwork/standards/issue-patterns.md` with 47 patterns adapted from relevance data
- **Self-Verification:** Read file, verify all pattern sections present
- **Human QA:** Review patterns for relevance-specific language removal, verify examples are generic
- **Confidence Ceiling:** 85% (content quality requires human judgment)

### Unit 3: Create review-standards.md
- **Changes:** Write `plugins/unitwork/standards/review-standards.md` with type safety, null handling, error handling, code organization standards
- **Self-Verification:** Read file, verify standard sections present
- **Human QA:** Review standards for language-agnostic applicability
- **Confidence Ceiling:** 85%

### Unit 4: Create checklists.md
- **Changes:** Write `plugins/unitwork/standards/checklists.md` with three checklists
- **Self-Verification:** Read file, verify all checklists present
- **Human QA:** Review for completeness and practicality
- **Confidence Ceiling:** 90%

### Unit 5: Update uw-review.md Command
- **Changes:**
  - Add support for multiple review origins (branch, PR, area)
  - Add required reading step for reference files
  - Add tier-based severity documentation
  - Update severity definitions
- **Self-Verification:** Read file, verify new sections present
- **Human QA:** Test command with different origins
- **Confidence Ceiling:** 90%

### Unit 6: Update Review Agents with Taxonomy References
- **Changes:** Update all 6 review agents to:
  - Reference `issue-patterns.md` for pattern names
  - Use tier-based severity ranking
  - Include pattern names in findings
- **Self-Verification:** Read each agent file, verify references added
- **Human QA:** Run review on sample code, verify findings reference patterns
- **Confidence Ceiling:** 85%

## Verification Plan

### Agent Self-Verification
- File existence checks for all new files
- Content verification via grep for key sections
- Syntax validation of markdown structure

### Human QA Checklist

#### Prerequisites
1. Have code changes ready to review
2. Ensure git repo is in clean state

#### Verification Steps
- [ ] Run `/uw:review` on branch diff -> Verify patterns referenced in findings
- [ ] Run `/uw:review pr 123` (if PR exists) -> Verify PR diff mode works
- [ ] Check findings include tier classification
- [ ] Verify P1 correctness issues ranked above P1 cleanliness issues
- [ ] Review issue-patterns.md for any relevance-specific language
- [ ] Verify checklists are actionable

### Notes
- The 47 patterns are adapted from relevance data - frequency percentages are informative, not prescriptive
- Area-specific guidelines are intentionally out of scope - they're project-specific

## Spec Changelog
- 14-01-2026: Initial spec from interview
