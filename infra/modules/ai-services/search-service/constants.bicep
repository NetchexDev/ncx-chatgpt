import { Props } from './types.bicep'

@sys.export()
var DefaultConfiguration Props = {
  disableLocalAuth: false
  partitionCount: 1
  publicNetworkAccess: 'Enabled'
  replicaCount: 1
}
