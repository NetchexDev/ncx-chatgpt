
@sys.export()
type Props = {
  @sys.description('The resource ID of the Log Analytics Workspace to link with this Application Insights resource.')
  workspaceId: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-02-01'>.id

  @sys.description('The type of application being monitored by the Application Insights resource.')
  applicationType: 'web' | 'other' | null

  @sys.description('The public network access for ingestion. Defaults to `Enabled`.')
  publicNetworkIngestion: 'Enabled' | 'Disabled' | null

  @sys.description('The public network access for query. Defaults to `Enabled`.')
  publicNetworkQuery: 'Enabled' | 'Disabled' | null
}

@sys.export()
type Outputs = {
  @sys.description('The ID of the Application Insights resource.')
  id: resourceOutput<'Microsoft.Insights/components@2020-02-02'>.id

  @sys.description('The instrumentation key for the Application Insights resource.')
  instrumentationKey: resourceOutput<'Microsoft.Insights/components@2020-02-02'>.properties.InstrumentationKey

  @sys.description('The connection string for the Application Insights resource.')
  connectionString: resourceOutput<'Microsoft.Insights/components@2020-02-02'>.properties.ConnectionString
}

