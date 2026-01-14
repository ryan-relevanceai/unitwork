# Installation Documentation & Script

## Purpose & Impact
- Why: Users currently have no easy way to set up Hindsight and agent-browser dependencies
- Who: New users adopting Unit Work plugin
- Success: Users can run a single script or follow clear manual steps to get dependencies installed

## Requirements

### Functional Requirements
- [ ] FR1: Create `install_deps.sh` bash script that installs Hindsight CLI and agent-browser
- [ ] FR2: Script checks for Docker and Node.js prerequisites, errors with instructions if missing
- [ ] FR3: Script installs Hindsight CLI (brew on macOS, curl on Linux)
- [ ] FR4: Script installs agent-browser via npm
- [ ] FR5: Enhance README Requirements section with clearer documentation
- [ ] FR6: Document recommended presets (OpenRouter + Gemini 3 Flash)

### Non-Functional Requirements
- [ ] NFR1: Script works on macOS and Linux (bash compatible)
- [ ] NFR2: Script is idempotent (can be run multiple times safely)
- [ ] NFR3: Clear error messages with actionable next steps

### Out of Scope
- Windows support (can be added later)
- Automatic Docker installation
- GUI/interactive installer

## Technical Approach

### Files Affected
1. `install_deps.sh` (new) - Main installation script
2. `README.md` - Enhance Requirements section (lines 99-164)

### Script Design
- Check prerequisites (Docker, Node.js 18+)
- Detect OS (macOS vs Linux)
- Install Hindsight CLI via appropriate method
- Install agent-browser globally via npm
- Print success message with next steps

### README Changes
- Add recommended presets section (OpenRouter + Gemini 3 Flash)
- Improve Docker command to use detached mode (-d)
- Add troubleshooting tips
- Keep manual installation commands for users who prefer them

## Implementation Units

### Unit 1: Create install_deps.sh script
- **Changes:** Create new file `install_deps.sh` in repo root
- **Self-Verification:** Run `bash -n install_deps.sh` to check syntax
- **Human QA:**
  - [ ] Review script logic
  - [ ] Test on macOS if available
- **Confidence Ceiling:** 95% (bash script, no UI)

### Unit 2: Enhance README Requirements section
- **Changes:** Edit `README.md` lines 99-164
- **Self-Verification:** Check markdown renders correctly
- **Human QA:**
  - [ ] Review documentation clarity
  - [ ] Verify Docker command uses -d flag
  - [ ] Check recommended presets are correct
- **Confidence Ceiling:** 95% (documentation only)

## Verification Plan

### Agent Self-Verification
- Run `bash -n install_deps.sh` to validate syntax
- Check file is executable
- Verify README markdown structure

### Human QA Checklist
- [ ] Run `./install_deps.sh` on a clean system (or review script logic)
- [ ] Verify Docker command works with -d flag
- [ ] Confirm recommended presets match user's preference (OpenRouter + Gemini 3 Flash)
- [ ] Test manual installation commands work independently

## Spec Changelog
- 14-01-2026: Initial spec from interview
