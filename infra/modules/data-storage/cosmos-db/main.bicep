import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs } from './types.bicep'
import { DefaultProps } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Cosmos DB service.')
param core CoreConfiguration

@sys.description('The resource configuration for the Cosmos DB service.')
param props Props

var updatedProps = {
  locations: [
    {
      locationName: core.location
      failoverPriority: 0
    }
  ]
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2025-05-01-preview' = {
  name: core.name
  location: core.location
  tags: core.?tags

  kind: 'GlobalDocumentDB'

  properties: union(DefaultProps, updatedProps, props.?properties ?? {})

  resource database 'sqlDatabases' = {
    name: props.databaseName
    properties: {
      resource: {
        id: props.databaseName
      }
    }

    resource containers 'containers' = [
      for container in props.?containers ?? []: {
        name: container.name
        properties: {
          resource: {
            id: container.name
            partitionKey: {
              paths: container.partitionKeyPaths
              kind: container.partitionKeyKind ?? 'Hash'
            }
          }
        }
      }
    ]
  }
}

@sys.secure()
output core Outputs = {
  id: cosmosDbAccount.id
  keys: [
    cosmosDbAccount.listKeys().primaryMasterKey
    cosmosDbAccount.listKeys().secondaryMasterKey
  ]
  endpoint: cosmosDbAccount.properties.documentEndpoint
  connectionString: 'AccountEndpoint=${cosmosDbAccount.properties.documentEndpoint};AccountKey=${cosmosDbAccount.listKeys().primaryMasterKey};'
}

@sys.description('The Cosmos DB Account resource.')
output res resource = cosmosDbAccount
