import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs } from './types.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Container App Environment.')
param core CoreConfiguration

@sys.description('Configuration for the Container App Environment resource. See `DefaultConfiguration` for defaults.')
param props Props

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2025-01-01' = {
  name: core.name
  location: core.location
  tags: core.?tags
  identity: { type: 'SystemAssigned' }

  properties: union(
    {
      appLogsConfiguration: {
        destination: 'log-analytics'
        logAnalyticsConfiguration: {
          customerId: props.logAnalyticsConfiguration.customerId
          sharedKey: props.logAnalyticsConfiguration.key
        }
      }
    },
    props
  )
}

@sys.secure()
output core Outputs = {
  id: containerAppEnvironment.id
  name: containerAppEnvironment.name
  defaultDomain: containerAppEnvironment.properties.defaultDomain
  staticIp: containerAppEnvironment.properties.staticIp
}

@sys.description('The Container App Environment resource.')
output res resource = containerAppEnvironment
