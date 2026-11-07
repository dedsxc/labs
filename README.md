# labs

Helm charts and container images for my homelab, published to GHCR under `ghcr.io/dedsxc`.

[![Release Containers](https://github.com/dedsxc/labs/actions/workflows/release-containers.yaml/badge.svg)](https://github.com/dedsxc/labs/actions/workflows/release-containers.yaml)
[![Release Helm Charts](https://github.com/dedsxc/labs/actions/workflows/release-helm-charts.yaml/badge.svg)](https://github.com/dedsxc/labs/actions/workflows/release-helm-charts.yaml)

## Layout

| Path          | Content                                              |
| ------------- | ---------------------------------------------------- |
| `helm/`       | Helm charts, published as OCI artifacts              |
| `containers/` | One Dockerfile per image, published to GHCR          |
| `aicommits/`  | Git `commit-msg` hooks that generate commit messages |
| `.github/`    | Workflows, release-please and Renovate configuration |

## Helm charts

Each chart lives in `helm/<name>` and is versioned by release-please from Conventional Commits.

| Chart               | Description                                       |
| ------------------- | ------------------------------------------------- |
| `cnpg-cluster`      | CloudNativePG `Cluster`, databases, backups       |
| `fork/app-template` | Generic application chart, built on `fork/common` |
| `fork/common`       | Common library chart used by `app-template`       |

Pull a chart:

```bash
helm pull oci://ghcr.io/dedsxc/cnpg-cluster --version <version>
```

See [`helm/cnpg-cluster/README.md`](helm/cnpg-cluster/README.md) for the `cnpg-cluster` values.

## Container images

Each image lives in `containers/<name>` and is published as `ghcr.io/dedsxc/<name>:<version>`.

| Image            | Description                        |
| ---------------- | ---------------------------------- |
| `cnpg`           | CloudNativePG PostgreSQL + pgcopydb |
| `codesandbox`    | CodeSandbox bundler                |
| `debian-tools`   | Debian slim with `curl` and `jq`   |
| `garmin-mcp`     | Garmin Connect MCP server          |
| `meilisearch`    | Meilisearch                        |
| `mem0-dashboard` | Mem0 self-hosted dashboard         |
| `mem0-server`    | Mem0 self-hosted server            |
| `ollama`         | Ollama, non-root user              |
| `ollama-rocm`    | Ollama (ROCm)                      |
| `squoosh`        | Squoosh image compressor           |

An image folder contains:

| File         | Role                                                                      |
| ------------ | ------------------------------------------------------------------------- |
| `Dockerfile` | Build definition                                                          |
| `VERSION`    | Executable script that prints the image tag (for example `1.56.1`)        |
| `PLATFORM`   | Target platforms, comma separated (for example `linux/amd64,linux/arm64`) |

To add an image, create `containers/<name>/` with these three files. The workflows below
build and push it.

## Workflows

| Workflow                      | Trigger                           | What it does                                                           |
| ----------------------------- | --------------------------------- | ---------------------------------------------------------------------- |
| `release-containers`          | Push to `main` on `containers/**` | Builds and pushes the modified images                                  |
| `release-containers-schedule` | Daily at 01:00 UTC, manual        | Rebuilds an image when its `VERSION` differs from the latest GHCR tag  |
| `docker-build-test`           | Pull request on `containers/**`   | Builds the modified images                                             |
| `release-helm-charts`         | Push to `main` on `helm/**`       | release-please opens a release PR; merging it pushes the chart to GHCR |
| `charts-test-deployment`      | Pull request on `helm/**`         | `helm template` + `kubeconform` on the modified charts                    |

Dependencies are updated by Renovate.

## Contributing

- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, and
  `feat!:` for a breaking change. release-please derives the chart version from them.
- Do not edit the `version` in `Chart.yaml` or `CHANGELOG.md`: release-please does it.
- Hooks: `pre-commit install` (trailing whitespace, YAML check, large files, gitleaks).
