# Code Review: Learnings Format Improvement

## Summary
- P1 Issues: 0
- P2 Issues: 4 (all fixed)
- P3 Issues: 2 (deferred)

## P1 - Critical Issues

None.

## P2 - Important Issues (Fixed)

### 1. Hindsight Placeholder Clarity
**Location:** `uw-compound.md:145`
**Issue:** Unclear if `<feature type>` should be substituted
**Fix:** Added concrete example showing "OAuth integrations" instead of abstract placeholder

### 2. Forced 5-Section Taxonomy
**Location:** Both files
**Issue:** Every learning forced into 5 sections even when some don't apply
**Fix:** Added "(if any)" to optional sections, comment noting to include only meaningful content

### 3. Exposed Hindsight Command Logic
**Location:** `uw-compound.md:113-139`
**Issue:** User sees 4 separate retain calls - implementation detail leak
**Fix:** Replaced with single concrete example + guidance bullets

### 4. Guidelines Duplicate Template
**Location:** `uw-compound.md:141-158`
**Issue:** Memory format guidelines repeat what template sections already express
**Fix:** Consolidated into brief bullets after the example

## P3 - Nice-to-Have (Deferred)

### 1. Inline Explanations in Template
**Location:** `learnings.md`
**Issue:** `{What changed...}` prompts duplicate section header meaning
**Status:** Kept minimal prompts for guidance; removed verbose ones

### 2. "What NOT to capture" Redundancy
**Location:** `uw-compound.md:34-38`
**Issue:** Intro principle already sets boundary
**Status:** Removed - intro is sufficient

## Review Status
- [x] All P1s resolved (none found)
- [x] P2s addressed
- [x] P3s documented for future consideration
