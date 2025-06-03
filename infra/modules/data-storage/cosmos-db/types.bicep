@sys.export()
@sys.description('The SKU for the Cosmos DB account.')
type Sku = {
  @sys.description('The name of the SKU.')
  name: 'Standard'
}

@sys.export()
@sys.description('The properties for a Cosmos DB container.')
type Container = {
  @sys.description('The name of the container.')
  name: string

  @sys.description('The partition key paths for the container.')
  partitionKeyPaths: string[]

  @sys.description('The kind of partition key. Defaults to `Hash`.')
  partitionKeyKind: 'Hash' | 'Range'?
}

@sys.export()
@sys.description('The configuration for Cosmos DB.')
type Props = {
  @sys.description('The name of the database to create.')
  databaseName: string

  @sys.description('The containers to create in the database.')
  containers: Container[]?

  @sys.description('The properties to set on the Cosmos DB resource.')
  properties: InternalProps?
}

@sys.export()
@sys.description('The internal properties to set on the Cosmos DB resource.')
type InternalProps = {
  @sys.description('The database account offer type. Defaults to `Standard`.')
  databaseAccountOfferType: string?

  @sys.description('Disable local authentication for the Cosmos DB service. Defaults to `false`.')
  disableLocalAuth: bool?

  @sys.description('Public network access for the Cosmos DB service. Defaults to `Enabled`.')
  publicNetworkAccess: 'Disabled' | 'Enabled'?

  @sys.description('Locations for the Cosmos DB account.')
  locations: {
    @sys.description('The location name.')
    locationName: string

    @sys.description('The failover priority.')
    failoverPriority: int
  }[]?

  @sys.description('Disable key-based metadata write access. Defaults to `true`.')
  disableKeyBasedMetadataWriteAccess: bool?
}

@sys.export()
@sys.description('The output properties of the Cosmos DB resource.')
type Outputs = {
  @sys.description('The resource ID of the Cosmos DB account.')
  id: resourceOutput<'Microsoft.DocumentDB/databaseAccounts@2025-05-01-preview'>.id

  @sys.description('The keys of the Cosmos DB account.')
  keys: string[]

  @sys.description('The endpoint of the Cosmos DB account.')
  endpoint: resourceOutput<'Microsoft.DocumentDB/databaseAccounts@2025-05-01-preview'>.properties.documentEndpoint

  @sys.description('The connection string of the Cosmos DB account.')
  connectionString: string
}
