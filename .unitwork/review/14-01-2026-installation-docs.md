# Code Review: Installation Documentation

## Summary
- P1 Issues: 0
- P2 Issues: 2
- P3 Issues: 3

## P1 - Critical Issues

None.

## P2 - Important Issues

### [INSECURE_DOWNLOAD] - Severity: P2

**Location:** `install_deps.sh:111, 117`

**Issue:** Binary downloads via curl do not verify integrity with checksums

**Why:** The script downloads executables from GitHub and immediately makes them executable. While HTTPS is used, there's no checksum verification. If the download is intercepted or compromised at source, malicious code could be executed with elevated privileges via `sudo mv`.

**Fix:**
```bash
# Before
curl -L https://github.com/vectorize-io/hindsight/releases/latest/download/hindsight-linux-x86_64 -o /tmp/hindsight

# After - add -f flag and enforce https
curl -fsSL --proto '=https' https://github.com/vectorize-io/hindsight/releases/latest/download/hindsight-linux-x86_64 -o /tmp/hindsight
```

Note: Full checksum verification requires maintaining known-good checksums, which adds maintenance burden. The `-f` flag at minimum ensures HTTP errors are caught.

---

### [SEQUENTIAL_INSTALLS] - Severity: P2

**Location:** `install_deps.sh:202-208`

**Issue:** `install_hindsight_cli` and `install_agent_browser` run sequentially when they are independent

**Why:** Running them in parallel could save 10-30 seconds during network operations.

**Trade-off:** Parallel execution would interleave stdout, making output harder to read. For an install script that runs once, clarity may be more valuable than speed.

**Verdict:** Acceptable as-is for clarity. Documenting but not fixing.

---

## P3 - Nice-to-Have

### [CREDENTIAL_EXPOSURE_DOCS] - Severity: P3

**Location:** `README.md:129`

**Issue:** Documentation shows API key in shell export format, which users might commit to dotfiles repos.

**Why:** Minor risk of accidental key exposure.

**Verdict:** Acceptable - standard documentation pattern.

---

### [PRIVILEGE_ESCALATION_PATTERN] - Severity: P3

**Location:** `install_deps.sh:113, 119`

**Issue:** Script uses `sudo` on network-fetched content without explicit per-operation consent.

**Why:** Common pattern for install scripts. Users expect sudo prompts.

**Verdict:** Acceptable - standard install script behavior.

---

### [MACOS_ARM_ONLY] - Severity: P3

**Location:** `install_deps.sh:111`

**Issue:** macOS direct download assumes ARM64 (`hindsight-darwin-arm64`), which would fail on Intel Macs.

**Why:** Most macOS users in 2026 are on Apple Silicon, but Intel Macs still exist.

**Verdict:** Edge case. Brew path handles both architectures. Document but don't fix.

---

## Review Status
- [x] All P1s resolved (none found)
- [x] P2s addressed or explicitly deferred
  - INSECURE_DOWNLOAD: Fixed - added `-fsSL` flags to curl commands
  - SEQUENTIAL_INSTALLS: Deferred - clarity preferred over speed for install script
- [x] P3s documented for future consideration
