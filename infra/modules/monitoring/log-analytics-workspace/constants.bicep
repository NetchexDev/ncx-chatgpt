import { Props } from './types.bicep'

@sys.export()
var DefaultProps Props = {
  sku: 'Standard'
  retention: 30
  publicNetworkIngestion: 'Enabled'
  publicNetworkQuery: 'Enabled'
}
