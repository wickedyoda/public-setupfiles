# Security Scanning

This repository runs automated security scans on every pull request to `main`.

## What's Scanned

| Scan | Tool | Frequency | What It Checks | Blocking |
|------|------|-----------|----------------|----------|
| Secret Scanning | Trufflehog | On push/PR + weekly | Detects leaked credentials, API keys, tokens in all repository files | ✅ Yes |
| ShellCheck | ShellCheck | On every PR/push | Security + linting issues in `.sh` scripts | ✅ Yes |
| ShellCheck (Legacy) | ludeeus/shellicopter | On every PR/push | Additional shell script checks | ❌ No |
| CodeQL | GitHub CodeQL | On every PR/push | SAST for Python — detects injection, hardcoded secrets, insecure code patterns | ✅ Yes |
| Python Dependencies | `pip-audit` | On every PR/push | Known CVEs in `requirements.txt` files | ❌ No |
| Docker Images | Docker Scout (Trivy) | On every PR/push | Critical/HIGH CVEs in Dockerfiles | ❌ No |

## Workflow Files

- `.github/workflows/shellcheck.yml` — ShellCheck linting (blocking) on all `.sh` files
- `.github/workflows/secret-scanning.yml` — Trufflehog secret scanning (blocking) on all files, runs weekly
- `.github/workflows/security-scans.yml` — ShellCheck (legacy), pip-audit, Docker Scout
- `.github/workflows/codeql.yml` — CodeQL SAST analysis
- `.github/secret_scanning.yml` — GitHub-native secret scanning exclusion patterns

## Required Checks on `main`

Branch protection requires the following checks to pass before merging:
- `ShellCheck` — shellcheck.yml workflow
- `CodeQL` — codeql.yml workflow
- `Trufflehog Secret Scanning` — secret-scanning.yml workflow

## Enabling Push Protection (GitHub-native)

1. Go to **Settings** → **Advanced Security** → **Enable** "Secret Protection"
2. Enable **"Push protection"** under Secret Protection
3. Optionally enable:
   - **Non-provider patterns** — detect private keys, connection strings
   - **Validity checks** — verify if detected secrets are still active

## Failing Builds

When a security scan fails on a PR, GitHub will post check results directly on the PR. All contributors must address security findings before the PR can be merged (enforced via branch protection rules on `main`).

### Secret scanning failures

If Trufflehog detects a potential secret, the CI will fail and the `results.sarif` file will be uploaded to the **Security** tab. Review findings and either:
- Rotate the exposed secret immediately
- Add the path to `.github/secret_scanning.yml` exclusions if it's a false positive (e.g., an example file with placeholder values)
