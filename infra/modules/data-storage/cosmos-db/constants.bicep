import { InternalProps } from './types.bicep'

@sys.export()
var DefaultProps InternalProps = {
  databaseAccountOfferType: 'Standard'
  disableLocalAuth: false
  publicNetworkAccess: 'Enabled'
  disableKeyBasedMetadataWriteAccess: true
  locations: [
    {
      locationName: 'placeholder' // Will be replaced with actual location in main.bicep
      failoverPriority: 0
    }
  ]
}
