import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs, Sku } from './types.bicep'
import { DefaultProps } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Storage Account service.')
param core CoreConfiguration

@sys.description('The SKU for the Storage Account. Defaults to Standard_LRS.')
param sku Sku = {
  name: 'Standard_LRS'
}

@sys.description('The resource configuration for the Storage Account service.')
param props Props

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: core.name
  location: core.location
  tags: core.?tags

  kind: props.?kind ?? 'StorageV2'
  sku: sku

  properties: union(DefaultProps, props.?properties ?? {})

  resource blobServices 'blobServices' = {
    name: 'default'

    properties: {
      containerDeleteRetentionPolicy: {
        days: 7
        enabled: true
      }
    }

    resource containers 'containers' = [
      for container in props.?containers ?? []: {
        name: container.name
        properties: {
          publicAccess: container.?publicAccess ?? 'None'
        }
      }
    ]
  }
}

@sys.secure()
output core Outputs = {
  id: storageAccount.id
  blobEndpoint: storageAccount.properties.primaryEndpoints.blob
  keys: [
    storageAccount.listKeys().keys[0].value
    storageAccount.listKeys().keys[1].value
  ]
}

@sys.description('The Storage Account resource.')
output res resource = storageAccount
