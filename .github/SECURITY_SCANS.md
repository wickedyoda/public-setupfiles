# Security Scanning

This repository runs automated security scans on every pull request to `main`.

## What's Scanned

| Scan | Tool | Frequency | What It Checks |
|------|------|-----------|----------------|
| Secret Scanning | GitHub Secret Scanning | On push/PR + push protection | Detects leaked credentials, API keys, tokens in code, issues, PRs, wikis |
| ShellCheck | `ludeeus/shellicopter` (via `actions/checkout`) | On every PR/push | Security + linting issues in `.sh` scripts |
| CodeQL | GitHub CodeQL | On every PR/push | SAST for Python — detects injection, hardcoded secrets, insecure code patterns |
| Python Dependencies | `pip-audit` | On every PR/push | Known CVEs in `requirements.txt` files |
| Docker Images | Docker Scout | On every PR/push | Critical CVEs in Dockerfiles |

## Workflow Files

- `.github/workflows/security-scans.yml` — ShellCheck, pip-audit, Docker Scout
- `.github/workflows/codeql.yml` — CodeQL SAST analysis
- `.github/secret_scanning.yml` — Exclusions for secret scanning

## Enabling Secret Scanning & Push Protection

1. Go to **Settings** → **Advanced Security** → **Enable** "Secret Protection"
2. Enable **"Push protection"** under Secret Protection
3. Optionally enable:
   - **Non-provider patterns** — detect private keys, connection strings
   - **Validity checks** — verify if detected secrets are still active

## Failing Builds

When a security scan fails on a PR, GitHub will post check results directly on the PR. All contributors must address security findings before the PR can be merged (enforced via branch protection rules on `main`).
