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
