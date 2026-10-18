---
name: sonar-scan-fix
description: Scans the project with SonarQube via MCP, displays issues, and fixes them in batches on a dedicated branch. Requires a running SonarQube Server instance and a container engine (podman/docker/nerdctl).
disable-model-invocation: true
argument-hint: '[project-key]'
allowed-tools: Read, Glob, Grep, Edit, Write, AskUserQuestion, Bash(podman:*), Bash(docker:*), Bash(nerdctl:*), Bash(curl:*), Bash(sonar-scanner:*), Bash(git:*), Bash(claude:*), Bash(ls:*), Bash(cat:*), Bash(date:*), Bash(npm:*), Bash(npx:*), Bash(mvn:*), Bash(gradle:*), Bash(command:*), Bash(printenv:*), Bash(wc:*), Bash(pytest:*), Bash(dotnet:*)
---

# /sonar-scan-fix — SonarQube scan & fix cycle

## Session context

Today's date:
!`date +%F 2>/dev/null || powershell -NoProfile -c "Get-Date -Format yyyy-MM-dd" 2>/dev/null`

Operating system:
!`uname -s 2>/dev/null || echo "Windows"`

Container engine available:
!`command -v podman 2>/dev/null || command -v docker 2>/dev/null || command -v nerdctl 2>/dev/null || echo "NONE"`

SONAR_HOST_URL:
!`test -n "$SONAR_HOST_URL" && echo "SET → $SONAR_HOST_URL" || echo "NOT SET"`

SONAR_TOKEN:
!`test -n "$SONAR_TOKEN" && echo "SET (value hidden)" || echo "NOT SET"`

Current branch:
!`git branch --show-current 2>/dev/null`

Repository root:
!`git rev-parse --show-toplevel 2>/dev/null || pwd`

sonar-project.properties:
!`cat sonar-project.properties 2>/dev/null || echo "NOT FOUND"`

Registered MCP servers:
!`claude mcp list 2>/dev/null || echo "Could not list MCP servers"`

---

## Hard rules

- **Never print, log, save to a file, or commit `SONAR_TOKEN`.** Use it only inside shell commands via the environment variable reference `$SONAR_TOKEN` / `$env:SONAR_TOKEN`.
- **Never auto-fix Security Hotspots** — they require human triage. List them separately.
- **Never make changes that alter business logic** just to satisfy a SonarQube rule. List those issues separately for manual review.
- **Idempotent:** re-running the skill detects prior state (image pulled, MCP registered, branch exists) and resumes from the appropriate step.
- **Language:** respond in the same language the user used when invoking the skill.

---

## Instructions

Follow these nine steps in order. **Do not skip ahead.** At every **PAUSE** point, use AskUserQuestion and wait for the user's answer before continuing.

---

### Step 1 — Detect container engine

Look at the **Container engine available** value in the session context above.

- If it shows a path (e.g. `/usr/bin/podman`), use that engine for all subsequent container commands. Store the binary name (the last path segment) as `ENGINE`.
- If it shows `NONE`, **PAUSE:**

```
No container engine detected (looked for podman, docker, nerdctl).
Install one of these, then re-run /sonar-scan-fix.
```

Options: `["I have installed one — retry detection", "Abort"]`

If the user retries, run `command -v podman 2>/dev/null || command -v docker 2>/dev/null || command -v nerdctl 2>/dev/null` again.

---

### Step 2 — Ensure the MCP image is available

Check if the image exists locally:

```bash
$ENGINE image inspect docker.io/sonarsource/sonarqube-mcp >/dev/null 2>&1
```

- If it exists → continue.
- If it does not exist → pull it:

```bash
$ENGINE pull docker.io/sonarsource/sonarqube-mcp
```

- If the pull succeeds → continue.
- If the pull fails → **PAUSE:**

```
Failed to pull docker.io/sonarsource/sonarqube-mcp.
Error: <show stderr>

Possible causes: no internet, proxy/firewall blocking the registry, or engine daemon not running.
```

Options: `["Retry the pull", "I will pull manually — continue", "Use an alternative registry (I will provide the image name)", "Abort"]`

If the user provides an alternative image name, use that for all subsequent commands.

---

### Step 3 — Validate SonarQube credentials

Read the **SONAR_HOST_URL** and **SONAR_TOKEN** values from the session context.

**If either is `NOT SET` → PAUSE:**

Show which variables are missing. Then provide platform-specific instructions based on the **Operating system** in session context:

For Unix/macOS/Linux:
```
Run these commands in your terminal (the token will NOT appear in shell history):

  export SONAR_HOST_URL=https://your-sonarqube-server.example.com
  read -s SONAR_TOKEN && export SONAR_TOKEN

The second command waits silently for you to paste the token and press Enter.
```

