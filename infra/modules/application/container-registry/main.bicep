import { CoreConfiguration } from '../../types.bicep'
import { Sku, Props } from './types.bicep'
import { DefaultConfiguration, acrPullRoleDefinitionId as AcrPull } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Container Registry.')
param core CoreConfiguration

@sys.description('The SKU for the Container Registry. Defaults to `Basic`.')
param sku Sku = { name: 'Basic' }

@sys.description('Configuration for the Container Registry resource. See `DefaultConfiguration` for defaults.')
param props Props = {}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: core.name
  location: core.location
  tags: core.?tags

  sku: sku

  properties: union(DefaultConfiguration, props)
}

resource acrPullManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: '${core.name}-acr-pull'
  location: core.location
  tags: core.?tags
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, 'acrpull', acrPullManagedIdentity.id)
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', AcrPull)
    principalId: acrPullManagedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output id string = containerRegistry.id
output loginServer string = containerRegistry.properties.loginServer
output acrPullIdentityId string = acrPullManagedIdentity.id
