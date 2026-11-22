targetScope = 'resourceGroup'
@description('Globally unique lowercase suffix, 5-12 letters or digits')
@minLength(5)
@maxLength(12)
param suffix string
param location string = resourceGroup().location
@allowed(['Standard_LRS','Standard_ZRS','Standard_GRS','Standard_RAGRS'])
param redundancy string = 'Standard_LRS'
param deployDisk bool = false
param deployPremiumFiles bool = false
param deployPrivateNetworking bool = false
param adminIpCidr string = ''
var accountName = 'stlab12${suffix}'
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
 name: accountName
 location: location
 sku: { name: redundancy }
 kind: 'StorageV2'
 properties: {
  minimumTlsVersion: 'TLS1_2'
  supportsHttpsTrafficOnly: true
  allowBlobPublicAccess: false
  allowSharedKeyAccess: true // Required for account/service SAS and Azure Files SMB exercises; production should assess disabling it
  publicNetworkAccess: 'Enabled'
  networkAcls: { defaultAction: 'Allow' bypass: 'AzureServices' }
  encryption: { services: { blob: { enabled: true } file: { enabled: true } } keySource: 'Microsoft.Storage' }
 }
}
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
 parent: storage
 name: 'default'
 properties: {
  isVersioningEnabled: true
  deleteRetentionPolicy: { enabled: true days: 7 }
  containerDeleteRetentionPolicy: { enabled: true days: 7 }
  changeFeed: { enabled: true }
 }
}
resource docs 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
 parent: blobService
 name: 'documents'
 properties: { publicAccess: 'None' }
}
resource fileservice 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
 parent: storage
 name: 'default'
 properties: { shareDeleteRetentionPolicy: { enabled: true days: 7 } }
}
resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = {
 parent: fileservice
 name: 'teamfiles'
 properties: { shareQuota: 20 enabledProtocols: 'SMB' }
}
resource queueservice 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
 parent: storage
 name: 'default'
}
resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01' = {
 parent: queueservice
 name: 'workitems'
}
resource tableservice 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
 parent: storage
 name: 'default'
}
resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
 parent: tableservice
 name: 'LabInventory'
}
resource lifecycle 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
 parent: storage
 name: 'default'
 properties: {
  policy: { rules: [
   { name: 'tier-old-block-blobs' enabled: true type: 'Lifecycle' definition: {
     filters: { blobTypes: ['blockBlob'] prefixMatch: ['documents/'] }
     actions: { baseBlob: { tierToCool: { daysAfterModificationGreaterThan: 30 } tierToArchive: { daysAfterModificationGreaterThan: 180 } } snapshot: { delete: { daysAfterCreationGreaterThan: 365 } } version: { delete: { daysAfterCreationGreaterThan: 365 } } }
   } }
  ] }
 }
}
resource disk 'Microsoft.Compute/disks@2023-10-02' = if (deployDisk) {
 name: 'disk-lab12-${suffix}'
 location: location
 sku: { name: 'Standard_LRS' }
 properties: { creationData: { createOption: 'Empty' } diskSizeGB: 4 }
}
resource premium 'Microsoft.Storage/storageAccounts@2023-05-01' = if (deployPremiumFiles) {
 name: 'pf${suffix}'
 location: location
 sku: { name: 'Premium_LRS' }
 kind: 'FileStorage'
 properties: { minimumTlsVersion: 'TLS1_2' supportsHttpsTrafficOnly: true }
}
resource premiumFileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = if (deployPremiumFiles) {
 parent: premium
 name: 'default'
}
resource premiumShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = if (deployPremiumFiles) {
 parent: premiumFileService
 name: 'premiumshare'
 properties: { shareQuota: 100 enabledProtocols: 'SMB' }
}
// Private endpoint is provisioned through scripts/private-endpoint.sh after deployment.
// deployPrivateNetworking is retained as an explicit lab intent flag, not an auto-deployed network.
output storageAccountName string = storage.name
output diskName string = deployDisk ? disk.name : ''
output premiumAccountName string = deployPremiumFiles ? premium.name : ''
output privateNetworkingRequested bool = deployPrivateNetworking
