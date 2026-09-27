param location string
param storageMoverName string
param storageMoverDescription string = ''
param projectName string
param projectDescription string = ''
param storageAccountName string
@minValue(1)
@maxValue(5000)
param shareCount int
@minValue(1)
@maxValue(102400)
param shareQuotaGiB int = 1024
param tags object = {}

resource storageMover 'Microsoft.StorageMover/storageMovers@2024-07-01' = {
  name: storageMoverName
  location: location
  tags: union(tags, {
    project: projectName
  })
  properties: {
    description: storageMoverDescription
  }
}

resource project 'Microsoft.StorageMover/storageMovers/projects@2024-07-01' = {
  parent: storageMover
  name: projectName
  properties: {
    description: projectDescription
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: union(tags, {
    project: projectName
  })
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    largeFileSharesState: 'Enabled'
  }
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-05-01' = [for i in range(0, shareCount): {
  parent: fileService
  name: 'share${padLeft(string(i + 1), 3, '0')}'
  properties: {
    enabledProtocols: 'SMB'
    accessTier: 'TransactionOptimized'
    shareQuota: shareQuotaGiB
  }
}]

output storageMoverResourceId string = storageMover.id
output projectResourceId string = project.id
output storageAccountResourceId string = storageAccount.id
output createdShareCount int = shareCount
