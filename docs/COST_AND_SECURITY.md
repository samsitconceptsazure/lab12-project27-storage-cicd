# Cost Optimization and Security Notes

## Cost
- Four small Standard_LRS StorageV2 accounts can be inexpensive, but not free. Charges vary by region, stored data, operations, and egress.
- Avoid GRS/RA-GRS until the replication lesson. Do not store large sample files.
- No VM, AKS, database, Private Endpoint, App Service, or Log Analytics workspace is deployed.
- Soft delete keeps deleted data for 7 days and can increase capacity charges.
- Delete all four resource groups after class; check billing in Azure Cost Management.

## Security model and limitations
- GitHub OIDC avoids client secrets and uses short-lived credentials.
- HTTPS and TLS 1.2 are required. Anonymous blob container access is disabled.
- Static website files in `$web` are PUBLIC by design, including `deployment.json`; do not put secrets, customer data, or internal information there.
- `allowSharedKeyAccess: true` is retained for broad static-website compatibility, although uploads use Microsoft Entra ID (`--auth-mode login`). Harden this setting if compatible with your chosen deployment pattern.
- The storage account uses public network access for the lab. Production systems should evaluate private networking, CDN/Front Door, WAF, and origin protection.
- Production deployment should use scoped identities and separate deploy/runtime permissions. Subscription-wide Contributor is a teaching shortcut, not a production recommendation.
- Four environments are isolated by resource group and storage account, but not by separate subscriptions or tenants.
