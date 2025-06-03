@export()
@sys.description('Properties for the Container App Environment.')
type Props = {
  @sys.description('Log Analytics configuration for the Container App Environment.')
  logAnalyticsConfiguration: {
    @sys.description('The Log Analytics workspace customer ID.')
    customerId: string

    @sys.description('The Log Analytics workspace shared key.')
    key: string
  }
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
