@export()
@sys.description('Default configuration for the Container Registry.')
var DefaultConfiguration = {
  adminUserEnabled: false
  policies: {
    exportPolicy: { status: 'enabled' }
    azureADAuthenticationAsArmPolicy: { status: 'enabled' }
  }
  dataEndpointEnabled: false
  publicNetworkAccess: 'Enabled'
  networkRuleBypassOptions: 'AzureServices'
  zoneRedundancy: 'Disabled'
  anonymousPullEnabled: false
}

@export()
@sys.description('Default SKU for the Container Registry.')
var DefaultSku = {
  name: 'Basic'
}

@sys.export()
var acrPullRoleDefinitionId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
