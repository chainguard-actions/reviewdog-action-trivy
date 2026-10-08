<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.17.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-trivy/v1.17.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh downloads and pipes a remote install script directly to `sh` without first saving it to disk for inspection. The pattern `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | GITHUB_TOKEN="..." sh -s` executes whatever the remote URL serves, making the build vulnerable to supply-chain attacks if the URL is compromised. The URL is pinned to a commit SHA in the path, but the content is still piped directly to a shell interpreter.

Locations:

- `script.sh:55`

### script-injection (severity: high)

Rule (b) violation: Multiple user-controlled input variables are expanded without double-quotes in the trivy command invocation in script.sh. The variables `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, `${INPUT_TRIVY_TARGET}` (line 100), and `${INPUT_FLAGS}` (line 107) are all set from `inputs.*` values via the `env:` block in action.yml, making them workflow-controllable. Without double-quoting, shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) embedded in these values will be interpreted by bash, enabling command injection. The shellcheck disable comment on line 99 suppresses the warning but does not fix the vulnerability.

Locations:

- `script.sh:100`
- `script.sh:107`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two high-severity findings in script.sh:
1. unsafe-shell (line 55): Replaced 'curl ... | sh -s -- -b ...' with a two-step approach: download the reviewdog install script to a temp file with 'curl -sfL ... -o "${REVIEWDOG_INSTALL_SCRIPT}"', then execute it with 'sh "${REVIEWDOG_INSTALL_SCRIPT}" -b ...' (dropping the '--' since stdin mode is no longer used).
2. script-injection (lines 100, 107): Double-quoted single-value inputs INPUT_TRIVY_COMMAND and INPUT_TRIVY_TARGET. Tokenized list-style inputs INPUT_TRIVY_FLAGS and INPUT_FLAGS via xargs into bash arrays (trivy_flags and reviewdog_flags) with proper null-delimited read loops, then expanded them safely with "${array[@]}". Removed the shellcheck disable comment.

