// ----------------------------------------------------------------------------
// Exposes a Container App via an API gateway
// ----------------------------------------------------------------------------

@allowed([
  'dev'
  'stg'
  'prd'
])
@description('Environment short name')
param env string

@description('Container App HTTP port')
param backendNames string

@description('Container App ID')
param containerAppId string

@description('Container App FDQN')
param containerAppFqdn string

// get reference to API manager
resource apiManager 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: 'apim-ticc-${env}'
}

// create backend for service
resource backend 'Microsoft.ApiManagement/service/backends@2021-12-01-preview' = [for b in split(backendNames, ','): {
  name: b
  parent: apiManager
  properties: {
    url: 'https://${containerAppFqdn}'
    protocol: 'http'
    resourceId: '${environment().resourceManager}/${containerAppId}'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}]
