import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs } from 'types.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Container App.')
param core CoreConfiguration

@sys.description('The resource configuration for the Container App.')
param props Props

resource containerApp 'Microsoft.App/containerApps@2025-02-02-preview' = {
  name: core.name
  location: core.location
  tags: core.?tags

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${props.pullIdentityId}': {}
    }
  }

  properties: {
    managedEnvironmentId: props.containerAppEnvironmentId
    configuration: {
      ingress: {
        external: true
        targetPort: props.?containerPort ?? 3000
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          identity: props.pullIdentityId
          server: props.acrUri
        }
      ]
    }
    template: {
      containers: [
        {
          name: core.name
          image: props.containerImage
          env: props.?environmentVariables ?? []
        }
      ]
      scale: {
        minReplicas: props.?minReplicas ?? 1
      }
    }
  }
}

output core Outputs = {
  id: containerApp.id
  fqdn: containerApp.properties.configuration.ingress.fqdn
  latestRevisionName: containerApp.properties.latestRevisionName
}
