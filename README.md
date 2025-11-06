# Analytical Platform MLflow

[![Ministry of Justice Repository Compliance Badge](https://github-community.service.justice.gov.uk/repository-standards/api/analytical-platform-mlflow/badge)](https://github-community.service.justice.gov.uk/repository-standards/analytical-platform-mlflow)

[![Open in Dev Container](https://raw.githubusercontent.com/ministryofjustice/.devcontainer/refs/heads/main/contrib/badge.svg)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/ministryofjustice/analytical-platform-mlflow)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ministryofjustice/analytical-platform-mlflow)

> [!CAUTION]
> **This deployment is not production-ready in its current state.**
> Trivy security scanning has identified multiple HIGH risk security issues in the Helm chart configuration.
> Missing security contexts allow privilege escalation and root access, writable root filesystems pose security risks, and seccomp profiles are not configured.
> These issues must be addressed before deploying to production environments.

> [!IMPORTANT]
> MLflow on Analytical Platform is currently in discovery

This repository contains the MLflow container image for use on the Analytical Platform.

## Running Locally

### Build

```bash
make build
```

### Test

```bash
make test
```

### Run

```bash
make run
```

Open a browser <http://localhost:5000>

## Versions

### Ubuntu

Dependabot is configured to do this in [`.github/dependabot.yml`](.github/dependabot.yml), but if you need to get the digest, do the following

```bash
docker pull --platform linux/amd64 public.ecr.aws/ubuntu/ubuntu:24.04

docker image inspect --format='{{ index .RepoDigests 0 }}' public.ecr.aws/ubuntu/ubuntu:24.04
```

### APT Packages

The latest versions of the APT packages can be obtained by running the following

```bash
docker run -it --rm --platform linux/amd64 public.ecr.aws/ubuntu/ubuntu:24.04

apt-get update

apt-cache policy ${PACKAGE} # for example curl, git or gpg
```

### MLflow

Dependabot is configured to manage the packages in [`src/opt/mlflow/requirements.txt`](src/opt/analytical-platform/requirements.txt)
