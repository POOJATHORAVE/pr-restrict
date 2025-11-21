#!/bin/bash
set -e

echo "Running Gitleaks scan..."

if command -v gitleaks >/dev/null 2>&1; then
  echo "Using local gitleaks installation"
  gitleaks detect \
    --source="." \
    --config="gitleaks.toml" \
    --verbose \
    --exit-code 1
elif command -v docker >/dev/null 2>&1; then
  echo "Using gitleaks via Docker"
  docker run --rm -v "$PWD":/src zricethezav/gitleaks:v8.18.4 detect \
    --source /src \
    --config /src/gitleaks.toml \
    --verbose \
    --exit-code 1
else
  echo "ERROR: Neither gitleaks nor docker is available"
  echo "Please install gitleaks or docker to run this script"
  exit 2
fi