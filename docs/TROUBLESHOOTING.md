# Troubleshooting

- **AuthorizationPermissionMismatch / 403 on upload:** Grant Storage Blob Data Contributor to signed-in user or GitHub service principal; wait for RBAC propagation. Management-plane Contributor alone does not grant blob data access.
- **StorageAccountAlreadyTaken:** Choose another lowercase unique suffix and redeploy.
- **RequestDisallowedByPolicy:** Check Azure for Students allowed locations, SKUs, and resource-type policies; select a permitted region.
- **InvalidTemplate / Bicep compilation:** Run `az bicep upgrade` and `az bicep build --file infra/main.bicep`.
- **AADSTS / No matching federated identity:** Verify issuer `https://token.actions.githubusercontent.com`, subject `repo:OWNER/REPO:environment:ENV`, audience `api://AzureADTokenExchange`, and exact repository/environment spelling.
- **GitHub environment variables missing:** Configure all five environment variables for each environment, not just repository-level variables.
- **Website 404 / blank:** Confirm static website enabled and `index.html` plus `deployment.json` uploaded to `$web` container; allow a short propagation delay.
- **Deployment manifest FAIL:** Check `/deployment.json` and browser developer console; verify file content is valid JSON.
- **No static website endpoint:** Check the storage account's Static website setting and Bicep deployment output.
- **Cost spikes:** Review storage redundancy, capacity, transactions, retained soft-deleted data, and Azure Monitor settings. Remove lab RGs.
- **Azure policy denies shared keys:** This demo uses static website and allows shared keys; adapt to a hardened App Service/Front Door architecture if policy forbids shared key access.
