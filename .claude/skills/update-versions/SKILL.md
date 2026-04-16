---
name: update-versions
description: Check and update the latest versions of AI services (Claude Desktop, ChatGPT/Codex, Gemini CLI, Ollama) in install scripts. Use this skill whenever the user asks to update versions, check for latest releases, sync version numbers, or keep install scripts up to date. Also trigger when the user says "버전 업데이트", "최신 버전 확인", "버전 동기화", or similar phrases in Korean.
---

# Update Versions

Automatically check the latest versions of supported AI services and update the install scripts accordingly.

## When to use

- User asks to update or check versions
- User wants to sync install scripts with latest releases
- Before a new release of Setup-AI to ensure scripts are current
- Periodic maintenance to keep versions fresh

## Supported Services

| Service | Script Directory | Primary Source |
|---------|-----------------|----------------|
| Claude Desktop | `scripts/claude-desktop/` | Official download page |
| ChatGPT / Codex | `scripts/chatgpt-codex/` | GitHub Releases API |
| Gemini CLI | `scripts/gemini-cli/` | GitHub Releases API |
| Ollama | `scripts/ollama/` | GitHub Releases API |

## Script Version Format

Each install script declares its target version at the top using a standard variable:

```bash
# In .sh files
VERSION="x.y.z"
```

```powershell
# In .ps1 files
$Version = "x.y.z"
```

These are the only lines that should be modified when updating versions.

## Workflow

### Step 1: Fetch Latest Versions

For each service, check the latest version from official sources. Read `references/version-sources.md` for the full list of URLs and APIs.

**Preferred method — GitHub Releases API (for services with GitHub repos):**

Use WebFetch to call the GitHub API:
- `https://api.github.com/repos/openai/codex/releases/latest` → ChatGPT/Codex
- `https://api.github.com/repos/google-gemini/gemini-cli/releases/latest` → Gemini CLI
- `https://api.github.com/repos/ollama/ollama/releases/latest` → Ollama

Extract the `tag_name` field from the JSON response. Strip any leading `v` prefix (e.g., `v1.2.3` → `1.2.3`).

**Fallback — Web Search:**

If the API is unavailable or the service doesn't use GitHub releases (e.g., Claude Desktop), use WebSearch:
- Search for `"<service name> latest version download"` or `"<service name> release notes"`
- Look for version numbers in the results

Run all fetches in parallel to save time.

### Step 2: Read Current Versions

Read the install scripts under `scripts/<service>/install.sh` and `scripts/<service>/install.ps1`.

Find the `VERSION="..."` (sh) or `$Version = "..."` (ps1) line and extract the current version string.

If a script doesn't exist yet, note it as "script not found" and skip.

### Step 3: Compare and Update

For each service:
- If latest version > current version → update the version line in both `.sh` and `.ps1`
- If versions match → no change needed
- If script not found → skip, note in report

Use the Edit tool to modify only the version line. Do not change anything else in the scripts.

### Step 4: Report Summary

Present a clear summary table:

```
Version Update Report
=====================

| Service         | Previous | Latest | Status      |
|-----------------|----------|--------|-------------|
| Claude Desktop  | 1.0.0    | 1.1.0  | Updated     |
| ChatGPT / Codex | 2.0.0    | 2.0.0  | Up to date  |
| Gemini CLI      | 0.5.0    | 0.6.0  | Updated     |
| Ollama          | -        | 0.3.0  | Not found   |
```

Include:
- Which services were updated
- Which were already current
- Which scripts were missing
- Any errors encountered during version checks

## Error Handling

- If a GitHub API call fails (rate limit, network error), fall back to WebSearch
- If WebSearch also fails, report the service as "unable to check" and continue with others
- Never leave a script in a partially modified state — either update succeeds fully or not at all
- If the version format is unexpected (not semver), report it and let the user decide

## Notes

- GitHub API has rate limits for unauthenticated requests (60/hour). This skill checks at most 4 endpoints per run, so this is not a concern for normal usage.
- Version sources may change over time. If a source URL returns errors consistently, update `references/version-sources.md` with the correct URL.
- Some services (like Claude Desktop) may not publish version numbers publicly in a structured API. In these cases, web search is the primary method — the version found may require human verification.
