# Live Unraid testing

Record Unraid version, image version, date and results. Do not commit passwords, tokens or personal server addresses.

| Check | Expected | Status |
|---|---|---|
| Install | Required password and workspace fields shown | Pending |
| Startup | Container stays running | User confirmed running installations, 2026-10-25 |
| Icon | PNG appears on Docker page | User confirmed on existing installation, 2026-10-25 |
| Port mapping | WebUI works with alternate host port | User confirmed browser access on alternate host ports, 2026-10-25 |
| Authentication | Correct password works; wrong password cannot access protected functions | Pending |
| Workspace | User-approved test edit persists on host | Pending |
| Ollama | Own endpoint discovers models and answers a prompt | User confirmed on existing and separate-appdata installations, 2026-10-25 |
| Recreation | Config and sessions survive Unraid recreation | Pending |
| Fresh install | Separate appdata and port work without existing settings | User confirmed empty-appdata WebUI and Ollama after manual configuration, 2026-10-25 |

User also confirmed the existing-appdata instance worked after a container restart (2026-10-25). Full container recreation and fresh-instance restart persistence have not been separately verified. These are user-reported tests, not remote automated checks. Unraid version was not recorded; OpenCode image is 2.0.32.

Read-only checks in Unraid Terminal, substituting the actual container name:

```sh
docker inspect --format '{{.State.Status}}' OpenCode
docker exec OpenCode opencode --version
docker port OpenCode
```

Inspect logs locally. Redact credentials before sharing: some versions print server credentials during startup.

Check Ollama from Unraid Terminal using your own address:

```sh
curl --fail --max-time 10 http://YOUR-OLLAMA-HOST:11434/api/tags
```

This checks host connectivity only. Confirm OpenCode's connection by selecting an Ollama model in WebUI and sending a short prompt.

## Pairing regression checks (issue #1)

The helper has automated shell tests for URL validation, container selection, password handling, API failure and malformed responses. Run `sh tests/pair-browser.test.sh` from the repository root. These use a mock Docker executable and do not establish a real OpenCode session.

Live checks remain pending on Unraid with image 2.0.32:

1. In a fresh browser profile, confirm the reported repeating prompt on plain HTTP, then close that tab.
2. Run `sh scripts/pair-browser.sh http://YOUR-UNRAID-HOST:HOST-PORT OpenCode` and open the link directly. Confirm redirect to the app and successful event streaming without repeated login prompts in Chrome and Vivaldi, including Android.
3. Confirm the same link cannot be redeemed twice; an unused link expires after five minutes.
4. Confirm a new link works in another browser and an alternate mapped host port.
5. Confirm the password remains required for unauthenticated API requests. Change the password through Unraid, Apply, and confirm old browser sessions are rejected and a new pairing link works.
6. Confirm sessions and appdata are preserved. Test failures with a stopped container and an incorrect password without sharing credentials or pairing links in logs.

Automated tests do not verify the embedded UI, actual Docker image utilities, or real browser cookie behavior.
