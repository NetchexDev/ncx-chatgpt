@sys.export()
@sys.description('The configuration for the Container App.')
type Props = {
  @sys.description('The ID of the Container App Environment where the app will be deployed.')
  containerAppEnvironmentId: string

  @sys.description('The ID of the user-assigned managed identity to pull container images.')
  pullIdentityId: string

  @sys.description('The URI of the Azure Container Registry.')
  acrUri: string

  @sys.description('The container image to deploy.')
  containerImage: string

  @sys.description('The port the container listens on. Defaults to 3000.')
  containerPort: int?

  @sys.description('Environment variables for the container.')
  environmentVariables: {
    @sys.description('The name of the environment variable.')
    name: string
    
    @sys.description('The value of the environment variable.')
    value: string
  }[]?

  @sys.description('The minimum number of replicas. Defaults to 1.')
  minReplicas: int?

  @sys.description('The maximum number of replicas. Defaults to 10.')
  maxReplicas: int?
}

@sys.export()
@sys.description('The output properties of the Container App resource.')
type Outputs = {
  @sys.description('The resource ID of the Container App.')
  id: resourceOutput<'Microsoft.App/containerApps@2025-02-02-preview'>.id

  @sys.description('The fully qualified domain name of the Container App.')
  fqdn: resourceOutput<'Microsoft.App/containerApps@2025-02-02-preview'>.properties.configuration.ingress.fqdn

  @sys.description('The name of the latest revision.')
  latestRevisionName: resourceOutput<'Microsoft.App/containerApps@2025-02-02-preview'>.properties.latestRevisionName
}
