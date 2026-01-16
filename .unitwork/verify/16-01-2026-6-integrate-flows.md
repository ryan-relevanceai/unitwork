# Verification: Unit 6 - Integrate into First-Time and Existing Setup Flows

## Changes Made
- Added "After Step 7: Proceed to Step 7.5" to connect steps
- Clarified which flows reach Step 7.5 (full setup vs sync-only)
- Fixed "Step 8" references to use "Final Report" and "proceed to Final Report"
- Added separate Final Report section for sync-only flow output
- Renamed final section to "Next Steps" for clarity

## AI-Verified
- [x] Full setup flow: Steps 1 → 1.5 (Full setup) → 2-7 → 7.5 → Final Report
- [x] Sync-only flow: Steps 1 → 1.5 (Sync learnings only) → 7.5 → Final Report
- [x] Exit flow: Steps 1 → 1.5 (Exit) → Stop
- [x] Step 7 has transition note to Step 7.5
- [x] Step 7.5 documents both entry points
- [x] Final Report has different output for sync-only vs full setup
- [x] No dangling "Step 8" references

## Human QA Checklist
- [ ] Run full bootstrap on a fresh repo, verify all steps execute
- [ ] Run bootstrap on existing repo, select "Full setup", verify exploration runs
- [ ] Run bootstrap on existing repo, select "Sync learnings only", verify exploration is skipped
- [ ] Run bootstrap on existing repo, select "Exit", verify bootstrap cancels

## Confidence
85%

## Notes
Confidence is 85% per spec (Unit 6 confidence ceiling). Both flows are documented but actual execution depends on the LLM following the branching instructions correctly.
