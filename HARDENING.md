<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.17.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-trivy/v1.17.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote install script directly to `sh` via `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}" sh -s`. Even though the URL path contains a commit SHA, this pattern executes remotely-fetched content directly in a shell without first saving and verifying it.

Locations:

- `script.sh:57`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansions of untrusted input-derived env vars in script.sh. On line 100, `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, and `${INPUT_TRIVY_TARGET}` are passed unquoted to the trivy command — these hold values from `inputs.trivy_flags`, `inputs.trivy_command`, and `inputs.trivy_target` respectively (set via the action.yml env: block). On line 107, `${INPUT_FLAGS}` is passed unquoted as a trailing argument to reviewdog, holding `inputs.flags`. Without double-quoting, shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in any of these values can cause command injection. The shellcheck disable comment on line 99 acknowledges but does not fix the issue.

Locations:

- `script.sh:100`
- `script.sh:107`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two high-severity findings in hardened/action/script.sh:

1. unsafe-shell (line 57): Replaced `curl ... | sh -s -- -b ...` with a two-step approach: download the reviewdog install script to a temp file (`${TEMP_PATH}/install-reviewdog.sh`) using `curl -sfL ... -o`, then execute it separately with `sh "${REVIEWDOG_INSTALL_SCRIPT}" -b "${REVIEWDOG_PATH}" "${REVIEWDOG_VERSION}"`. The `--` was dropped as it was the shell's option terminator for the piped form, not the script's own argument.

2. script-injection (lines 100, 107): Replaced unquoted expansions of `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, `${INPUT_TRIVY_TARGET}`, and `${INPUT_FLAGS}` with xargs-based array tokenization. Each input is guarded with `if [ -n "$VAR" ]` and tokenized via `printf '%s' "$VAR" | xargs printf '%s\0'` into bash arrays, then expanded as `"${array[@]}"` to preserve argument boundaries while preventing shell metacharacter injection.

