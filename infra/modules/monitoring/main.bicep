import { CoreConfiguration } from '../types.bicep'
import { MonitoringOutputs } from './types.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the monitoring resources.')
param core CoreConfiguration

// Create Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: 'law-${core.name}'
  location: core.location
  tags: core.?tags

  properties: {
    // TODO minor parameterization of below properties
    sku: { name: 'PerGB2018' }
    retentionInDays: 42
  }
}

// Create Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'insht-${core.name}'
  location: core.location
  tags: core.?tags

  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Output the resources
@sys.description('Outputs from the monitoring resources.')
output resources MonitoringOutputs = {
  logAnalytics: {
    id: logAnalyticsWorkspace.id
    name: logAnalyticsWorkspace.name
    resourceGroup: resourceGroup().name
    customerId: logAnalyticsWorkspace.properties.customerId
  }
  appInsights: {
    id: applicationInsights.id
    name: applicationInsights.name
    resourceGroup: resourceGroup().name
    instrumentationKey: applicationInsights.properties.InstrumentationKey
    connectionString: applicationInsights.properties.ConnectionString
  }
}
