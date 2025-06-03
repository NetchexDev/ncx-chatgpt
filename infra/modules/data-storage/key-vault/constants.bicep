import { InternalProps } from './types.bicep'

@sys.export()
var DefaultProps InternalProps = {
  enableRbacAuthorization: true
  enabledForDeployment: false
  enabledForDiskEncryption: true
  enabledForTemplateDeployment: false
  enableSoftDelete: true
  softDeleteRetentionInDays: 60
  enablePurgeProtection: true
  publicNetworkAccess: 'Enabled'
}
