# Test Matrix and Evidence Sheet
| ID | Area | Action | Expected result | Evidence |
|---|---|---|---|---|
| T01 | Account | Inspect TLS/HTTPS/encryption | TLS 1.2, HTTPS, encrypted | JSON + screenshot |
| T02 | Blob | Upload twice same name | Version history | version IDs |
| T03 | Blob | Delete and restore | Recovered blob | before/after |
| T04 | Tiers | Inspect Hot/Cool/Archive | Tier rules and costs explained | portal screenshot |
| T05 | Lifecycle | Inspect management policy | 30/180/365-day rules | policy JSON |
| T06 | Files | Create SMB share and snapshot | Snapshot available | share screenshot |
| T07 | Files | Restore deleted sample from snapshot | Sample recovered | restored file |
| T08 | Files | Test NFS (optional) | Linux client mount or documented restriction | mount evidence |
| T09 | Identity | Test authorized vs unauthorized user | Deny without data role | CLI output |
| T10 | SAS | Read-only service SAS | Read allowed, write denied | redacted HTTP codes |
| T11 | SAS | Account SAS | Scope/permissions enforced | redacted HTTP codes |
| T12 | SAS | User delegation SAS | Entra-issued SAS read | redacted HTTP codes |
| T13 | Queue | Enqueue and peek | Message visible | message metadata |
| T14 | Queue | Receive and delete | Count decreases | log |
| T15 | Table | Insert and query partition | Correct entity returned | SDK output |
| T16 | Disks | Create Standard disk | SKU and size visible | disk JSON |
| T17 | Disks | Create Premium disk (optional) | SKU differs | disk JSON |
| T18 | Redundancy | Compare LRS/ZRS/GRS/RA-GRS | Supported differences documented | SKU table |
| T19 | Networking | Test public endpoint | Data access with RBAC | HTTP result |
| T20 | Networking | Test private endpoint (optional) | Private DNS resolution in VNet | nslookup |
| T21 | Firewall | Restrict allowed source (optional) | Unauthorized source blocked | HTTP 403 |
| T22 | Backup | Configure Azure Files backup (optional) | Recovery point and restore | vault evidence |
| T23 | Immutability | Configure test-only time-based policy | Protected write/delete restrictions | portal screenshot |
| T24 | CI/CD | Commit a Bicep change | GitHub validates and deploys | Actions log |
| T25 | Cleanup | Delete lab RG | Resources no longer exist | portal evidence |

**Immutability note:** Some immutability policies cannot be shortened or removed after locking. Use only a disposable container and never lock a policy in the baseline lab. For Azure Files identity-based SMB access, directory setup is an optional advanced exercise, not part of the default deployment.
