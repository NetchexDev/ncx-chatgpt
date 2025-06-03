import { CoreConfiguration } from '../../types.bicep'
import { Sku, Props } from './types.bicep'
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


output id string = searchService.id

@secure()
output key string = searchService.listKeys().key1

output endpoint string = searchService.properties.endpoint
