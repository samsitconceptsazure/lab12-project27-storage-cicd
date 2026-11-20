# GitHub Actions OIDC Setup

## Identity setup
1. In Azure Portal, open **Microsoft Entra ID** → **App registrations** → **New registration**; create `lab12-p27-gha` (single tenant). Record Application (client) ID and Directory (tenant) ID.
2. Open the app registration → **Certificates & secrets** → **Federated credentials** → **Add credential** → **GitHub Actions deploying Azure resources**. Enter organization, repository, **Environment** entity type, and `dev` environment. Save. Repeat for `qa`, `stage`, `prod` (each must have its own credential).
3. In **Subscriptions** → your subscription → **Access control (IAM)**, assign the app's service principal **Contributor** at the subscription or scoped resource group level. The included script creates resource groups, so subscription-level permission is needed for the default workflow. In production, pre-create groups and scope permissions narrowly.
4. Assign the app's service principal **Storage Blob Data Contributor** at subscription or each target storage account scope. This is required for `az storage blob upload-batch --auth-mode login`.
5. In GitHub **Settings** → **Environments**, create `dev`, `qa`, `stage`, `prod`. Add the following **environment variables** to EACH environment: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `STORAGE_SUFFIX`, `AZURE_LOCATION`.
6. Use the SAME globally unique `STORAGE_SUFFIX` for all four environments. The resulting account names are `stdev<suffix>`, `stqa<suffix>`, `ststage<suffix>`, `stprod<suffix>`; all must be 3–24 chars total, lowercase letters and digits only.
7. Protect `stage` and `prod` with required reviewers where your GitHub plan supports it. OIDC environment credentials are tied to their exact environment names.
8. Push to `main` to deploy Dev automatically. To deploy QA, Stage, or Prod, use **Actions** → **Storage CI-CD** → **Run workflow** and choose the environment.

## Security caveat
The sample grants Contributor at subscription scope for first-time automated RG creation. This is broader than ideal. For production, provision RGs separately, assign Contributor and Storage Blob Data Contributor only to specific resource groups/accounts, and remove broad subscription roles.
