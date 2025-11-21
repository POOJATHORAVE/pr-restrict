# PR Restrict - Gitleaks Integration

This repository demonstrates GitHub secret scanning using Gitleaks in Jenkins CI/CD pipeline.

## Overview

The Jenkins pipeline automatically scans all pull requests for exposed secrets using Gitleaks, a SAST tool for detecting and preventing hardcoded secrets like passwords, API keys, and tokens.

## Fixed Issues

### Authentication Error Fix (v8.18.4 Update)

**Problem**: The Jenkins pipeline was failing with a Docker authentication/manifest error:
```
Error response from daemon: manifest for zricethezav/gitleaks:8.8.3 not found: manifest unknown
```

**Root Cause**: The Jenkinsfile referenced a non-existent Docker image version `zricethezav/gitleaks:8.8.3`. The correct format requires a 'v' prefix (e.g., `v8.18.4`).

**Solution**: Updated to use `zricethezav/gitleaks:v8.18.4` which is a valid, available Docker image.

## Setup and Usage

### Running Gitleaks Locally

You can run Gitleaks locally using the provided script:

```bash
./scripts/run_gitleaks.sh
```

This script will:
1. Check if gitleaks is installed locally
2. Fall back to Docker if gitleaks is not found
3. Run the scan with the configuration in `gitleaks.toml`

### Running in Jenkins

The Jenkinsfile is configured to:
1. Automatically run on all pull requests
2. Use Docker to run gitleaks (if local installation not available)
3. Generate a JSON report (`gitleaks-report.json`)
4. Fail the build if secrets are detected

### Configuration Files

- **Jenkinsfile**: Jenkins pipeline definition with gitleaks integration
- **gitleaks.toml**: Gitleaks configuration with custom rules and allowlist
- **.gitleaksignore**: Ignore file for false positives (fingerprint-based)
- **.gitignore**: Excludes build artifacts and reports from version control

## Gitleaks Configuration

The `gitleaks.toml` file includes:
- Custom rules for detecting various secret types (AWS, GitHub, Slack, etc.)
- Allowlist to exclude false positives (e.g., gitleaks-report.json)

## Jenkins Pipeline Stages

1. **Info**: Display branch and PR information
2. **Checkout**: Clone the repository
3. **Setup**: Install Python dependencies (if any)
4. **PR secret-scan and tests**: Run gitleaks and pytest on PRs
5. **Branch build & publish**: Full build for non-PR branches

## Troubleshooting

### Docker Image Version Issues

If you encounter errors like "manifest not found", ensure the Docker image version is correct:
- Use format: `zricethezav/gitleaks:v{VERSION}` (note the 'v' prefix)
- Check available versions at: https://hub.docker.com/r/zricethezav/gitleaks/tags

### Common Commands

```bash
# Check gitleaks version
docker run --rm zricethezav/gitleaks:v8.18.4 version

# Run scan manually with verbose output
docker run --rm -v "$PWD":/src zricethezav/gitleaks:v8.18.4 detect \
  --source /src \
  --config /src/gitleaks.toml \
  --verbose \
  --exit-code 1

# View the scan report
cat gitleaks-report.json | python3 -m json.tool
```

## Requirements

- Jenkins with Docker support
- Docker installed on Jenkins agents
- OR gitleaks binary installed locally

## Contributing

When adding new rules to `gitleaks.toml`, ensure you:
1. Test the rule against sample secrets
2. Add appropriate tags for categorization
3. Document the rule with a clear description
