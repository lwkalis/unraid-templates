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
5. Choose a workspace and password. Start the container and open WebUI.

Publishing this repository does not change existing installations. Preserve their settings. Before adding data/state mappings to an existing container, back up those container directories: an empty host mapping hides the old directory.

## Use your own Ollama server

Install Ollama separately and download a model suitable for your hardware. Merge `providers.ollama` from `examples/opencode.ollama.json` into `opencode.json` in the host config directory. Replace `YOUR-OLLAMA-HOST` with an address reachable from OpenCode; keep `/v1` at the end. Restart OpenCode and select an available Ollama model.

In bridge networking, `127.0.0.1` inside OpenCode means that container. Use your Ollama server's reachable address instead. Setting `OLLAMA_HOST` alone does not establish the provider configuration described here.

This template contains no personal server address or credentials. Each installer connects their own Ollama server; installing this template grants no access to the maintainer's network.

[OpenCode v2 Ollama documentation](https://opencode.ai/v2/docs/providers#ollama)

## Validation and Community Applications

XML, JSON, icon format and publication contents were checked locally. Fresh Unraid installation, browser login, model response and persistence after recreation still require live testing. This is not yet a verified Community Applications listing.

Complete `TESTING.md` before submission. Search Apps for an existing template using the same image and review [CA policies](https://forums.unraid.net/topic/87144-ca-application-policies-privacy-policy/). Submit through the form linked in that policy thread. Moderator approval is required. The account owner must confirm the policy's two-factor authentication requirement themselves.

Template support: [repository issues](https://github.com/lwkalis/unraid-templates/issues). Product: [OpenCode](https://opencode.ai).
