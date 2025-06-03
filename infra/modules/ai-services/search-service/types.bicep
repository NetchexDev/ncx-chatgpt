@sys.export()
@sys.description('The SKU for the Search service. Defaults to `standard`.')
type Sku = resourceInput<'Microsoft.Search/searchServices@2025-05-01'>.sku

@sys.export()
@sys.description('The properties to set on the Search service resource.')
type Props = {
  @sys.description('Disable local authentication for the Search service. Defaults to `false`.')
  disableLocalAuth: resourceInput<'Microsoft.Search/searchServices@2025-05-01'>.properties.disableLocalAuth?

  @sys.description('The number of partitions for the Search service. Defaults to `1`.')
  partitionCount: resourceInput<'Microsoft.Search/searchServices@2025-05-01'>.properties.partitionCount?

  @sys.description('Public network access for the Search service. Defaults to `Enabled`.')
  @sys.allowed(['Enabled', 'Disabled'])
  publicNetworkAccess: resourceInput<'Microsoft.Search/searchServices@2025-05-01'>.properties.publicNetworkAccess?

  @sys.description('The number of replicas for the Search service. Defaults to `1`.')
  replicaCount: resourceInput<'Microsoft.Search/searchServices@2025-05-01'>.properties.replicaCount?
}

@sys.export()
@sys.description('The output properties of the Search service resource.')
type Outputs = {
  @sys.description('The resource ID of the Search service.')
  id: resourceOutput<'Microsoft.Search/searchServices@2025-05-01'>.id

  @sys.description('The name of the Search service.')
  keys: string[]

  @sys.description('The endpoint of the Search service.')
  endpoint: resourceOutput<'Microsoft.Search/searchServices@2025-05-01'>.properties.endpoint

  // HACK Could not include `resource` in the output type due to Bicep limitations.
}
