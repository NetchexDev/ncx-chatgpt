import { CoreConfiguration } from '../../types.bicep'
import { Sku, Props, Outputs } from './types.bicep'
import { DefaultConfiguration } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Search service.')
param core CoreConfiguration

@sys.description('The SKU for the Search service. Defaults to `Standard`.')
param sku Sku = { name: 'Standard' }

@sys.description('Configuration for the Search service resource. See `DefaultConfiguration` for defaults.')
param props Props = {}

resource searchService 'Microsoft.Search/searchServices@2025-05-01' = {
  name: core.name
  location: core.location
  tags: core.?tags

  sku: sku

  properties: union(DefaultConfiguration, props)
}

@sys.secure()
output core Outputs = {
  id: searchService.id
  keys: [
    searchService.listKeys().key1
    searchService.listKeys().key2
  ]
  endpoint: searchService.properties.endpoint
}

@sys.description('The Search service resource.')
output res resource = searchService
