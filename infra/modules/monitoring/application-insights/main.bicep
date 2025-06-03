import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs } from './types.bicep'
import { DefaultProps } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Log Analytics Workspace.')
param core CoreConfiguration

param props Props

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: core.name
  location: core.location
  tags: core.?tags

  kind: props.?applicationType ?? DefaultProps.applicationType

  properties: union(DefaultProps, props)
}

output core Outputs = {
  id: applicationInsights.id
  instrumentationKey: applicationInsights.properties.InstrumentationKey
  connectionString: applicationInsights.properties.ConnectionString
}
