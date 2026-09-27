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
param projects MigrationProject[] = [
  {
    name: 'project01'
    description: 'Migration project 01'
    storageMoverName: 'stmv-project01'
    storageMoverDescription: 'Storage Mover for project 01'
    storageAccountName: 'stmvp01files001'
    shareCount: 60
  }
  {
    name: 'project02'
    description: 'Migration project 02'
    storageMoverName: 'stmv-project02'
    storageMoverDescription: 'Storage Mover for project 02'
    storageAccountName: 'stmvp02files001'
    shareCount: 60
  }
  {
    name: 'project03'
    description: 'Migration project 03'
    storageMoverName: 'stmv-project03'
    storageMoverDescription: 'Storage Mover for project 03'
    storageAccountName: 'stmvp03files001'
    shareCount: 60
  }
  {
    name: 'project04'
    description: 'Migration project 04'
    storageMoverName: 'stmv-project04'
    storageMoverDescription: 'Storage Mover for project 04'
    storageAccountName: 'stmvp04files001'
    shareCount: 60
  }
  {
    name: 'project05'
    description: 'Migration project 05'
    storageMoverName: 'stmv-project05'
    storageMoverDescription: 'Storage Mover for project 05'
    storageAccountName: 'stmvp05files001'
    shareCount: 60
  }
]

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
