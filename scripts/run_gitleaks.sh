#!/bin/bash
set -e

echo "Running Gitleaks scan..."
gitleaks detect \
  --source="." \
  --config="gitleaks.toml" \
  --verbose \
  --exit-code 1