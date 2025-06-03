import { InternalProps } from './types.bicep'

@sys.export()
var DefaultProps InternalProps = {
  publicNetworkAccess: 'Enabled'
  disableLocalAuth: false
}
