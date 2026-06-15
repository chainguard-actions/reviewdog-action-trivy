<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.13.10

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-trivy/v1.13.10** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes remote content directly to a shell interpreter: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b ...`. Even though the URL is pinned to a specific commit SHA, this pattern downloads and executes remote code in a single pipeline without first saving and verifying the script, which is the unsafe-shell anti-pattern.

Locations:

- `script.sh:54`

### script-injection (severity: high)

Rule (b) violation: Multiple env vars sourced from `inputs.*` (workflow-controllable) are expanded unquoted in the trivy command line in script.sh. Specifically: `${INPUT_TRIVY_FLAGS:-}`, `${INPUT_TRIVY_COMMAND}`, `${INPUT_TRIVY_TARGET}`, and `${INPUT_FLAGS}` are all unquoted, allowing an attacker-controlled input value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to inject arbitrary shell commands. The `# shellcheck disable=SC2086` comment even acknowledges the unquoted expansion. These variables are set from `inputs.trivy_flags`, `inputs.trivy_command`, `inputs.trivy_target`, and `inputs.flags` respectively in action.yml's env: block.

Locations:

- `script.sh:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed two high-severity issues in script.sh:
1. unsafe-shell (line 54): Replaced `curl ... | sh -s ...` with a two-step approach: download the reviewdog install script to a temp file with `curl -sfL --output`, execute it separately with `sh`, then clean up with `rm -f`.
2. script-injection (line 97): Replaced unquoted expansions of INPUT_TRIVY_FLAGS, INPUT_TRIVY_COMMAND, INPUT_TRIVY_TARGET, and INPUT_FLAGS with safe alternatives. INPUT_TRIVY_COMMAND and INPUT_TRIVY_TARGET are now double-quoted. INPUT_TRIVY_FLAGS and INPUT_FLAGS are split into bash arrays using `IFS=' ' read -r -a` and expanded with the `"${array[@]+"${array[@]}"}"` pattern that safely handles empty arrays. Removed the `# shellcheck disable=SC2086` comment that was acknowledging the unsafe pattern.

