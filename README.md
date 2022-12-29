# GitHub Actions

A collection of reusable GitHub Action workflows and bicep templates.

## Quick Start

### Workflows

To use a workflow, add a reference to the workflow in your repository's `.github/workflows` directory. For example, to use the `build-go.yml` workflow, add the following to your repository's `.github/workflows` directory:

```yaml
jobs:
  build:
    uses: credibil/github-actions/.github/workflows/build-go.yaml@main
    secrets: inherit

  staging:
    needs: build
    uses: credibil/github-actions/.github/workflows/deploy-go.yaml@main
    secrets: inherit
    with:
      environment: staging
      image-tag: ${{ needs.build.outputs.image-tag }}
```

### Bicep templates

Bicep templates are reused as Bicep modules. The template must be deployed to Azure as a Template Spec (or to Azure Container Registry). The `bicep/config.sh` script contains example commands for updating template specs.

To use a template as a module, add a reference to the template in your Bicep file. For example, to use the `bicep/containerapp.bicep` template, add the following to your Bicep file:

```bicep
module app 'ts:4e6ec3dd-7f2a-4679-86fc-1cc8297b48cd/app-ticc-stg-ae-rg/ts-containerapp:1.0' = {
  name: '${appName}-app'
  params: {
    location: location
    managedEnvName: 'cae-ticc-${env}'
    managedIdName: 'id-ticc-${env}'
    appName: appName
    imageName: imageName
    ghcrUser: ghcrUser
    ghcrPat: ghcrPat
  }
}
```

Alternatively, you can create an alias to simplify template naming:

```bicep
module app 'ts/AppSpecs:ts-containerapp:1.0' = {
```

To create an alias, add the following configuration to `bicepconfig.json` located in the same directory as your Bicep files.

```json
{
  "moduleAliases": {
    "ts": {
      "AppSpecs": {
        "subscription": "4e6ec3dd-7f2a-4679-86fc-1cc8297b48cd",
        "resourceGroup": "app-ticc-stg-ae-rg"
      }
    }
  }
}
```

### Further reading

<https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep>
