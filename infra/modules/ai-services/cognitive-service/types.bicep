@sys.export()
@sys.description('The SKU for the Cognitive service. Defaults to `standard`.')
type Sku = resourceInput<'Microsoft.CognitiveServices/accounts@2025-04-01-preview'>.sku

@sys.export()
@sys.discriminator('kind')
type Props = {
  @sys.description('The kind of Cognitive service to create. Defaults to `FormRecognizer`.')
  kind: 'FormRecognizer'

  @sys.description('The properties to set on the Cognitive service resource.')
  properties: InternalProps?
} | {
  @sys.description('The kind of Cognitive service to create. Defaults to `FormRecognizer`.')
  kind: 'SpeechServices'

  @sys.description('The properties to set on the Cognitive service resource.')
  properties: InternalProps?
} | {
  @sys.description('The kind of Cognitive service to create. Defaults to `OpenAI`.')
  kind: 'OpenAI'

  @sys.description('The properties to set on the Cognitive service resource.')
  properties: InternalProps?

  @sys.description('The model deployment configuration for the OpenAI service.')
  modelDeployment: ModelDeployment[]?
}

@sys.export()
type ModelDeployment = {
  @sys.description('The name of the model deployment.')
  name: string

  @sys.description('The SKU for the model deployment. Defaults to `S0`.')
  sku: {
    @sys.description('The name of the LLM model deployment sku.')
    name: string

    @sys.description('The capacity of the model deployment.')
    capacity: int?
  }

  @sys.description('The model to deploy. See `DefaultModel` for defaults.')
  model: {
    @sys.description('The format of the deployed model. Defaults to `OpenAI`.')
    format: 'OpenAI'

    @sys.description('The name of the model to deploy.')
    name: string

    @sys.description('The version of the model to deploy.')
    version: string?
  }

  @sys.description('The upgrade option for the model deployment. Defaults to `OnceCurrentVersionExpired`.')
  versionUpgradeOption: 'NoAutoUpgrade' | 'OnceCurrentVersionExpired' | 'OnceNewDefaultVersionAvailable' | null
}

@sys.export()
@sys.description('The properties to set on the Cognitive service resource.')
type InternalProps = {
  @sys.description('The custom subdomain name for the Cognitive service. Defaults to the resource name.')
  customSubDomainName: string?

  @sys.description('Disable local authentication for the Search service. Defaults to `false`.')
  disableLocalAuth: resourceInput<'Microsoft.CognitiveServices/accounts@2025-04-01-preview'>.properties.disableLocalAuth?

  @sys.description('Public network access for the Cognitive service. Defaults to `Enabled`.')
  publicNetworkAccess: 'Disabled' | 'Enabled'?
}

@sys.export()
@sys.description('The output properties of the Cognitive service resource.')
type Outputs = {
  @sys.description('The resource ID of the Cognitive service.')
  id: resourceOutput<'Microsoft.CognitiveServices/accounts@2025-04-01-preview'>.id

  @sys.description('The name of the Cognitive service.')
  keys: string[]

  @sys.description('The endpoint of the Cognitive service.')
  endpoint: resourceOutput<'Microsoft.CognitiveServices/accounts@2025-04-01-preview'>.properties.endpoint

  // HACK Could not include `resource` in the output type due to Bicep limitations.
}


