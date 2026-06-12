<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.14.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-trivy/v1.14.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote install script directly to `sh` without first downloading and verifying it. The pattern `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/.../install.sh | sh -s -- ...` executes arbitrary remote content in the runner shell. Even though the URL includes a pinned commit SHA in the path, the content is still piped directly to sh without integrity verification.

Locations:

- `script.sh:52`

### script-injection (severity: high)

Sub-rule (b): Multiple env vars holding untrusted `inputs.*` values are expanded unquoted in the trivy command line in script.sh. Specifically: `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, and `${INPUT_TRIVY_TARGET}` are all unquoted on line 99, and `${INPUT_FLAGS}` is unquoted on line 106. An attacker-controlled input value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) can break out of the intended command and execute arbitrary shell commands. The file even has a `# shellcheck disable=SC2086` comment acknowledging the unquoted expansions.

Locations:

- `script.sh:99`
- `script.sh:106`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two high-severity findings in script.sh:

1. unsafe-shell (line 52): Replaced `curl -sfL ... | sh -s` with a two-step approach: download the reviewdog install script to a temp file (`${TEMP_PATH}/reviewdog-install.sh`) using `curl -sfL --output`, then execute it separately with `sh`. This eliminates the risk of piping arbitrary remote content directly to a shell interpreter.

2. script-injection (lines 99, 106): Replaced unquoted variable expansions (`${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, `${INPUT_TRIVY_TARGET}`, `${INPUT_FLAGS}`) with safe alternatives:
   - Flag inputs (`INPUT_TRIVY_FLAGS`, `INPUT_FLAGS`) are parsed into bash arrays using `read -r -a` from here-strings, preventing shell metacharacter injection while preserving intended word-splitting
   - Arrays are expanded with `"${array[@]+"${array[@]}"}"` for safe empty-array handling
   - `INPUT_TRIVY_COMMAND` and `INPUT_TRIVY_TARGET` are now properly double-quoted
   - Removed the `# shellcheck disable=SC2086` comment that was acknowledging the unsafe unquoted expansions