For Windows (PowerShell):
```
Run these commands in your terminal:

  $env:SONAR_HOST_URL = "https://your-sonarqube-server.example.com"
  $env:SONAR_TOKEN = Read-Host -MaskInput "Token"

Then re-run /sonar-scan-fix in this same terminal session.
```

Options: `["I have exported the variables — retry", "Abort"]`

On retry, re-check with `printenv SONAR_HOST_URL` and `test -n "$SONAR_TOKEN" && echo SET || echo NOT SET` (never print the token value).

**Once both are set**, validate the connection:

```bash
curl -sf -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/authentication/validate"
```

Expected response contains `"valid":true`.

- If valid → continue.
- If `"valid":false` → **PAUSE:**

```
Token authentication failed. The token may be expired, revoked, or lack permissions.
Generate a new token at: $SONAR_HOST_URL/account/security
```

Options: `["I have updated the token — retry", "Abort"]`

- If connection error (timeout, certificate error, etc.) → **PAUSE:**

```
Cannot reach $SONAR_HOST_URL.
Diagnosis: <show curl error>

Check: Are you connected to the VPN? Does the URL require a custom CA certificate?
```

Options: `["I have fixed connectivity — retry", "Abort"]`

---

### Step 4 — Register the SonarQube MCP server in Claude Code

Check the **Registered MCP servers** from session context. If a server named `sonarqube` already appears → skip this step and continue to Step 5.

Otherwise, determine the project key:

1. If `$ARGUMENTS` was provided, use it as the project key.
2. Else if `sonar-project.properties` exists in session context, extract `sonar.projectKey` from it.
3. Else **PAUSE** and ask the user for the project key.

Determine the absolute path to the repository root from session context.

Register the MCP server (user scope — never `.mcp.json`):

```bash
claude mcp add --transport stdio sonarqube -- \
  $ENGINE run -i --rm \
  -e SONARQUBE_URL="$SONAR_HOST_URL" \
  -e SONARQUBE_TOKEN="$SONAR_TOKEN" \
  -e SONARQUBE_PROJECT_KEY="<project-key>" \
  -e SONARQUBE_TOOLSETS="issues,measures,vortex" \
  -v "<repo-root-absolute-path>:/app/mcp-workspace:rw" \
  docker.io/sonarsource/sonarqube-mcp
```

> **Important:** Use `$SONAR_HOST_URL` and `$SONAR_TOKEN` as literal env-var references so the actual values are never written to any config file. The container inherits them at runtime from the shell environment.

After successful registration, **PAUSE:**

```
✅ The SonarQube MCP server has been registered in your Claude Code user config.

To activate it you must restart Claude Code. After restarting, run /sonar-scan-fix again
— it will detect the existing registration and resume from Step 5 (the scan).
```

Options: `["Understood — I will restart and re-run"]`

**Stop execution here on this run.** The MCP is only loaded on the next Claude Code session.

---

### Step 5 — Run the SonarQube scanner

Check the **sonar-project.properties** value from session context.

- If `NOT FOUND` → **PAUSE:**

```
No sonar-project.properties found at the repository root.
This file is required for the scanner to know the project key and source paths.
```

Options: `["The file is at a different path (I will specify)", "Help me create a minimal one", "Abort"]`

If the user asks you to create one, ask for `sonar.projectKey` and `sonar.sources`, then write a minimal file. Do NOT include `sonar.token` in the file.

- If found → run the scanner. Detect the available scanner command:
  1. `sonar-scanner` (standalone CLI)
  2. `mvn sonar:sonar` (Maven projects)
  3. `npx sonarqube-scanner` (Node projects)
  4. `gradle sonarqube` (Gradle projects)
  5. `dotnet sonarscanner` (.NET projects)

Use the first one available. Pass the token and quality-gate wait flag via command-line arguments (never in the properties file):

```bash
sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.host.url="$SONAR_HOST_URL" \
  -Dsonar.qualitygate.wait=true
```

If the scan fails, show the error and ask the user how to proceed.

---

### Step 6 — Retrieve issues

**Primary method — MCP tools:** Use the SonarQube MCP server's tools to list open issues for the project/branch. The MCP exposes tools for searching issues.

**Fallback — REST API:** If MCP tools are not available (server not registered, not loaded, or erroring), use the REST API directly:

```bash
curl -sf -u "$SONAR_TOKEN:" \
  "$SONAR_HOST_URL/api/issues/search?projectKeys=<project-key>&statuses=OPEN,CONFIRMED,REOPENED&ps=500&p=1"
```

Paginate (`p=2`, `p=3`, …) until all issues are retrieved.

Parse and categorize every issue by:
- **Severity:** BLOCKER, CRITICAL, MAJOR, MINOR, INFO
- **Type:** BUG, VULNERABILITY, CODE_SMELL
- **File and line**
- **Rule key and message**

Separate **Security Hotspots** (type `SECURITY_HOTSPOT`) into a distinct list — they will NOT be auto-fixed.

