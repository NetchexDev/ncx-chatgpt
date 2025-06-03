import { InternalProps } from './types.bicep'

@sys.export()
var DefaultProps InternalProps = {
  allowSharedKeyAccess: true
  publicNetworkAccess: 'Enabled'
  minimumTlsVersion: 'TLS1_2'
  isHnsEnabled: false
  accessTier: 'Hot'
  allowBlobPublicAccess: false
}
