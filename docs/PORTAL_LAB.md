# Azure Portal Click-by-Click Lab

1. Open https://portal.azure.com and choose the intended subscription.
2. Navigate to **Resource groups** → **Create**. Enter `rg-lab12-p27-dev` and an allowed region; select **Review + create** → **Create**.
3. Navigate to **Storage accounts** → **Create**. Select the resource group, use `stdev<suffix>` as the globally unique name, choose **Standard**, **StorageV2**, **LRS**, and a permitted region.
4. On **Advanced**, require secure transfer, minimum TLS 1.2, disable anonymous blob access, and leave account keys enabled for the static website lab. Review and create.
5. Open the account → **Data management** → **Data protection**. Enable blob and container soft delete for 7 days and save.
6. Open **Data management** → **Static website** → Enable. Index document `index.html`, error document `index.html`. Save.
7. Open **Access control (IAM)** → **Add role assignment** → **Storage Blob Data Contributor** → select your identity → **Review + assign**. Wait for propagation.
8. Open **Containers** → `$web`. Upload `app/index.html` and a generated `app/deployment.json` (run `python3 scripts/create_manifest.py dev stdev<suffix> > app/deployment.json`).
9. Open **Static website** and copy the primary endpoint. Visit it in a browser and confirm the environment label and PASS health check.
10. Repeat steps 2–9 for QA, Stage and Prod, with distinct names and resource groups.
11. In GitHub repository **Settings** → **Environments**, create `dev`, `qa`, `stage`, `prod`. Add required reviewers to stage/prod when supported by repository plan.
12. Configure OIDC and environment variables as in `GITHUB_OIDC.md`, then open **Actions** → **Storage CI-CD** → **Run workflow** and select a target environment.
13. Inspect the workflow validation, deployment, and verification logs. Confirm each target environment's website displays the correct label.
14. Delete lab resource groups after testing.

**Note:** The portal-only workflow is a manual equivalent. The supplied Bicep and GitHub Actions workflows are the reproducible source of truth.
