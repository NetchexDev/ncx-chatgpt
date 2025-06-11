@sys.export()
type Props = {
  @sys.description('The SKU for the Log Analytics Workspace. Defaults to `PerGB2018`.')
  sku: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-02-01'>.properties.sku?

  @sys.description('The retention period for the Log Analytics Workspace in days. Defaults to `30`.')
  retention: int

  @sys.description('The public network access for ingestion. Defaults to `Enabled`.')
  publicNetworkIngestion: 'Enabled' | 'Disabled' | null

  @sys.description('The public network access for query. Defaults to `Enabled`.')
  publicNetworkQuery: 'Enabled' | 'Disabled' | null
}

@sys.export()
type Outputs = {
  @sys.description('The ID of the Log Analytics Workspace resource.')
  id: resourceOutput<'Microsoft.OperationalInsights/workspaces@2025-02-01'>.id

  @sys.description('The customer ID of the Log Analytics Workspace.')
  customerId: resourceOutput<'Microsoft.OperationalInsights/workspaces@2025-02-01'>.properties.customerId

  @sys.description('The primary shared key for the Log Analytics Workspace.')
  key: string
}
