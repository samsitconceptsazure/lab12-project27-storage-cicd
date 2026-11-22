# LAB 12 — Enterprise Azure Storage | Student Lab Manual

**Audience:** Cloud engineering students. **Time:** 2–3 days (10–16 hours). **Subscription:** Standard Azure preferred. **Important:** some operations require paid capacity, quota, special permissions, and supported regions. Execute one optional cost-bearing experiment at a time.

## Prerequisites
- Azure CLI and Bicep (`az bicep install`); Bash; Python 3.10+; subscription Contributor for deployment, plus User Access Administrator / RBAC Administrator to assign roles.
- An Entra user or workload identity with Blob, Queue and Table data roles. Storage management-plane Contributor is NOT equivalent to data-plane roles.
- Azure Cloud Shell for deployment. The web portal runs locally or in a trusted development environment, not as a publicly exposed production app.
- Review [Microsoft Azure Storage documentation](https://learn.microsoft.com/azure/storage/) for regional support, current pricing, lifecycle rules, and premium offerings.

## 0. Prepare the lab
```bash
az login # omit in Cloud Shell
az account set --subscription '<subscription ID>'
export RG=rg-lab12-storage LOCATION=centralindia SUFFIX=abc12345
az bicep build --file infra/main.bicep
bash scripts/deploy.sh
```
Use a unique suffix, 5–12 lowercase alphanumeric characters. In Portal: Resource groups > rg-lab12-storage > Resources. Check account, blob container, Azure Files share, queue and table.

**Data-plane roles:** Portal > Storage account > Access control (IAM) > Add role assignment. Give your signed-in user `Storage Blob Data Contributor`, `Storage Queue Data Contributor`, and `Storage Table Data Contributor` at the lab resource group (or storage account) scope. Wait several minutes for propagation. For a user object ID, set `PRINCIPAL_OBJECT_ID` and run `bash scripts/roles.sh` if you have role assignment privileges. The role script is written for user principals; adjust principal type for service principals. Verify with `az role assignment list`.

## 1. Storage account: design, redundancy, security
**Portal:** Storage accounts > account > Overview, Configuration, Redundancy, Networking, Encryption, Access control (IAM).
**CLI:**
```bash
A="stlab12${SUFFIX}"
az storage account show -g "$RG" -n "$A" --query '{name:name,kind:kind,sku:sku.name,tls:minimumTlsVersion,public:publicNetworkAccess,https:enableHttpsTrafficOnly}' -o json
az storage account show -g "$RG" -n "$A" --query 'encryption' -o json
```
**Test:** HTTPS enforced; minimum TLS 1.2; blob anonymous public access disabled; Microsoft-managed encryption at rest. Record screenshot. **Replication lab:** LRS single datacenter, ZRS zones, GRS geo replication, RA-GRS secondary read access (supported SKU/region only). To test, deploy a second disposable account with another suffix and `REDUNDANCY=Standard_ZRS` or `Standard_GRS` / `Standard_RAGRS`. Avoid repeatedly converting the main account. Redundancy is not backup; regional failover testing may be disruptive and is excluded from the inexpensive baseline. Observe redundancy in Portal; do not assume immediate secondary read access.

## 2. Blob storage, versions, soft delete, archive
**Portal:** Storage account > Data storage > Containers > documents > Upload. Under Data protection inspect versioning and soft delete.
```bash
A="stlab12${SUFFIX}"
printf 'Version 1\n' > /tmp/lab12-blob.txt
az storage blob upload --account-name "$A" --container-name documents --name training.txt --file /tmp/lab12-blob.txt --auth-mode login --overwrite
printf 'Version 2\n' > /tmp/lab12-blob.txt
az storage blob upload --account-name "$A" --container-name documents --name training.txt --file /tmp/lab12-blob.txt --auth-mode login --overwrite
az storage blob list --account-name "$A" -c documents --include v --auth-mode login -o table
az storage blob delete --account-name "$A" -c documents -n training.txt --auth-mode login
az storage blob list --account-name "$A" -c documents --include d,v --auth-mode login -o table
```
**Recovery:** Portal > documents > Show deleted blobs / Versions; restore or promote a prior version. Verify content. Soft delete, versioning and lifecycle behavior differ; archive blobs cannot be read until rehydrated and incur retrieval costs. Blob tiers: Hot, Cool, Archive (also Cold where supported). For the lab, view tiers in Portal, and avoid archiving important data. Lifecycle policies run asynchronously, not immediately.

## 3. Azure Files SMB and NFS
**Portal:** Storage account > File shares > teamfiles. Upload a sample file; create snapshot from share's Snapshots action; delete sample; restore from snapshot where supported.
```bash
A="stlab12${SUFFIX}"
az storage share-rm show -g "$RG" --storage-account "$A" --name teamfiles -o json
az storage share-rm snapshot -g "$RG" --storage-account "$A" --name teamfiles -o json
```
**SMB:** From a VM or workstation with TCP 445 access, mount `\\<account>.file.core.windows.net\teamfiles` (Windows) or CIFS (Linux), using a supported identity method. For a simple lab, a storage account key can be used on an isolated machine; do not commit it or paste it into shared logs. Azure Files identity-based SMB auth requires a configured directory source (AD DS, Microsoft Entra Kerberos, or Microsoft Entra Domain Services, depending on platform and supported scenario), share-level RBAC and file ACLs; ordinary Azure login alone does not automatically mount an SMB share.
**NFS:** The baseline share is SMB. NFS 4.1 requires a separate supported Premium FileStorage configuration, appropriate VNet/private networking, and a Linux client; NFS is not enabled on this baseline account. See optional premium exercise. **Backup:** Azure Backup for Azure Files uses a Recovery Services vault/backup policy and is separate from snapshots. Test restore to an alternate path before claiming recoverability.

## 4. SAS: service, account, user delegation
**Security:** SAS is a bearer credential. Use minimal permissions, HTTPS, short expirations, and never print/share production tokens. Shared-key SAS requires shared key access; user delegation SAS requires Entra credentials and `Storage Blob Delegator` at storage account or broader scope (plus data permissions as appropriate).
```bash
A="stlab12${SUFFIX}"
EXPIRY=$(date -u -d '+15 minutes' '+%Y-%m-%dT%H:%MZ')
# For Linux/GNU date. On macOS use: date -u -v+15M '+%Y-%m-%dT%H:%MZ'
# Service SAS (uses account key, output is secret):
az storage blob generate-sas --account-name "$A" --container-name documents --name training.txt --permissions r --expiry "$EXPIRY" --https-only --auth-mode key --as-user false -o tsv
# Account SAS (key-based):
az storage account generate-sas --account-name "$A" --services b --resource-types sco --permissions rl --expiry "$EXPIRY" --https-only -o tsv
# User delegation SAS (Entra):
az storage blob generate-sas --account-name "$A" --container-name documents --name training.txt --permissions r --expiry "$EXPIRY" --https-only --auth-mode login --as-user -o tsv
```
**Tests:** Compare scope (blob vs service/account), permissions, expiration, and inability to write with read-only SAS. Use a currently existing blob (re-upload `training.txt` if deleted). If `--auth-mode key` cannot retrieve a key, a storage key must be provided securely; role-based permissions may restrict key retrieval. Account SAS cannot be user delegation SAS. Never put SAS tokens in GitHub.

## 5. Lifecycle management
**Portal:** Storage account > Data management > Lifecycle management > View policy. The baseline Bicep policy applies to `documents/` block blobs: Cool after 30 days, Archive after 180 days, delete snapshots and old versions after 365 days. Age thresholds are based on actual blob timestamps; no immediate tier transition is expected.
```bash
az storage account management-policy show -g "$RG" --account-name "stlab12${SUFFIX}" -o json
```
**Test:** Confirm the policy is enabled, matches the container prefix and is scoped to block blobs. Record that archived blobs have retrieval delays/costs. Test deletion of old versions only with disposable sample data; legal holds/immutability may prevent deletion.

## 6. Queue Storage: send, receive, process
**Portal:** Storage account > Data storage > Queues > workitems > Add message. Inspect message count. Queue messages are for asynchronous processing; receiving a message does not automatically delete it.
```bash
A="stlab12${SUFFIX}"
az storage message put --account-name "$A" --queue-name workitems --content 'process-order-001' --auth-mode login
az storage message peek --account-name "$A" --queue-name workitems --auth-mode login -o json
az storage message get --account-name "$A" --queue-name workitems --auth-mode login -o json
```
**Test:** `get` makes a message temporarily invisible; to complete processing delete it with the message ID and pop receipt returned by `get` (the local Flask portal demonstrates this). If the visibility timeout expires before deletion, the message becomes visible again. Design consumers to be idempotent; poison messages need retry/dead-letter handling implemented by the application (Azure Queue Storage has no native dead-letter queue like Service Bus).

## 7. Table Storage: partitioning and queries
**Portal:** Storage account > Data storage > Tables > LabInventory. Use Storage Explorer or the demo portal to insert and query entities. Table Storage uses PartitionKey and RowKey as the composite entity key.
**CLI:** Azure CLI table entity commands may require the `storage-preview` extension and supported authentication mode; the supplied Python app uses the supported `azure-data-tables` SDK with Entra credentials.
```bash
export STORAGE_ACCOUNT="stlab12${SUFFIX}"
python3 -m venv .venv
.venv/bin/pip install -r app/requirements.txt
.venv/bin/python - <<'PYCODE'
import os
from azure.identity import DefaultAzureCredential
from azure.data.tables import TableServiceClient
name=os.environ['STORAGE_ACCOUNT']
client=TableServiceClient(f'https://{name}.table.core.windows.net',credential=DefaultAzureCredential())
t=client.get_table_client('LabInventory')
t.upsert_entity({'PartitionKey':'classA','RowKey':'item001','description':'SSD stock','quantity':5})
print(list(t.query_entities("PartitionKey eq 'classA'")))
PYCODE
```
**Test:** Same RowKey in different partitions is allowed; duplicate key in the same partition requires update/upsert. Design partitions to avoid hotspots. This is Azure Table Storage, not Azure Cosmos DB for Table.

## 8. Managed Disks: Standard vs Premium
**Portal:** Disks > Create > Standard HDD, Standard SSD, or Premium SSD where supported. Use an unattached disposable disk for inspection; actual IOPS/latency benchmarks require a VM and disk attachment.
```bash
export DEPLOY_DISK=true
bash scripts/deploy.sh
az disk show -g "$RG" -n "disk-lab12-${SUFFIX}" --query '{name:name,sku:sku.name,size:diskSizeGb,state:diskState}' -o json
# Optional Premium SSD disk, incurs charges even unattached:
az disk create -g "$RG" -n "disk-premium-${SUFFIX}" -l "$LOCATION" --size-gb 4 --sku Premium_LRS
```
**Test:** Compare SKU, provisioned size, estimated monthly charges and disk state. Managed Disks are block storage attached to VMs, NOT part of the general-purpose storage account's blob/file/queue/table APIs. Standard/Premium performance is SKU- and size-dependent. Delete unused disks immediately.

## 9. Private endpoints and firewalls
**Portal:** Storage account > Networking > Public network access and Private endpoint connections. The optional `scripts/private-endpoint.sh` creates a blob private endpoint, VNet and private DNS zone. A client inside the VNet is needed to prove private resolution and connectivity.
```bash
bash scripts/private-endpoint.sh
# On a VM inside the VNet, resolve and test:
# nslookup stlab12<SUFFIX>.blob.core.windows.net
# Expect private IP for blob endpoint, then test SDK/CLI data access.
```
**Tests:** Public endpoint with open firewall should work with RBAC; restrict firewall to a permitted IP and verify blocked external client; private endpoint should work from VNet client with proper DNS. Cloud Shell is NOT automatically inside your VNet. Private endpoints are separate per subresource (blob, file, queue, table). Do not disable public access until you have a working private administration path. Private endpoints, DNS, VM and outbound traffic can incur costs.

## 10. Premium Azure Files and AD integration
Optional: `DEPLOY_PREMIUM_FILES=true bash scripts/deploy.sh` creates a Premium FileStorage account and SMB share (100 GiB provisioned; significant recurring cost). Compare throughput/latency and pricing to standard. For AD integration, configure a supported identity source and share-level RBAC/ACLs, then test an authorized vs unauthorized user from a domain-joined client. NFS requires a separately created NFS share and compatible VNet client; do not assume SMB and NFS can be enabled interchangeably on one share.

## 11. Local application
```bash
export SUFFIX=abc12345
bash scripts/run-app.sh
# Visit http://127.0.0.1:8000 (on the machine running Flask)
```
In Cloud Shell, use **Web preview** for port 8000 if available; Cloud Shell sessions are ephemeral. Portal uses DefaultAzureCredential and RBAC. Do not expose the teaching app to the public internet: it intentionally has no user login or CSRF protection. Use it to upload small files, enqueue/process work, and insert/query inventory entities.

## 12. Verification and cleanup
```bash
bash scripts/verify.sh
export CONFIRM_DELETE="$RG"
bash scripts/cleanup.sh
```
Resource-group deletion is destructive and asynchronous. Confirm no backup vaults, retained snapshots, or other chargeable resources remain. Some protected resources may need extra deletion steps. Record resource costs before and after lab.

## Student deliverables
Architecture diagram; deployment transcript; screenshots of all resource types; SAS access matrix (no tokens); Queue processing results; Table partition query; Blob version/restore; Files snapshot/restore; redundancy and SKU comparison; network access evidence; lifecycle policy; cost report; cleanup evidence.
