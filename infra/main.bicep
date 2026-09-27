param location string = resourceGroup().location
param shareQuotaGiB int = 1024
param globalTags object = {
  workload: 'storage-migration'
  managedBy: 'azure-devops'
}

type MigrationProject = {
  name: string
  description: string
  storageMoverName: string
  storageMoverDescription: string
  storageAccountName: string
  shareCount: int
}

@description('Each entry maps one migration project and one destination storage account. Use 5 entries with shareCount 60 to create 300 shares total.')
param projects MigrationProject[]

module projectDeployments './modules/project.bicep' = [for project in projects: {
  name: 'deploy-${project.name}'
  params: {
    location: location
    storageMoverName: project.storageMoverName
    storageMoverDescription: project.storageMoverDescription
    projectName: project.name
    projectDescription: project.description
    storageAccountName: project.storageAccountName
    shareCount: project.shareCount
    shareQuotaGiB: shareQuotaGiB
    tags: globalTags
  }
}]

output projectCount int = length(projects)
output shareCounts array = [for p in projects: int(p.shareCount)]
output storageMoverIds array = [for (p, index) in projects: projectDeployments[index].outputs.storageMoverResourceId]
output storageAccountIds array = [for (p, index) in projects: projectDeployments[index].outputs.storageAccountResourceId]
