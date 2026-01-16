# Fix Installation Documentation

## Purpose & Impact
- Correct installation instructions that reference wrong package names
- Ensure users can successfully install dependencies on first attempt
- Add missing Linux-specific setup steps

## Requirements

### Functional Requirements
- [ ] FR1: Fix agent-browser package name from `@anthropic/agent-browser` to `agent-browser`
- [ ] FR2: Add Linux-specific `--with-deps` flag for agent-browser installation
- [ ] FR3: Detect macOS architecture (arm64 vs x86_64) for Hindsight CLI download

### Non-Functional Requirements
- [ ] NFR1: Installation script should work on both Intel and Apple Silicon Macs
- [ ] NFR2: Clear error messages when dependencies fail

### Out of Scope
- Adding Windows support
- Changing Hindsight Docker configuration (verified correct)

## Technical Approach

### Files Affected
1. `install_deps.sh` - Main installation script
2. `README.md` - Documentation with manual install commands

### Changes Required

**install_deps.sh:142** - Wrong package name
```bash
# Current (wrong)
npm install -g @anthropic/agent-browser

# Correct
npm install -g agent-browser
```

**install_deps.sh:143** - Missing Linux deps
```bash
# Current
agent-browser install

# Correct (with OS detection)
if [ "$OS" == "linux" ]; then
    agent-browser install --with-deps
else
    agent-browser install
fi
```

**install_deps.sh:111** - Hardcoded arm64
```bash
# Current (only arm64)
curl -fsSL https://github.com/vectorize-io/hindsight/releases/latest/download/hindsight-darwin-arm64 -o /tmp/hindsight

# Correct (detect architecture)
ARCH=$(uname -m)
if [ "$ARCH" == "arm64" ]; then
    HINDSIGHT_ARCH="arm64"
else
    HINDSIGHT_ARCH="amd64"
fi
curl -fsSL https://github.com/vectorize-io/hindsight/releases/latest/download/hindsight-darwin-${HINDSIGHT_ARCH} -o /tmp/hindsight
```

**README.md:357** - Wrong package name
```bash
# Current (wrong)
npm install -g @anthropic/agent-browser

# Correct
npm install -g agent-browser
```

**README.md** - Add Linux note for agent-browser
```bash
# After agent-browser install command, add note:
# On Linux, use: agent-browser install --with-deps
```

## Implementation Units

### Unit 1: Fix agent-browser package name
- **Changes:** `install_deps.sh:142`, `README.md:357`
- **Self-Verification:** Run `npm view agent-browser` to confirm package exists
- **Human QA:** None needed - simple text replacement
- **Confidence Ceiling:** 100%

### Unit 2: Add Linux --with-deps flag
- **Changes:** `install_deps.sh:143-150`
- **Self-Verification:** Read the modified code to verify OS detection logic is correct
- **Human QA:** Test on Linux if available
- **Confidence Ceiling:** 95%

### Unit 3: Detect macOS architecture for Hindsight CLI
- **Changes:** `install_deps.sh:110-115`
- **Self-Verification:** Run `uname -m` to verify architecture detection works
- **Human QA:** None needed - standard Unix command
- **Confidence Ceiling:** 98%

### Unit 4: Update README.md with Linux note
- **Changes:** `README.md` - add note after agent-browser install section
- **Self-Verification:** Read the modified section
- **Human QA:** None needed - documentation only
- **Confidence Ceiling:** 100%

## Verification Plan

### Agent Self-Verification
- Verify `npm view agent-browser` returns valid package info
- Read modified files to confirm changes are correct
- Run `uname -m` to verify architecture detection command

### Human QA Checklist
- [ ] Run `./install_deps.sh` on macOS to verify it completes successfully
- [ ] (Optional) Run on Linux to verify `--with-deps` flag is used
- [ ] Review README.md changes for clarity

## Spec Changelog
- 16-01-2026: Initial spec based on official documentation comparison
  - Hindsight docs: https://hindsight.vectorize.io/developer/installation
  - agent-browser docs: https://github.com/vercel-labs/agent-browser
