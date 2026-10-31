# Unraid templates

Community-maintained Unraid template for the upstream OpenCode container. Not affiliated with OpenCode or Unraid.

![OpenCode](icons/opencode.png)

## OpenCode

Image: `ghcr.io/anomalyco/opencode:2.0.32` (pinned; update after testing). Browser interface: container TCP port `4096`. Startup: `opencode serve --hostname 0.0.0.0 --port 4096`. Working directory: `/workspace`.

Choose your own password and workspace. Config, data and state use separate persistent appdata mappings. Model servers, downloaded models, provider accounts and API credits are separate.

## Icon for an existing container

Edit the container, enable Advanced View, and set Icon URL to:

```text
https://raw.githubusercontent.com/lwkalis/unraid-templates/main/icons/opencode.png
```

Apply and refresh the Docker page. Try a hard refresh if the question mark remains. Source and attribution are in `icons/`.

## Install for testing

1. Download `opencode.xml`.
2. Copy to `/boot/config/plugins/dockerMan/templates-user/my-OpenCode.xml` on Unraid. Back up an existing file at that location before replacing it.
3. Open Docker > Add Container and select the OpenCode user template.
4. For a second test instance, choose a different name, unused host port and separate appdata directories. Do not share live appdata between two instances.
5. Choose a workspace and password. Start the container and follow Browser sign-in below, then open WebUI.

Publishing this repository does not change existing installations. Preserve their settings. Before adding data/state mappings to an existing container, back up those container directories: an empty host mapping hides the old directory.

## Browser sign-in (including repeating login prompts)

OpenCode 2.0.32 can repeatedly challenge unauthenticated background requests when accessed over plain HTTP on a LAN. This can interrupt the browser's login prompt ([issue #1](https://github.com/lwkalis/unraid-templates/issues/1)). Use a one-time pairing link to establish a browser session before opening the app.

Download [scripts/pair-browser.sh](scripts/pair-browser.sh) from this repository to your Unraid host. In Unraid Terminal, run:

```sh
sh /path/to/pair-browser.sh http://YOUR-UNRAID-HOST:4096 OpenCode
```

Replace the URL with the exact address and **host port** you use for WebUI, and `OpenCode` with your container name. Open the printed link directly in the browser you want to connect. It sets a session cookie and redirects to the app, avoiding password entry in the repeating prompt. The link works once and expires after five minutes; run the helper again for another browser. Treat the link as a temporary credential and do not post it in issues.

The helper uses Docker and standard shell tools on the host and BusyBox wget in the pinned upstream image. It calls the **already running container** on port 4096; it does not start a second OpenCode service or change appdata. Existing installations can use it immediately without reinstalling the template. Use the same hostname and port afterward so the browser sends the session cookie. Changing the server password invalidates paired sessions.

The username is fixed to `opencode` in this upstream version; `OPENCODE_SERVER_USERNAME` is not supported. Set the password through Unraid's **Server Password** container field and Apply. Removing or emptying the password does **not** disable authentication: the CLI generates a random password instead. The template therefore keeps the password required and does not offer a nonfunctional authentication-disable switch.

This is a supported pairing workaround for the login prompt problem, not a patch to the embedded upstream UI. The upstream implementation is documented by its [pairing API](https://github.com/anomalyco/opencode/blob/v2.0.32/packages/protocol/src/groups/server.ts), [browser session handler](https://github.com/anomalyco/opencode/blob/v2.0.32/packages/server/src/handlers/server.ts), [fixed username](https://github.com/anomalyco/opencode/blob/v2.0.32/packages/server/src/auth.ts), and [password startup behavior](https://github.com/anomalyco/opencode/blob/v2.0.32/packages/cli/src/server-process.ts).

## Use your own Ollama server

Install Ollama separately and download a model suitable for your hardware. Merge `providers.ollama` from `examples/opencode.ollama.json` into `opencode.json` in the host config directory. Replace `YOUR-OLLAMA-HOST` with an address reachable from OpenCode; keep `/v1` at the end. Restart OpenCode and select an available Ollama model.

In bridge networking, `127.0.0.1` inside OpenCode means that container. Use your Ollama server's reachable address instead. Setting `OLLAMA_HOST` alone does not establish the provider configuration described here.

This template contains no personal server address or credentials. Each installer connects their own Ollama server; installing this template grants no access to the maintainer's network.

[OpenCode v2 Ollama documentation](https://opencode.ai/v2/docs/providers#ollama)

## Validation and Community Applications

XML, JSON, icon format and publication contents were checked locally. On 2026-10-25, the user confirmed browser access with separate appdata, Ollama responses after manual provider configuration, and the icon. The existing-appdata installation also worked after restart. Full recreation persistence, workspace edits and rejection of an incorrect password remain unverified; see TESTING.md. This repository is not yet listed in Community Applications.

Complete `TESTING.md` before submission. Search Apps for an existing template using the same image and review [CA policies](https://forums.unraid.net/topic/87144-ca-application-policies-privacy-policy/). Submit through [the Community Applications portal](https://ca.unraid.net/submit). Moderator approval is required. The account owner must confirm the policy's two-factor authentication requirement themselves.

Template support: [repository issues](https://github.com/lwkalis/unraid-templates/issues). Product: [OpenCode](https://opencode.ai).
