# LAB 12 — Project 27: SamsITConcepts Enterprise Storage CI/CD

**Complete GitHub-compatible hands-on lab**: Bicep infrastructure, four isolated Azure Storage environments (Dev, QA, Stage, Prod), working static web application, GitHub Actions OIDC pipeline, CLI deployment/verification/cleanup, Azure Portal manual, architecture diagrams, tests and troubleshooting.

## Architecture
See [architecture diagrams](diagrams/architecture.md). GitHub Actions validates code and Bicep, authenticates with Entra ID via OIDC, deploys storage with Bicep, uploads the static app to `$web`, and verifies its HTTPS endpoint.

## Quick start (Azure Cloud Shell Bash)
```bash
az account set --subscription '<subscription-id>'
export LOCATION=centralindia # or your subscription's allowed region
export SUFFIX=abc12345       # globally unique lowercase alphanumeric 3-12 chars
# Before upload, grant your user Storage Blob Data Contributor; see docs/CLI_LAB.md
bash scripts/deploy.sh dev
bash scripts/verify.sh dev
```

## GitHub Actions
Read [OIDC setup](docs/GITHUB_OIDC.md). Push to `main` for automatic Dev deployment; manually dispatch QA, Stage, Prod. GitHub environments can require approvals.

## Documentation
- [Azure Portal manual](docs/PORTAL_LAB.md)
- [CLI lab manual](docs/CLI_LAB.md)
- [OIDC setup](docs/GITHUB_OIDC.md)
- [Test scenarios](docs/TEST_SCENARIOS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Cost and security](docs/COST_AND_SECURITY.md)

## Test locally
```bash
python3 -m unittest discover -s tests -v
az bicep build --file infra/main.bicep
```

## Cleanup
```bash
bash scripts/cleanup.sh dev
bash scripts/cleanup.sh qa
bash scripts/cleanup.sh stage
bash scripts/cleanup.sh prod
```

## Limitations
This is a **functional static website + infrastructure CI/CD lab**, not a document-upload API or private enterprise document repository. Static websites are public. It has not been live-deployed to your subscription. See security notes before production use.

## License
MIT. Training use by SamsITConcepts.
