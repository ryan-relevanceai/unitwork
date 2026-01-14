# Learnings: Installation Documentation
Date: 14-01-2026
Spec: .unitwork/specs/14-01-2026-installation-docs.md

## Feature Paths Discovered
- `install_deps.sh` (repo root): Bash script for automated dependency installation
- `README.md` lines 97-186: Manual installation documentation with prerequisites, Hindsight setup, and agent-browser setup

## Architectural Decisions
- **Repo root for install script**: Install scripts belong at repo root for discoverability (standard convention)
- **Dual approach (script + manual)**: Provide both automated script and manual commands for users who want control
- **Detached Docker mode (-d)**: Use detached mode so terminal isn't blocked - users can continue working
- **Sequential installs over parallel**: Chose clarity of output over ~30s speed gain for one-time script

## Gotchas & Quirks
- **curl -fsSL flags required**: Plain `curl -L` doesn't fail on HTTP errors. Always use `-f` (fail on errors), `-s` (silent), `-S` (show errors), `-L` (follow redirects) for downloading executables
- **macOS ARM64 assumption**: Direct download path assumes Apple Silicon. The brew path handles both architectures, so brew users are fine. Intel Mac users without brew need manual adjustment
- **Docker daemon check**: Need to verify Docker daemon is running (`docker info`), not just that Docker binary exists (`command -v docker`)

## Verification Insights
- **Verified automatically**: Bash syntax via `bash -n`, file permissions
- **Human review needed**: Actual script execution on target platforms, documentation clarity
- **Security review caught curl flags issue**: The parallel security reviewer identified missing `-f` flag as P2 - good example of why multi-agent review finds issues single-pass might miss

## For Next Time
- For install scripts, always use `curl -fsSL` pattern from the start
- When supporting multiple OS, consider all architectures (not just the most common)
- Interview question to add: "Should script prioritize speed (parallel) or clarity (sequential)?"
- Color output helpers (`print_success`, `print_error`) are worth the few lines - they make output scannable
