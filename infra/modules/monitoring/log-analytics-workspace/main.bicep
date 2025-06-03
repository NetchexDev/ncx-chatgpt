import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs } from './types.bicep'
import { DefaultProps } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Log Analytics Workspace.')
param core CoreConfiguration

param props Props?

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: core.name
  location: core.location
  tags: core.?tags

  properties: union(DefaultProps, props ?? {})
}

@sys.secure()
output core Outputs = {
  id: logAnalyticsWorkspace.id
  customerId: logAnalyticsWorkspace.properties.customerId
  key: logAnalyticsWorkspace.listSharedKeys().primarySharedKey
}
