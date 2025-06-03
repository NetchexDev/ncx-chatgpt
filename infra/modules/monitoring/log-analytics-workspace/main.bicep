import { CoreConfiguration } from '../../types.bicep'
import { Props } from './types.bicep'
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


output id string = logAnalyticsWorkspace.id


output customerId string = logAnalyticsWorkspace.properties.customerId

@secure()
output key string = logAnalyticsWorkspace.listSharedKeys().primarySharedKey
