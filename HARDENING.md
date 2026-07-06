<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy--/v1.15.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-trivy--/v1.15.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The workflow uses `actions/checkout@master` — a mutable branch ref rather than a pinned 40-character commit SHA. This means the action can be silently updated to a different (potentially malicious) commit without any change to the workflow file.

Locations:

- `.github/workflows/labels.yml:15`

### permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no individual jobs define job-level `permissions:` blocks. This means all jobs run with the default (broad) token permissions, violating the principle of least privilege. Affected files: depup.yml, labels.yml, lint.yml, release.yml, tests.yml.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/labels.yml:1`
- `.github/workflows/lint.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/tests.yml:1`

### script-injection (severity: high)

Multiple `run:` blocks in tests.yml directly interpolate GitHub Actions expressions inside shell commands (sub-rule a). The expressions `${{ matrix.type }}`, `${{ steps.test.outputs.trivy-return-code }}`, and `${{ steps.test.outputs.reviewdog-return-code }}` are substituted into shell variables before the shell parses them, allowing an attacker who controls matrix values or step outputs to inject arbitrary shell commands. Offending lines include: `check_type="${{ matrix.type }}"`, `trivy_return="${{ steps.test.outputs.trivy-return-code }}"`, `reviewdog_return="${{ steps.test.outputs.reviewdog-return-code }}"`.

Locations:

- `.github/workflows/tests.yml:57`
- `.github/workflows/tests.yml:58`
- `.github/workflows/tests.yml:59`
- `.github/workflows/tests.yml:91`
- `.github/workflows/tests.yml:92`
- `.github/workflows/tests.yml:120`
- `.github/workflows/tests.yml:121`
- `.github/workflows/tests.yml:155`
- `.github/workflows/tests.yml:156`

### unsafe-shell (severity: high)

In script.sh, the reviewdog installer is fetched and piped directly to `sh` without first saving it to a file: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/9b54cccfb4bf2509aef8a3e26899412348b62ce9/install.sh | GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}" sh -s -- ...`. Although the URL is pinned to a specific commit SHA, piping remote content directly to a shell interpreter is a dangerous pattern — if the remote content is ever compromised or the network is intercepted, arbitrary code executes immediately.

Locations:

- `script.sh:47`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, permissions, script-injection, unsafe-shell

**Notes:**

Fixed all 4 findings: (1) Pinned actions/checkout@master to full SHA 61b9e3751b92087fd0b06925ba6dd6314e06f089 in labels.yml; (2) Added top-level permissions:{} and job-level minimal permissions to all 5 workflow files (depup.yml, labels.yml, lint.yml, release.yml, tests.yml); (3) Moved all ${{ matrix.type }}, ${{ steps.test.outputs.trivy-return-code }}, and ${{ steps.test.outputs.reviewdog-return-code }} expressions out of run: shell strings into env: blocks in tests.yml; (4) Fixed unsafe-shell in script.sh by downloading the reviewdog install script to a temp file first, then executing it separately instead of piping curl output directly to sh.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script.sh lines 88 and 96: replaced unquoted variable expansions of attacker-controlled inputs with safe alternatives. INPUT_TRIVY_COMMAND and INPUT_TRIVY_TARGET (single-value inputs) are now double-quoted. INPUT_TRIVY_FLAGS and INPUT_FLAGS (multi-word flag inputs) are parsed into bash arrays using 'read -r -a' and expanded with the '${array[@]+"${array[@]}"}' idiom, which safely handles multiple arguments without allowing shell metacharacter injection and correctly produces no arguments when the input is empty. The '# shellcheck disable=SC2086' comment was removed since the quoting issue is now properly resolved.

