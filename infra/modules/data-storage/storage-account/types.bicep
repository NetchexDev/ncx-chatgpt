@sys.export()
@sys.description('The SKU for the Storage Account.')
type Sku = {
  @sys.description('The SKU name for the Storage Account.')
  name: 'Standard_LRS' | 'Standard_GRS' | 'Standard_RAGRS' | 'Standard_ZRS' | 'Premium_LRS' | 'Premium_ZRS'
}

@sys.export()
@sys.description('The configuration for a blob container.')
type Container = {
  @sys.description('The name of the container.')
  name: string

  @sys.description('The public access level for the container. Default is "None".')
  publicAccess: 'None' | 'Blob' | 'Container'?
}

@sys.export()
@sys.description('The configuration for Storage Account.')
type Props = {
  @sys.description('The properties to set on the Storage Account resource.')
  properties: InternalProps?

  @sys.description('The containers to create in the blob service.')
  containers: Container[]?

  @sys.description('Whether to disable local authentication for access. Default is false.')
  disableLocalAuth: bool?

  @sys.description('The kind of storage account. Default is "StorageV2".')
  kind: 'StorageV2' | 'BlobStorage' | 'BlockBlobStorage' | 'FileStorage' | 'Storage'?
}

@sys.export()
@sys.description('The internal properties to set on the Storage Account resource.')
type InternalProps = {
  @sys.description('Whether shared key access is allowed. Default is true.')
  allowSharedKeyAccess: bool?

  @sys.description('Public network access for the Storage Account. Default is "Enabled".')
  publicNetworkAccess: 'Disabled' | 'Enabled'?

  @sys.description('The minimum TLS version required. Default is "TLS1_2".')
  minimumTlsVersion: 'TLS1_0' | 'TLS1_1' | 'TLS1_2'?

  @sys.description('Whether hierarchical namespace is enabled. Default is false.')
  isHnsEnabled: bool?

  @sys.description('Access tier for the storage account. Default is "Hot".')
  accessTier: 'Hot' | 'Cool'?

  @sys.description('Whether blob public access is enabled. Default is false.')
  allowBlobPublicAccess: bool?
}

@sys.export()
@sys.description('The output properties of the Storage Account resource.')
type Outputs = {
  @sys.description('The resource ID of the Storage Account.')
  id: resourceOutput<'Microsoft.Storage/storageAccounts@2024-01-01'>.id

  @sys.description('The primary endpoint for the blob service.')
  blobEndpoint: resourceOutput<'Microsoft.Storage/storageAccounts@2024-01-01'>.properties.primaryEndpoints.blob

  @sys.description('The access keys for the Storage Account.')
  keys: string[]
}
