#!/usr/bin/env bash

export MLFLOW_AUTH_CONFIG_PATH="${MLFLOW_ROOT}/auth.ini"
export MLFLOW_AUTH_ADMIN_USERNAME="${MLFLOW_AUTH_ADMIN_USERNAME:-"analyticalplatform"}"
export MLFLOW_AUTH_ADMIN_PASSWORD="${MLFLOW_AUTH_ADMIN_PASSWORD:-"analyticalplatform"}"
export MLFLOW_AUTH_DATABASE_URI="${MLFLOW_AUTH_DATABASE_URI:-"sqlite:///basic_auth.db"}"
export MLFLOW_AUTH_DEFAULT_PERMISSION="${MLFLOW_AUTH_DEFAULT_PERMISSION:="NO_PERMISSIONS"}"
export MLFLOW_SERVER_DEV_MODE="${MLFLOW_SERVER_DEV_MODE:-"false"}"
export MLFLOW_SERVER_HOST="${MLFLOW_SERVER_HOST:-"0.0.0.0"}"
export MLFLOW_SERVER_PORT="${MLFLOW_SERVER_PORT:-"5000"}"
export MLFLOW_SERVER_WORKERS="${MLFLOW_SERVER_WORKERS:-"1"}"
export MLFLOW_SERVER_BACKEND_STORE_URI="${MLFLOW_SERVER_BACKEND_STORE_URI:-"sqlite:///mlflow.db"}"
export MLFLOW_SERVER_DEFAULT_ARTIFACT_ROOT="${MLFLOW_SERVER_DEFAULT_ARTIFACT_ROOT:-"${MLFLOW_ROOT}/mlruns"}"

sed --in-place "s|ADMIN_USERNAME|${MLFLOW_AUTH_ADMIN_USERNAME}|" "${MLFLOW_AUTH_CONFIG_PATH}"
sed --in-place "s|ADMIN_PASSWORD|${MLFLOW_AUTH_ADMIN_PASSWORD}|" "${MLFLOW_AUTH_CONFIG_PATH}"
sed --in-place "s|DATABASE_URI|${MLFLOW_AUTH_DATABASE_URI}|" "${MLFLOW_AUTH_CONFIG_PATH}"
sed --in-place "s|DEFAULT_PERMISSION|${MLFLOW_AUTH_DEFAULT_PERMISSION}|" "${MLFLOW_AUTH_CONFIG_PATH}"

if [[ "${MLFLOW_SERVER_DEV_MODE}" == "true" ]]; then
  MLFLOW_SERVER_DEV_MODE_FLAG="--dev"
else
  MLFLOW_SERVER_DEV_MODE_FLAG=""
fi

mlflow server ${MLFLOW_SERVER_DEV_MODE_FLAG} \
  --host "${MLFLOW_SERVER_HOST}" \
  --port "${MLFLOW_SERVER_PORT}" \
  --workers "${MLFLOW_SERVER_WORKERS}" \
  --app-name basic-auth \
  --backend-store-uri "${MLFLOW_SERVER_BACKEND_STORE_URI}" \
  --default-artifact-root "${MLFLOW_SERVER_DEFAULT_ARTIFACT_ROOT}"
