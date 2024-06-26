FROM public.ecr.aws/ubuntu/ubuntu@sha256:4f5ca1c8b7abe2bd1162e629cafbd824c303b98954b1a168526aca6021f8affe

LABEL org.opencontainers.image.vendor="Ministry of Justice" \
      org.opencontainers.image.authors="Analytical Platform (analytical-platform@digital.justice.gov.uk)" \
      org.opencontainers.image.title="MLflow" \
      org.opencontainers.image.description="MLflow image for Analytical Platform" \
      org.opencontainers.image.url="https://github.com/ministryofjustice/analytical-platform-mlflow"

ENV CONTAINER_USER="analyticalplatform" \
    CONTAINER_UID="1001" \
    CONTAINER_GROUP="analyticalplatform" \
    CONTAINER_GID="1001" \
    DEBIAN_FRONTEND="noninteractive" \
    MLFLOW_ROOT="/mlflow" \
    MLFLOW_VERSION="2.14.1" \
    BOTO3_VERSION="1.34.131" \
    PROMETHEUS_FLASK_EXPORTER_VERSION="0.23.0" \
    PSYCOPG2_BINARY_VERSION="2.9.9"

SHELL ["/bin/bash", "-e", "-u", "-o", "pipefail", "-c"]

RUN <<EOF
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
  "curl=8.5.0-2ubuntu10.1" \
  "libpq-dev=16.3-0ubuntu0.24.04.1" \
  "python3.12=3.12.3-1" \
  "python3-pip=24.0+dfsg-1ubuntu1"

apt-get clean --yes

rm --force --recursive /var/lib/apt/lists/*

pip install --break-system-packages --no-cache-dir \
  "mlflow==${MLFLOW_VERSION}" \
  "boto3==${BOTO3_VERSION}" \
  "prometheus-flask-exporter==${PROMETHEUS_FLASK_EXPORTER_VERSION}" \
  "psycopg2-binary==${PSYCOPG2_BINARY_VERSION}"

install --directory --owner ${CONTAINER_USER} --group ${CONTAINER_GROUP} --mode 0755 ${MLFLOW_ROOT}
EOF

USER ${CONTAINER_USER}
WORKDIR ${MLFLOW_ROOT}
EXPOSE 5000
COPY --chown=${CONTAINER_USER}:${CONTAINER_GROUP} src/mlflow/auth.ini /mlflow/auth.ini
COPY --chown=nobody:nobody --chmod=0755 src/usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=nobody:nobody --chmod=0755 src/usr/local/bin/healthcheck.sh /usr/local/bin/healthcheck.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
HEALTHCHECK --interval=15s --timeout=10s --start-period=10s --retries=3 CMD ["/usr/local/bin/healthcheck.sh"]
