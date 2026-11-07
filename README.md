# labs

Helm charts and container images for my homelab, published to GHCR under `ghcr.io/dedsxc`.

## Layout

| Path          | Role                                                                    |
| ------------- | ----------------------------------------------------------------------- |
| `helm/`       | Helm charts, one folder per chart, published as OCI artifacts           |
| `containers/` | Container images, one folder per image, published to GHCR               |
| `aicommits/`  | Git `commit-msg` hooks that generate commit messages                    |
| `.github/`    | CI workflows, release-please and Renovate configuration                 |

## Helm charts

A chart lives in `helm/<name>`. On a merge to `main`, release-please opens a release PR from the
Conventional Commits; merging it publishes the chart to `oci://ghcr.io/dedsxc/<name>`.
Pull requests dry-run the modified charts with `helm template` and `kubeconform`.

```bash
helm pull oci://ghcr.io/dedsxc/<name> --version <version>
```

## Container images

An image lives in `containers/<name>` and is published as `ghcr.io/dedsxc/<name>:<version>`. The
folder contains:

| File         | Role                                                                      |
| ------------ | ------------------------------------------------------------------------- |
| `Dockerfile` | Build definition                                                          |
| `VERSION`    | Executable script that prints the image tag                               |
| `PLATFORM`   | Target platforms, comma separated (for example `linux/amd64,linux/arm64`) |

To add an image, create the folder with these three files. A merge to `main` builds and pushes the
modified images, and a daily job rebuilds an image when its `VERSION` differs from the latest tag.
Pull requests only build the modified images.

## Contributing

- Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, and `feat!:`
  for a breaking change. release-please derives the chart version from them.
- Do not edit the `version` in `Chart.yaml` or `CHANGELOG.md`: release-please does it.
- Hooks: `pre-commit install`.
