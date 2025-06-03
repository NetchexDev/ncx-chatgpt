import { CoreConfiguration } from '../../types.bicep'
import { Sku, Props, Outputs } from './types.bicep'
import { DefaultProps } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Cognitive service.')
param core CoreConfiguration

@sys.description('The SKU for the Cognitive service. Defaults to `S0`.')
param sku Sku = { name: 'S0' }

@sys.description('The resource configuration for the Cognitive service. See `DefaultConfiguration` for defaults.')
param props Props

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: core.name
  location: core.location
  tags: core.?tags

  kind: props.kind
  sku: sku

  properties: union(DefaultProps, { customSubDomainName: core.name }, props.?properties ?? {})
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

@sys.secure()
output core Outputs = {
  id: cognitiveService.id
  keys: [
    cognitiveService.listKeys().key1
    cognitiveService.listKeys().key2
  ]
  endpoint: cognitiveService.properties.endpoint
}

@sys.description('The Cognitive Service resource.')
output res resource = cognitiveService
