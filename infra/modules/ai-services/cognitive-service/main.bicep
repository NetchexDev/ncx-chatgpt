import { CoreConfiguration } from '../../types.bicep'
import { Sku, Props } from './types.bicep'
import { DefaultProps } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Cognitive service.')
param core CoreConfiguration

@sys.description('The SKU for the Cognitive service. Defaults to `S0`.')
param sku Sku = { name: 'S0' }

@sys.description('The resource configuration for the Cognitive service. See `DefaultConfiguration` for defaults.')
param props Props

param logAnalyticsWorkspaceId string?

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: core.name
  location: core.location
  tags: core.?tags

  kind: props.kind
  sku: sku

  properties: union(DefaultProps, {
    customSubDomainName: core.name
  }, props.?properties ?? {})
}

@sys.batchSize(1)
resource llm 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = [
  for deployment in props.?modelDeployments ?? []: {
    parent: cognitiveService
    name: deployment.name

    sku: deployment.sku

    properties: {
      model: deployment.model
      versionUpgradeOption: deployment.versionUpgradeOption ?? 'OnceCurrentVersionExpired'
    }
  }
]

resource diagnosticSettings 'microsoft.insights/diagnosticSettings@2016-09-01' =
  if (!empty(logAnalyticsWorkspaceId)) {
    name: 'service'
    scope: cognitiveService
    location: core.location
    properties: {
      workspaceId: logAnalyticsWorkspaceId
      logs: [
        {
          category: 'Audit'
          enabled: true
          retentionPolicy: {
            days: 30
            enabled: true
          }
        }
        {
          category: 'RequestResponse'
          enabled: true
          retentionPolicy: {
            days: 30
            enabled: true
          }
        }
      ]
      metrics: [
        {
          timeGrain: 'PT1M'
          enabled: true
          retentionPolicy: {
            days: 30
            enabled: true
          }
        }
      ]
    }
  }

output id string = cognitiveService.id

@secure()
output key string = cognitiveService.listKeys().key1

output endpoint string = cognitiveService.properties.endpoint

output res resource = cognitiveService
