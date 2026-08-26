# Garmin MCP

Container image for [Taxuspt/garmin_mcp](https://github.com/Taxuspt/garmin_mcp), pinned to upstream commit `3610be6feed93088d85b0f35aba9d7d07c2505a7`.

The Kubernetes deployment must set `GARMIN_MCP_TRANSPORT=streamable-http`, bind to `0.0.0.0`, and persist `/home/garmin/.garminconnect`.
