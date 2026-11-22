# SamsITConcepts — LAB 12: Enterprise Azure Storage Complete Capstone

**GitHub-ready project** for Azure Storage Account, Blob Storage, Azure Files, SAS, lifecycle, Queue Storage, Table Storage, Managed Disks, redundancy, security, protection, networking, premium tiers and automation.

## What is implemented
- Bicep baseline: StorageV2, private blob container, SMB file share, queue, table, versioning, soft delete, lifecycle management and encryption; optional Standard managed disk and Premium FileStorage share.
- Flask teaching portal: Blob upload/list, Queue send/process, Table entity insert/query, with Microsoft Entra `DefaultAzureCredential`.
- CLI deployment/verification, optional blob private endpoint + DNS, RBAC helper, cleanup.
- GitHub Actions workflow: automatic validation on push/PR, manual OIDC-authenticated baseline deployment.
- Detailed Portal + CLI manual, test matrix, troubleshooting/cost guide, Mermaid diagrams.

## Quick start
```bash
az account set --subscription '<YOUR_SUBSCRIPTION_ID>'
export RG=rg-lab12-storage LOCATION=centralindia SUFFIX=abc12345
bash scripts/deploy.sh
# Assign data roles to the current user through Azure Portal IAM, then wait for propagation
bash scripts/verify.sh
bash scripts/run-app.sh
```
Open `http://127.0.0.1:8000` on the machine running Flask. If using Azure Cloud Shell, use Web Preview for port 8000. Do not publish the demo application on the public internet; it has no end-user authentication or CSRF protection.

## GitHub Actions setup
1. Push the *contents* of this folder to the repository root (including hidden `.github/workflows/deploy.yml`).
2. Create an Entra app registration and service principal; add a GitHub Actions **environment** federated credential: issuer `https://token.actions.githubusercontent.com`, subject `repo:<OWNER>/<REPO>:environment:lab`, audience `api://AzureADTokenExchange`.
3. In GitHub > Settings > Environments, create `lab`. Set environment variables `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_RESOURCE_GROUP`, `AZURE_LOCATION`, `STORAGE_SUFFIX`.
4. Assign the service principal **Contributor** on the target resource group (pre-create the resource group or grant deployment rights to create it). No client secret is required. The pipeline does not upload application data; grant data-plane roles separately for portal use.
5. Push to `main` to validate. Actions > LAB12 Enterprise Storage IaC > Run workflow to deploy. Confirm Azure resources.

## Safety and scope
- Optional private networking requires a client in the VNet to verify; the provided script creates only a **blob** private endpoint. Separate endpoints are needed for file, queue and table.
- SMB AD integration, NFS, Azure Backup, immutable retention, secondary-region failover, and live disk benchmarking are guided **advanced manual exercises**, not automatically provisioned. They may incur substantial costs or require directory services, VMs, and privileged access.
- Key-based SAS exercises require shared-key access; the baseline permits this for teaching. For hardened production accounts prefer user delegation SAS and evaluate disabling shared-key access.
- Some account configurations/SKUs are region- and subscription-dependent. Standard Azure subscription recommended.
- Run `CONFIRM_DELETE="$RG" bash scripts/cleanup.sh` when finished.

Start with [Student lab manual](docs/PORTAL-AND-CLI-GUIDE.md), then [test matrix](docs/TEST-CASES.md), [troubleshooting](docs/TROUBLESHOOTING.md), and [architecture](diagrams/architecture.mmd).
