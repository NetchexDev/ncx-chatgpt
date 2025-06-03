@export()
@sys.description('Container Registry SKU options.')
type Sku = {
  @sys.description('The SKU name for the Container Registry. Defaults to `Basic`.')
  name: 'Basic' | 'Standard' | 'Premium'
}

@export()
@sys.description('Properties for the Container Registry.')
type Props = {
  @sys.description('Whether admin user is enabled.')
  adminUserEnabled: bool?

  @sys.description('Policies for the Container Registry.')
  policies: {
    @sys.description('Export policy for the Container Registry.')
    exportPolicy: { status: 'enabled' | 'disabled' }?

    @sys.description('Azure AD authentication as ARM policy for the Container Registry.')
    azureADAuthenticationAsArmPolicy: { status: 'enabled' | 'disabled' }?
  }?

  @sys.description('Whether data endpoint is enabled.')
  dataEndpointEnabled: bool?

  @sys.description('Public network access for the Container Registry.')
  publicNetworkAccess: 'Enabled' | 'Disabled'?

  @sys.description('Network rule bypass options for the Container Registry.')
  networkRuleBypassOptions: 'AzureServices' | 'None'?

  @sys.description('Zone redundancy for the Container Registry.')
  zoneRedundancy: 'Enabled' | 'Disabled'?

  @sys.description('Whether anonymous pull is enabled.')
  anonymousPullEnabled: bool?
}

@export()
@sys.description('Outputs for the Container Registry.')
type Outputs = {
  @sys.description('The ID of the Container Registry.')
  id: string

  @sys.description('The login server of the Container Registry.')
  loginServer: string

  @sys.description('The principal ID of the Container Registry identity.')
  identity: string
}
