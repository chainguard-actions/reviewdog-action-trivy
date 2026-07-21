<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.15.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-trivy/v1.15.0** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in tests.yml directly interpolate GitHub Actions expressions into shell commands (sub-rule a). The 'Check return codes' step in the `test-check` job uses `${{ matrix.type }}`, `${{ steps.test.outputs.trivy-return-code }}`, and `${{ steps.test.outputs.reviewdog-return-code }}` directly inside shell command strings. If any of these values contain shell metacharacters, they will be interpreted by the shell before quoting can protect them. The same pattern repeats in the `test-pr-check`, `test-pr-review`, and `test-operating-systems` jobs. These should be moved to `env:` variables and then referenced as quoted `"$VAR"` in the shell.

Locations:

- `.github/workflows/tests.yml:57`
- `.github/workflows/tests.yml:58`
- `.github/workflows/tests.yml:59`
- `.github/workflows/tests.yml:100`
- `.github/workflows/tests.yml:101`
- `.github/workflows/tests.yml:138`
- `.github/workflows/tests.yml:139`
- `.github/workflows/tests.yml:172`
- `.github/workflows/tests.yml:173`

### permissions (severity: medium)

None of the workflow files define a top-level `permissions:` key, and no individual job defines its own `permissions:` block. This means all jobs run with the default (potentially broad) token permissions. Each workflow should declare minimal required permissions at the top level or per-job.

Locations:

- `.github/workflows/tests.yml:1`
- `.github/workflows/depup.yml:1`
- `.github/workflows/lint.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/labels.yml:1`

### unpinned-uses (severity: high)

The workflow `labels.yml` references `actions/checkout@master`, which is a mutable branch ref rather than an immutable 40-character commit SHA. This means the action code can change at any time without notice, creating a supply-chain risk. It should be pinned to a full SHA, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `.github/workflows/labels.yml:17`

### unsafe-shell (severity: high)

In `script.sh`, the reviewdog installer is fetched and piped directly to `sh` without first saving it to a file for inspection: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/9b54cccfb4bf2509aef8a3e26899412348b62ce9/install.sh | GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}" sh -s -- ...`. Even though the URL is pinned to a specific commit SHA, piping remote content directly to a shell interpreter is a dangerous pattern. The script should be downloaded to a temporary file, its integrity verified (e.g. via checksum), and then executed separately.

Locations:

- `script.sh:55`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, permissions, unpinned-uses, unsafe-shell

**Notes:**

Fixed all four findings:
1. script-injection (tests.yml): Moved all ${{ matrix.type }}, ${{ steps.test.outputs.trivy-return-code }}, and ${{ steps.test.outputs.reviewdog-return-code }} expressions out of run: shell strings into env: blocks (CHECK_TYPE, TRIVY_RETURN, REVIEWDOG_RETURN) across all four affected jobs (test-check, test-pr-check, test-pr-review, test-operating-systems).
2. permissions: Added minimal top-level permissions blocks to all 5 workflow files: tests.yml (contents:read, checks:write, pull-requests:write), depup.yml (contents:write, pull-requests:write), lint.yml (contents:read, checks:write, pull-requests:write), release.yml (contents:write, pull-requests:write), labels.yml (contents:read, issues:write).
3. unpinned-uses (labels.yml): Pinned actions/checkout@master to the full commit SHA actions/checkout@61b9e3751b92087fd0b06925ba6dd6314e06f089 # master.
4. unsafe-shell (script.sh): Replaced curl-pipe-to-sh pattern with download-to-tempfile then execute separately pattern for the reviewdog installer, cleaning up the temp file afterward.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in script.sh by: (1) replacing unquoted ${INPUT_TRIVY_COMMAND} and ${INPUT_TRIVY_TARGET} with double-quoted versions to prevent shell metacharacter injection; (2) replacing unquoted ${INPUT_TRIVY_FLAGS:-} and ${INPUT_FLAGS} with bash arrays built via `read -ra` from here-strings, then expanded using the `"${array[@]+"${array[@]}"}"` idiom that safely handles empty arrays without producing spurious empty arguments. The shellcheck disable comment was removed as it's no longer needed.

