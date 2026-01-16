# Learnings: Fix Installation Documentation

Date: 16-01-2026
Spec: .unitwork/specs/16-01-2026-fix-installation-docs.md

## Summary

Fixed broken installation script and README that referenced a non-existent npm package (`@anthropic/agent-browser` doesn't exist - the correct package is `agent-browser` from vercel-labs). Also added architecture detection for macOS and Linux system dependency handling.

## Gotchas & Surprises

- **Package naming assumptions**: The `@anthropic/agent-browser` package was assumed to exist because it looked like a scoped npm package name, but it never existed on npm. The actual package is `agent-browser` (unscoped) published by vercel-labs. Always verify package names with `npm view <package>` before documenting them.

- **Architecture naming conventions differ**: `uname -m` returns `x86_64` on Intel Macs, but GitHub releases use `amd64` in filenames. The mapping `x86_64 → amd64` is a common convention but not obvious. Hindsight also publishes both variants (`hindsight-linux-x86_64` and `hindsight-linux-amd64` both exist).

## Generalizable Patterns

- **Validate external dependencies against source of truth**: When writing installation documentation, always verify against the official source (npm registry, GitHub releases API) rather than assuming package/binary names. Use `npm view <pkg>` or `curl -sI <url> | head -1` to verify.

- **Architecture detection for multi-arch binaries**: Standard pattern for macOS is `ARCH=$(uname -m)` then map to release naming convention. Most projects use `arm64` for Apple Silicon and `amd64` for Intel (not `x86_64`).
