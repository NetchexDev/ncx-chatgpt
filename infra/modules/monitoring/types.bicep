@sys.export()
type LogAnalyticsWorkspaceProps = {
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
type ApplicationInsightsProps = {
  @sys.description('The type of application being monitored by the Application Insights resource.')
  applicationType: 'web' | 'other' | null

  @sys.description('The public network access for ingestion. Defaults to `Enabled`.')
  publicNetworkIngestion: 'Enabled' | 'Disabled' | null

  @sys.description('The public network access for query. Defaults to `Enabled`.')
  publicNetworkQuery: 'Enabled' | 'Disabled' | null
}

@sys.export()
type MonitoringProps = {
  @sys.description('The properties for the Log Analytics Workspace.')
  logAnalytics: LogAnalyticsWorkspaceProps?

  @sys.description('The properties for the Application Insights.')
  appInsights: ApplicationInsightsProps?
}

@sys.export()
type LogAnalyticsWorkspaceOutputs = {
  @sys.description('The ID of the Log Analytics Workspace resource.')
  id: resourceOutput<'Microsoft.OperationalInsights/workspaces@2025-02-01'>.id

  name: string
  resourceGroup: string

  @sys.description('The customer ID of the Log Analytics Workspace.')
  customerId: resourceOutput<'Microsoft.OperationalInsights/workspaces@2025-02-01'>.properties.customerId
}

@sys.export()
type ApplicationInsightsOutputs = {
  @sys.description('The ID of the Application Insights resource.')
  id: resourceOutput<'Microsoft.Insights/components@2020-02-02'>.id

  name: string
  resourceGroup: string

  @sys.description('The instrumentation key for the Application Insights resource.')
  instrumentationKey: resourceOutput<'Microsoft.Insights/components@2020-02-02'>.properties.InstrumentationKey

  @sys.description('The connection string for the Application Insights resource.')
  connectionString: resourceOutput<'Microsoft.Insights/components@2020-02-02'>.properties.ConnectionString
}

@sys.export()
type MonitoringOutputs = {
  @sys.description('Outputs from the Log Analytics Workspace.')
  logAnalytics: LogAnalyticsWorkspaceOutputs

  @sys.description('Outputs from the Application Insights.')
  appInsights: ApplicationInsightsOutputs
}
