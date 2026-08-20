FROM public.ecr.aws/ubuntu/ubuntu:24.04@sha256:22a8228e1e48cbe7e0e0f2056e752ffb8a35950cda150a4e5e16417200bec648

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Analytical Platform (analytical-platform@digital.justice.gov.uk)" \
      org.opencontainers.image.title="MLflow" \
      org.opencontainers.image.description="MLflow image for Analytical Platform" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/analytical-platform-mlflow"

ENV CONTAINER_USER="analyticalplatform" \
    CONTAINER_UID="1000" \
    CONTAINER_GROUP="analyticalplatform" \
    CONTAINER_GID="1000" \
    DEBIAN_FRONTEND="noninteractive" \
    MLFLOW_ROOT="/opt/mlflow"

SHELL ["/bin/bash", "-e", "-u", "-o", "pipefail", "-c"]

# trivy:ignore:AVD-DS-0017 Trivy does not understand the HEREDOC syntax used below
RUN <<EOF
userdel --remove --force ubuntu

groupadd \
  --gid ${CONTAINER_GID} \
  ${CONTAINER_GROUP}

useradd \
  --uid ${CONTAINER_UID} \
  --gid ${CONTAINER_GROUP} \
  --create-home \
  --shell /bin/bash \
  ${CONTAINER_USER}

apt-get update --yes

apt-get install --no-install-recommends --yes --only-upgrade \
  "libc-bin=2.39-0ubuntu8.8" \
  "libc6=2.39-0ubuntu8.8"

apt-get install --no-install-recommends --yes \
  "ca-certificates=20260601~24.04.1" \
  "curl=8.5.0-2ubuntu10.12" \
  "gpgv=2.4.4-2ubuntu17.4" \
  "gzip=1.12-1ubuntu3.2" \
  "libncursesw6=6.4+20240113-1ubuntu2.1" \
  "libpq-dev=16.14-0ubuntu0.24.04.1" \
  "libtinfo6=6.4+20240113-1ubuntu2.1" \
  "ncurses-base=6.4+20240113-1ubuntu2.1" \
  "ncurses-bin=6.4+20240113-1ubuntu2.1" \
  "perl-base=5.38.2-3.2ubuntu0.3" \
  "python3.12=3.12.3-1ubuntu0.15" \
  "python3-pip=24.0+dfsg-1ubuntu1.3"

apt-get clean --yes

rm --force --recursive /var/lib/apt/lists/*

install --directory --owner ${CONTAINER_USER} --group ${CONTAINER_GROUP} --mode 0755 ${MLFLOW_ROOT}
EOF

COPY --chown=${CONTAINER_USER}:${CONTAINER_GROUP} src${MLFLOW_ROOT}/requirements.txt ${MLFLOW_ROOT}/requirements.txt
RUN <<EOF
pip install --break-system-packages --no-cache-dir --requirement ${MLFLOW_ROOT}/requirements.txt
EOF

USER ${CONTAINER_USER}
WORKDIR ${MLFLOW_ROOT}
EXPOSE 5000
COPY --chown=${CONTAINER_USER}:${CONTAINER_GROUP} src${MLFLOW_ROOT}/auth.ini ${MLFLOW_ROOT}/auth.ini
COPY --chown=nobody:nobody --chmod=0755 src/usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=nobody:nobody --chmod=0755 src/usr/local/bin/healthcheck.sh /usr/local/bin/healthcheck.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
HEALTHCHECK --interval=15s --timeout=10s --start-period=10s --retries=3 CMD ["/usr/local/bin/healthcheck.sh"]
