import { CoreConfiguration } from '../../types.bicep'
import { Sku, Props } from './types.bicep'
import { DefaultConfiguration } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Search service.')
param core CoreConfiguration

@sys.description('The SKU for the Search service. Defaults to `standard`.')
param sku Sku = { name: 'standard' }

@sys.description('Configuration for the Search service resource. See `DefaultConfiguration` for defaults.')
param props Props = {}

#disable-next-line use-recent-api-versions // ! 2025-05-01 is not available in all regions yet
resource searchService 'Microsoft.Search/searchServices@2025-02-01-Preview' = {
  name: core.name
  location: core.location
  tags: core.?tags

  sku: sku

  properties: union(DefaultConfiguration, props)
}


output id string = searchService.id

@secure()
output key string = searchService.listAdminKeys().primaryKey

output endpoint string = searchService.properties.endpoint
