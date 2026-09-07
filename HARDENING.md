<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.15.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-trivy/v1.15.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The workflow uses `actions/checkout@master` — a mutable branch ref rather than a pinned 40-character commit SHA. This means the action can be silently updated (or compromised) without any change to the workflow file, creating a supply-chain risk.

Locations:

- `.github/workflows/labels.yml:14`

### unsafe-shell (severity: high)

script.sh pipes the output of a remote `curl` download directly into `sh` for execution: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/9b54cccfb4bf2509aef8a3e26899412348b62ce9/install.sh | GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}" sh -s -- ...`. Even though the URL is pinned to a commit SHA, piping remote content directly to a shell interpreter is an unsafe pattern — the script should be downloaded to a file, verified, and then executed separately.

Locations:

- `script.sh:51`

### script-injection (severity: high)

Rule (a): Multiple `run:` blocks in tests.yml directly interpolate GitHub Actions expressions inside shell commands. The expressions `${{ matrix.type }}`, `${{ steps.test.outputs.trivy-return-code }}`, and `${{ steps.test.outputs.reviewdog-return-code }}` are substituted by the Actions template engine before the shell ever sees the string, allowing an attacker who controls these values to inject arbitrary shell commands. Affected steps: 'Check return codes' in jobs test-check (line ~60), test-pr-check (line ~100), test-pr-review (line ~140), and test-operating-systems (line ~175).

Rule (b): script.sh expands user-controlled input env vars unquoted in the trivy command line: `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, `${INPUT_TRIVY_TARGET}`, and `${INPUT_FLAGS}` (line ~96). These variables are populated from `inputs.*` values (set in action.yml's env: block) and their unquoted expansion allows shell metacharacter injection (`;`, `|`, `&`, `$(...)`, etc.) by a caller who controls those inputs.

Locations:

- `.github/workflows/tests.yml:60`
- `.github/workflows/tests.yml:100`
- `.github/workflows/tests.yml:140`
- `.github/workflows/tests.yml:175`
- `script.sh:96`

### permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no individual job within them defines job-level permissions either. Without explicit permissions, workflows run with the default repository token permissions (which may be `write-all` depending on repository settings), violating the principle of least privilege.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/labels.yml:1`
- `.github/workflows/lint.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/tests.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, unsafe-shell, script-injection, permissions

**Notes:**

Fixed all four findings:

1. unpinned-uses: Pinned `actions/checkout@master` in labels.yml to full commit SHA `61b9e3751b92087fd0b06925ba6dd6314e06f089 # master`.

2. unsafe-shell: In script.sh, replaced the `curl ... | sh -s -- -b ...` pipe pattern with: download to temp file, execute separately (dropping the `--` which was the shell's option terminator, not the script's), then clean up the temp file.

3. script-injection: (a) In tests.yml, moved all `${{ matrix.type }}`, `${{ steps.test.outputs.trivy-return-code }}`, and `${{ steps.test.outputs.reviewdog-return-code }}` expressions from run: blocks into env: blocks across all four 'Check return codes' steps. (b) In script.sh, replaced unquoted `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, `${INPUT_TRIVY_TARGET}`, and `${INPUT_FLAGS}` expansions with xargs-based array tokenization to prevent shell metacharacter injection while preserving argument boundaries.

4. permissions: Added least-privilege `permissions:` blocks to all five workflow files: depup.yml (contents:write, pull-requests:write), labels.yml (contents:read, issues:write), lint.yml (contents:read, checks:write, pull-requests:write), release.yml (contents:write, pull-requests:write), tests.yml (contents:read, checks:write, pull-requests:write).

