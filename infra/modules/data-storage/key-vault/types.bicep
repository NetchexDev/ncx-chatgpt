@sys.export()
@sys.description('The SKU for the Key Vault.')
type Sku = {
  @sys.description('The SKU family. Always "A".')
  family: string

  @sys.description('The SKU name for the Key Vault. Default is "standard".')
  name: 'Standard' | 'Premium'
}

@sys.export()
@sys.description('Secret configuration for Key Vault.')
type Secret = {
  @sys.description('The name of the secret.')
  name: string

  @sys.description('The content type of the secret.')
  contentType: string?

  @sys.description('The value of the secret.')
  value: string
}

@sys.export()
@sys.description('The configuration for Key Vault.')
type Props = {
  @sys.description('The properties to set on the Key Vault resource.')
  properties: InternalProps?

  @sys.description('The secrets to create in the Key Vault.')
  secrets: Secret[]?
}

@sys.export()
@sys.description('The internal properties to set on the Key Vault resource.')
type InternalProps = {
  @sys.description('Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Default is false.')
  enabledForDeployment: bool?

  @sys.description('Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Default is true.')
  enabledForDiskEncryption: bool?

  @sys.description('Whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Default is false.')
  enabledForTemplateDeployment: bool?

  @sys.description('Whether RBAC is used for authorization. Default is true.')
  enableRbacAuthorization: bool?

  @sys.description('Whether soft delete is enabled for this key vault. Default is true.')
  enableSoftDelete: bool?

  @sys.description('The number of days to retain deleted vaults and vault objects. Default is 90.')
  softDeleteRetentionInDays: int?

  @sys.description('Whether protection against purge is enabled for this key vault. Default is true.')
  enablePurgeProtection: bool?

  @sys.description('Public network access for the Key Vault. Default is "Enabled".')
  publicNetworkAccess: 'Disabled' | 'Enabled'?
}

@sys.export()
@sys.description('The output properties of the Key Vault resource.')
type Outputs = {
  @sys.description('The resource ID of the Key Vault.')
  id: resourceOutput<'Microsoft.KeyVault/vaults@2024-12-01-preview'>.id

  @sys.description('The URI of the Key Vault.')
  uri: resourceOutput<'Microsoft.KeyVault/vaults@2024-12-01-preview'>.properties.vaultUri
}
