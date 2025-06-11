import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs } from './types.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Container App Environment.')
param core CoreConfiguration

@sys.description('Configuration for the Container App Environment resource. See `DefaultConfiguration` for defaults.')
param props Props

var lawParts string[] = split(props.analyticsWorkspaceId, '/')

resource analyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  scope: resourceGroup(lawParts[4]) /* analyticsWorkspaceRGName */
  name: lawParts[8] /* analyticsWorkspaceName */
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2025-01-01' = {
  name: core.name
  location: core.location
  tags: core.?tags

  properties: union(
    {
      appLogsConfiguration: {
        destination: 'log-analytics'
        logAnalyticsConfiguration: {
          customerId: analyticsWorkspace.properties.customerId
          sharedKey: analyticsWorkspace.listKeys().primarySharedKey
        }
      }
    },
    props
  )
}

output core Outputs = {
  id: containerAppEnvironment.id
  name: containerAppEnvironment.name
  defaultDomain: containerAppEnvironment.properties.defaultDomain
  staticIp: containerAppEnvironment.properties.staticIp
}
