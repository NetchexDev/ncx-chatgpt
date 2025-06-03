import { CoreConfiguration } from '../../types.bicep'
import { Props, Outputs, Sku } from './types.bicep'
import { DefaultProps } from './constants.bicep'

targetScope = 'resourceGroup'

@sys.description('The core configuration for the Key Vault service.')
param core CoreConfiguration

@sys.description('The SKU for the Key Vault. Defaults to `Standard`.')
param sku Sku = {
  family: 'A'
  name: 'Standard'
}

@sys.description('The resource configuration for the Key Vault service.')
param props Props

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: core.name
  location: core.location
  tags: core.?tags

  properties: union(
    DefaultProps,
    {
      sku: sku
      tenantId: subscription().tenantId
    },
    props.?properties ?? {}
  )

  resource secrets 'secrets' = [
    for secret in props.?secrets ?? []: {
      name: secret.name
      properties: {
        contentType: secret.?contentType ?? 'text/plain'
        value: secret.value
      }
    }
  ]
}

output core Outputs = {
  id: keyVault.id
  uri: keyVault.properties.vaultUri
}
