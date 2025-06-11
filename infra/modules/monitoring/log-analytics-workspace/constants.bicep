import { Props } from './types.bicep'

@sys.export()
var DefaultProps Props = {
  sku: { name: 'PerGB2018' }
  retention: 60
  publicNetworkIngestion: 'Enabled'
  publicNetworkQuery: 'Enabled'
}
