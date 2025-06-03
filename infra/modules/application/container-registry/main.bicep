import { CoreConfiguration } from '../../types.bicep'
import { Sku, Props, Outputs } from './types.bicep'
import { DefaultConfiguration } from './constants.bicep'

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
  identity: { type: 'SystemAssigned' }
  tags: core.?tags

  sku: sku

  properties: union(DefaultConfiguration, props)
}

@sys.secure()
output core Outputs = {
  id: containerRegistry.id
  loginServer: containerRegistry.properties.loginServer
  identity: containerRegistry.identity.principalId
}

@sys.description('The Container Registry resource.')
output res resource = containerRegistry
