#!/usr/bin/env bash

export MLFLOW_SERVER_HOST="${MLFLOW_SERVER_HOST:-"0.0.0.0"}"
export MLFLOW_SERVER_PORT="${MLFLOW_SERVER_PORT:-"5000"}"

curl http://"${MLFLOW_SERVER_HOST}":"${MLFLOW_SERVER_PORT}"/health || exit 1
