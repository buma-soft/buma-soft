# Azure Storage Mover migration scaffolding

This repository now contains a Bicep + Azure DevOps pipeline baseline for migrating **300 SMB shares** with **Azure Storage Mover**, split across **5 projects**. A **5-appliance** rollout is assumed but appliance registration/assignment is handled outside this template.

## Files

- `infra/main.bicep` - top-level deployment for 5 projects
- `infra/modules/project.bicep` - reusable per-project module
- `infra/parameters/prod.parameters.json` - sample production parameters
- `azure-pipelines.yml` - Azure DevOps validation + deployment pipeline

## What gets deployed

Per project:

- 1 Azure Storage Mover resource
- 1 Storage Mover project
- 1 Azure Storage Account (standard, large file shares enabled)
- 60 Azure File Shares (SMB)

Total in default configuration: **5 projects x 60 shares = 300 shares**.

## Appliance mapping

Appliances are expected to be registered and assigned to Storage Mover endpoints/jobs separately.
This template does **not** create source endpoints, destination endpoints, appliance/agent bindings, or migration job definitions.
It focuses on project and destination Azure File Share infrastructure.

## Azure DevOps setup

Update pipeline variables in `azure-pipelines.yml`:

- `azureServiceConnection`
- `resourceGroupName`
- `location` (optional override)

If placeholder values are not replaced, the pipeline skips Azure CLI validation/deployment steps by design.

Pipeline stages:

1. **Validate**: Bicep build + `az deployment group what-if`
2. **Deploy** (main/master branches only): `az deployment group create`

Feature branches run the **Validate** stage only.

## Deploy manually

```bash
az deployment group create \
  --resource-group <resource-group> \
  --template-file infra/main.bicep \
  --parameters @infra/parameters/prod.parameters.json location=<location>
```
