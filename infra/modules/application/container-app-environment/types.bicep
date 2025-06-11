@export()
@sys.description('Properties for the Container App Environment.')
type Props = {
  analyticsWorkspaceId: resourceInput<'Microsoft.OperationalInsights/workspaces@2025-02-01'>.id
}

@export()
@sys.description('Outputs for the Container App Environment.')
type Outputs = {
  @sys.description('The ID of the Container App Environment.')
  id: string

  @sys.description('The name of the Container App Environment.')
  name: string

  @sys.description('The default domain of the Container App Environment.')
  defaultDomain: string

  @sys.description('The static IP of the Container App Environment.')
  staticIp: string
}
