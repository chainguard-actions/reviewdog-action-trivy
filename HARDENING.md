<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.16.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-trivy/v1.16.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remotely fetched install script directly to `sh` via `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | ... sh -s -- ...`. Even though the URL is pinned to a commit SHA, this pattern executes remote content directly in a shell without first saving and inspecting it, matching the unsafe-shell check.

Locations:

- `script.sh:55`

### script-injection (severity: high)

Rule (b) violation: Multiple env vars sourced from action inputs are expanded unquoted in the trivy and reviewdog command invocation in script.sh. Specifically: `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, `${INPUT_TRIVY_TARGET}`, and `${INPUT_FLAGS}` are all unquoted, allowing an attacker-controlled input to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.). These variables are set from `inputs.trivy_flags`, `inputs.trivy_command`, `inputs.trivy_target`, and `inputs.flags` respectively in action.yml. The offending line is: `"${TRIVY_PATH}/trivy" --format sarif ${INPUT_TRIVY_FLAGS:-} --exit-code 1 ${INPUT_TRIVY_COMMAND} ${INPUT_TRIVY_TARGET} 2> /dev/null` and `${INPUT_FLAGS}` passed unquoted to reviewdog.

Locations:

- `script.sh:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two issues in hardened/action/script.sh:
1. unsafe-shell (line 55): Replaced `curl ... | sh -s -- -b ...` with a download-then-execute pattern: curl downloads the reviewdog install script to a mktemp file, then `sh "$REVIEWDOG_INSTALL_SCRIPT" -b "$REVIEWDOG_PATH" "$REVIEWDOG_VERSION"` executes it (dropping the `--` shell option terminator as required). The temp file is removed afterward.
2. script-injection (line 97): Replaced four unquoted variable expansions (${INPUT_TRIVY_FLAGS:-}, ${INPUT_TRIVY_COMMAND}, ${INPUT_TRIVY_TARGET}, ${INPUT_FLAGS}) with bash arrays populated via xargs/NUL-delimited read loops. Each input is guarded with `if [ -n ... ]` to prevent empty-value issues, and arrays are expanded with `"${array[@]}"` for safe quoting that prevents shell metacharacter injection.

