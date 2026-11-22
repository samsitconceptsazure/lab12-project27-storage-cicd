# Troubleshooting and Cost Guide
| Symptom | Cause | Action |
|---|---|---|
| AuthorizationPermissionMismatch | Missing data-plane RBAC | Assign Blob/Queue/Table data roles and wait for propagation |
| AuthorizationFailed on role assignment | Missing role assignment privileges | Ask RBAC administrator |
| StorageAccountAlreadyTaken | Global name collision | Change SUFFIX |
| RequestDisallowedByPolicy | Subscription policy blocks location/SKU/type | Select permitted options |
| InvalidTemplate / Bicep failure | Unsupported SKU/region or template schema | Run `az bicep build`, inspect deployment operations |
| SAS 403 | Expired, wrong resource/permissions, key disallowed | Generate new short-lived SAS; check time and account settings |
| Private endpoint DNS resolves public IP | Wrong DNS link/client network | Test from VNet client; verify private DNS zone and link |
| SMB mount fails | Port 445 blocked, identity not configured | Check connectivity, AD/Entra Kerberos and share-level permissions |
| Queue repeats work | Visibility timeout elapsed | Delete using latest pop receipt; implement idempotency |
| Archive read fails | Rehydration required | Initiate rehydrate; account for time/cost |
| Disk benchmark unavailable | Disk unattached | Attach to supported VM; costs apply |
| GitHub OIDC AADSTS700213 | Federated subject mismatch | Match repo, branch/environment, issuer and audience exactly |
| GitHub workflow not shown | `.github/workflows` not at repo root | Move workflow files to root directory |

## Cost controls
- Baseline: one Standard_LRS StorageV2 account with small Blob, Queue, Table and SMB share usage; charges still apply for capacity and transactions.
- Avoid Premium Files, premium disks, GRS/RA-GRS, VMs, private endpoints and Recovery Services vault unless needed; these can materially increase costs.
- Keep test objects tiny and retention short; monitor archive retrieval and minimum retention charges.
- Portal > Cost Management > Cost analysis > Filter resource group. Set a budget/alert; budget alerts do not automatically stop charges.
- Always run `CONFIRM_DELETE="$RG" bash scripts/cleanup.sh` and confirm deletion.
- Current pricing and regional availability: https://azure.microsoft.com/pricing/details/storage/ and https://azure.microsoft.com/pricing/details/managed-disks/