---

### Step 7 — Present summary and correction plan

Display a summary table:

```
| Severity | Bugs | Vulnerabilities | Code Smells | Total |
|----------|------|-----------------|-------------|-------|
| BLOCKER  |    … |               … |           … |     … |
| CRITICAL |    … |               … |           … |     … |
| MAJOR    |    … |               … |           … |     … |
| MINOR    |    … |               … |           … |     … |
| INFO     |    … |               … |           … |     … |
| **Total**|    … |               … |           … |     … |
```

If there are Security Hotspots, show them separately:

```
⚠️  Security Hotspots (require manual review — will NOT be auto-fixed):
  - <file>:<line> — <rule> — <message>
  …
```

If there are issues that would require business-logic changes, list them separately too:

```
⚠️  Issues requiring business-logic changes (will NOT be auto-fixed):
  - <file>:<line> — <rule> — <message>
  …
```

Then show a proposed correction plan grouped by batches (by file or by rule, whichever produces smaller batches).

**PAUSE:**

```
Above is the issue summary and proposed correction plan.
Which severities should I fix?
```

Options: `["BLOCKER + CRITICAL + MAJOR", "BLOCKER + CRITICAL only", "All (BLOCKER through INFO)", "Let me specify which ones"]`

Wait for the user's selection. Filter the working set accordingly.

---

### Step 8 — Create branch and fix in batches

Ensure the working tree is clean (`git status --short`). If not, warn and ask the user to commit or stash first.

Create and switch to a fix branch:

```bash
git checkout -b fix/sonar-<today's-date>
```

If the branch already exists, switch to it — this is a resume scenario. Check `git log` to see what was already done and propose a starting point.

Fix issues in small batches (5–10 issues, grouped by file when possible). For each batch:

1. Apply the fixes using Edit/Write tools.
2. Run the project's test suite (auto-detect: `npm test`, `mvn test`, `gradle test`, `pytest`, `dotnet test`, etc.). If no test command is detected, tell the user and skip.
3. Run the project's linter (auto-detect: `npm run lint`, `eslint .`, `flake8`, `pylint`, etc.). If no linter is detected, tell the user and skip.
4. If tests or lint **pass** → show progress (`Fixed X/Y issues, Z batches remaining`) and continue.
5. If tests or lint **fail** → **PAUSE:**

```
Tests/lint failed after batch N.
Failures:
<summary of failures>
```

Options: `["Show me the full output", "Revert this batch and skip these issues", "I will fix manually — continue to next batch", "Abort"]`

If the user chooses to revert, run `git checkout -- <files changed in this batch>` to undo the batch.

---

### Step 9 — Re-scan and verify

After all batches are applied, re-run the scanner (same as Step 5) and retrieve issues again (same as Step 6).

Build a before/after comparison:

```
| Severity | Before | After | Fixed | Remaining |
|----------|--------|-------|-------|-----------|
| BLOCKER  |      … |     … |     … |         … |
| CRITICAL |      … |     … |     … |         … |
| MAJOR    |      … |     … |     … |         … |
| MINOR    |      … |     … |     … |         … |
| INFO     |      … |     … |     … |         … |
| **Total**|      … |     … |     … |         … |

Quality Gate: <PASSED / FAILED>
```

**PAUSE:**

```
Re-scan complete. Summary above.
Branch: fix/sonar-<date>
All changes are local — nothing has been committed or pushed.
```

Options: `["Commit all changes", "Commit and push", "Let me review the diff first", "Abort without committing"]`

Act according to the user's choice:
- **Commit:** Use a message like `fix: resolve N SonarQube issues (BLOCKER: X, CRITICAL: Y, MAJOR: Z)`.
- **Commit and push:** Commit first, then push the branch.
- **Review diff:** Run `git diff` and show it, then ask again.
- **Abort:** Leave changes unstaged. The user can review and commit manually.

---

## Summary of expected behavior

```
First run (no image, no MCP):

  Step 1  →  Detects podman/docker/nerdctl
  Step 2  →  Pulls docker.io/sonarsource/sonarqube-mcp
  Step 3  →  Validates SONAR_HOST_URL + SONAR_TOKEN
  Step 4  →  Registers MCP → PAUSE: restart Claude Code
  (stops here)

Second run (after restart):

  Step 1  →  Engine already detected ✓
  Step 2  →  Image already present ✓
  Step 3  →  Credentials still valid ✓
  Step 4  →  MCP already registered ✓ (skip)
  Step 5  →  Runs sonar-scanner
  Step 6  →  Retrieves issues via MCP (or API fallback)
  Step 7  →  Shows summary → PAUSE: which severities?
  Step 8  →  Creates fix/sonar-<date> branch → fixes in batches
  Step 9  →  Re-scans → PAUSE: commit/push decision
```
