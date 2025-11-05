FROM public.ecr.aws/ubuntu/ubuntu:24.04@sha256:5e577b6d8daf617a41455f03330aa2aac0374d9ab1a47b39a5dd5cf1513a73e4

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
    MLFLOW_ROOT="/opt/mlflow" \
    UV_VERSION="0.5.11"

SHELL ["/bin/bash", "-e", "-u", "-o", "pipefail", "-c"]

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

apt-get install --no-install-recommends --yes \
  "ca-certificates=20240203" \
  "curl=8.5.0-2ubuntu10.6" \
  "libpq-dev=16.10-0ubuntu0.24.04.1" \
  "python3.12=3.12.3-1ubuntu0.8"

apt-get clean --yes

rm --force --recursive /var/lib/apt/lists/*

ln -s /usr/bin/python3.12 /usr/bin/python3
EOF

# uv
RUN <<EOF
ARCH="$(uname -m)"
if [ "${ARCH}" = "x86_64" ]; then
  UV_ARCH="x86_64-unknown-linux-gnu"
elif [ "${ARCH}" = "aarch64" ]; then
  UV_ARCH="aarch64-unknown-linux-gnu"
else
  echo "Unsupported architecture: ${ARCH}" && exit 1
fi

curl --location --fail-with-body \
  "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${UV_ARCH}.tar.gz" \
  --output uv.tar.gz

tar --extract --file uv.tar.gz

install --owner nobody --group nogroup --mode 0755 "uv-${UV_ARCH}/uv" /usr/local/bin/uv

install --owner nobody --group nogroup --mode 0755 "uv-${UV_ARCH}/uvx" /usr/local/bin/uvx

rm --force --recursive uv.tar.gz "uv-${UV_ARCH}"
EOF

RUN <<EOF
install --directory --owner ${CONTAINER_USER} --group ${CONTAINER_GROUP} --mode 0755 ${MLFLOW_ROOT}
EOF

COPY --chown=${CONTAINER_USER}:${CONTAINER_GROUP} src${MLFLOW_ROOT}/requirements.txt ${MLFLOW_ROOT}/requirements.txt
RUN <<EOF
uv pip install --python /usr/bin/python3.12 --system --break-system-packages --no-cache --requirement ${MLFLOW_ROOT}/requirements.txt
EOF

USER ${CONTAINER_USER}
WORKDIR ${MLFLOW_ROOT}
EXPOSE 5000
COPY --chown=${CONTAINER_USER}:${CONTAINER_GROUP} src${MLFLOW_ROOT}/auth.ini ${MLFLOW_ROOT}/auth.ini
COPY --chown=nobody:nobody --chmod=0755 src/usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=nobody:nobody --chmod=0755 src/usr/local/bin/healthcheck.sh /usr/local/bin/healthcheck.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
HEALTHCHECK --interval=15s --timeout=10s --start-period=10s --retries=3 CMD ["/usr/local/bin/healthcheck.sh"]
