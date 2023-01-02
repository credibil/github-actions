// ----------------------------------------------------------------------------
// Deploys a Container App
// ----------------------------------------------------------------------------

@description('Location of the Container Apps environment')
param location string = resourceGroup().location

// @allowed([
//   'dev'
//   'stg'
//   'prd'
// ])
@description('Container Apps environment')
param appEnv string

@description('Container App HTTP port')
param appName string

@description('Container App image name')
param imageTag string

@description('Container App target port')
param targetPort int = 8080

@secure()
@description('GitHub container registry user')
param ghcrUser string

@secure()
@description('GitHub container registry personal access token')
param ghcrPat string

@description('Custom param list for the container app')
param appParams string = ''

// get a reference to the container apps environment
resource managedEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: 'cae-${appEnv}'
}

// get a reference to the container apps environment
resource managedId 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'id-${appEnv}'
}

// -----------------------------
// Deploy Container App
// -----------------------------
resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: 'ca-${appName}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedId.id}': {}
    }
  }
  properties: {
    environmentId: managedEnv.id
    configuration: {
      activeRevisionsMode: 'single'
      dapr: {
        appId: appName
        appPort: 8080
        appProtocol: 'http'
        enabled: true
        enableApiLogging: false
      }
      ingress: {
        external: true
        targetPort: targetPort
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        // ipSecurityRestrictions: [
        //   {
        //     action: 'string'
        //     description: 'string'
        //     ipAddressRange: 'string'
        //     name: 'string'
        //   }
        // ]
      }
      registries: [
        {
          server: 'ghcr.io'
          username: ghcrUser
          passwordSecretRef: 'ghcr-pat'
        }
      ]
      secrets: [
        {
          name: 'ghcr-pat'
          value: ghcrPat
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: imageTag
          resources: {
            cpu: any('0.5')
            memory: '1Gi'
          }
          env: [for v in split(appParams, ','): {
            name: trim(split(v, '=')[0])
            value: trim(split(v, '=')[1])
          }]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 2
        rules: [
          {
            name: 'httpscalingrule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
          {
            name: 'cpuscalingrule'
            custom: {
              type: 'cpu'
              metadata: {
                type: 'Utilization'
                value: '75'
              }
            }
          }
          {
            name: 'memoryscalingrule'
            custom: {
              type: 'memory'
              metadata: {
                type: 'Utilization'
                value: '75'
              }
            }
          }
        ]
      }
    }
  }
}

output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
output containerAppId string = containerApp.id
