import { LogAnalyticsWorkspaceProps, ApplicationInsightsProps } from './types.bicep'

@sys.export()
var DefaultLogAnalyticsProps LogAnalyticsWorkspaceProps = {
  sku: { name: 'PerGB2018' }
  retention: 60
  publicNetworkIngestion: 'Enabled'
  publicNetworkQuery: 'Enabled'
}

@sys.export()
var DefaultApplicationInsightsProps ApplicationInsightsProps = {
  applicationType: 'web'
  publicNetworkIngestion: 'Enabled'
  publicNetworkQuery: 'Enabled'
}
