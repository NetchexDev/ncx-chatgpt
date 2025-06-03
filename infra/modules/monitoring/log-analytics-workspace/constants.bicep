import { Props } from './types.bicep'

@sys.export()
var DefaultProps Props = {
  sku: 'PerGB2018'
  retention: 30
  publicNetworkIngestion: 'Enabled'
  publicNetworkQuery: 'Enabled'
}
