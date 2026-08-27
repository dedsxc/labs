# OpenSRE

Reproducible build of [OpenSRE](https://github.com/Tracer-Cloud/opensre) pinned to an upstream commit.

The container runs the FastAPI web runtime on port `8000` as a non-root user. Update both `opensre/containers/opensre/Dockerfile` and `VERSION` when bumping upstream.

Telemetry is a runtime concern. The homelab deployment disables it with `OPENSRE_NO_TELEMETRY=1`.
