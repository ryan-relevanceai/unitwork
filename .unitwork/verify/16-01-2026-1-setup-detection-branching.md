# Verification: Unit 1 - Setup Detection and Branching

## Changes Made
- Added Step 1.5 to uw-bootstrap.md after dependency checks
- Step 1.5 detects existing `.unitwork` directory and Hindsight bank
- If either exists, prompts user with 3 options: Full setup, Sync learnings only, Exit
- Added Step 7.5 for learnings import (referenced by sync-only flow)

## AI-Verified
- [x] Step 1.5 added at correct location (after Step 1, before Step 2)
- [x] Detection logic checks both `.unitwork` dir and bank existence
- [x] AskUserQuestion prompt has correct options
- [x] Branching logic directs to correct steps based on selection
- [x] Step 7.5 exists for sync-only flow to jump to

## Human QA Checklist
- [ ] Run `/uw:bootstrap` on already-setup repo to verify detection works
- [ ] Confirm the 3 options appear in the prompt
- [ ] Verify "Exit" option cancels bootstrap correctly

## Confidence
95%

## Notes
This is the detection and branching structure. The actual learnings import logic (filtering, incremental, etc.) will be implemented in subsequent units.
