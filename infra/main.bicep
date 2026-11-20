targetScope = 'resourceGroup'
@allowed(['dev','qa','stage','prod'])
param environment string
param location string = resourceGroup().location
@minLength(3)
@maxLength(12)
param suffix string
@allowed(['Standard_LRS','Standard_GRS','Standard_RAGRS','Standard_ZRS'])
param skuName string = 'Standard_LRS'
param tags object = {}
var storageName = 'st${environment}${suffix}'
resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
 name: storageName
 location: location
 tags: union(tags, { environment: environment, workload: 'lab12-project27' })
 sku: { name: skuName }
 kind: 'StorageV2'
 properties: {
  accessTier: 'Hot'
  allowBlobPublicAccess: false
  allowSharedKeyAccess: true // Required for static website and $web uploads in this lab; see security tradeoffs
  minimumTlsVersion: 'TLS1_2'
  supportsHttpsTrafficOnly: true
  networkAcls: { defaultAction: 'Allow' }
 }
}
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
 parent: storage
 name: 'default'
 properties: {
  deleteRetentionPolicy: { enabled: true, days: 7 }
  containerDeleteRetentionPolicy: { enabled: true, days: 7 }
  staticWebsite: { enabled: true, indexDocument: 'index.html', error404Document: 'index.html' }
 }
}
output storageAccountName string = storage.name
output staticWebsiteUrl string = storage.properties.primaryEndpoints.web
