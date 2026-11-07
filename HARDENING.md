<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-trivy/v1.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-trivy/v1.18.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh, which the action's composite run step calls, downloads a remote installer and pipes it straight into a shell: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/9b54cccfb4bf2509aef8a3e26899412348b62ce9/install.sh | GITHUB_TOKEN="${INPUT_GITHUB_TOKEN}" sh -s -- -b "${REVIEWDOG_PATH}" "${REVIEWDOG_VERSION}"`. The installer URL is pinned to a commit, but the content still runs without being saved first, and the GitHub token is exposed to it. Save the script to a file first (and ideally check its checksum), then run it as a separate step.

Locations:

- `script.sh:54`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

script.sh: the reviewdog install.sh (still pinned to the same commit) is now downloaded with curl -o into a temp file. The script stops with an error if that file is empty, then runs it with `sh "$file" -b "$REVIEWDOG_PATH" "$REVIEWDOG_VERSION"` and deletes it afterwards. The '-s --' from the old piped form is gone, so the installer still sees -b as $1. GITHUB_TOKEN is still passed only to the installer process, as upstream did, because the installer uses it to call the GitHub API. No checksum check was added: I couldn't fetch the file to get a real hash, and I didn't want to make one up.

