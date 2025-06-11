targetScope = 'resourceGroup'

@minLength(3)
param prefix string = 'ncxat'

@export()
var abbreviations { *: string } = {
  eastus: 'eus'
  eastus2: 'eus2'
  northcentralus: 'ncus'
  southcentralus: 'scus'
  swedencentral: 'swc'
  westus: 'wus'
  westus3: 'wus3'
}

@export()
func abbreviate(key string) string => abbreviations[?key] ?? toLower(replace(key, ' ', ''))

param primaryLocation string = resourceGroup().location
param secondaryLocation string = 'eastus2'

@minLength(2)
param locShrt string = 'eus2'

param nextAuthHash string = uniqueString(newGuid())

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${prefix}-${locShrt}'
  location: primaryLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 60
  }
}

// Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appinsights-${prefix}-${locShrt}'
  location: primaryLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// Cosmos DB Account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2025-05-01-preview' = {
  name: 'cosmosdb-${prefix}-${locShrt}'
  location: primaryLocation
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: primaryLocation
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
  }
}

// Diagnostic Settings for Cosmos DB Account
resource cosmosDbDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: cosmosDbAccount
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'DataPlaneRequests'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'QueryRuntimeStatistics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'PartitionKeyStatistics'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'ControlPlaneRequests'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'MongoRequests'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Cosmos DB SQL Database
resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-05-01-preview' = {
  parent: cosmosDbAccount
  name: 'chat'
  properties: {
    resource: {
      id: 'chat'
    }
  }
}

// Cosmos DB SQL Database Containers
resource historyContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2025-05-01-preview' = {
  parent: cosmosDbDatabase
  name: 'history'
  properties: {
    resource: {
      id: 'history'
      partitionKey: {
        paths: [
          '/userId'
        ]
        kind: 'Hash'
      }
    }
  }
}

resource configContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2025-05-01-preview' = {
  parent: cosmosDbDatabase
  name: 'config'
  properties: {
    resource: {
      id: 'config'
      partitionKey: {
        paths: [
          '/userId'
        ]
        kind: 'Hash'
      }
    }
  }
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: 'sa${replace(prefix, '-', '')}${locShrt}'
  location: primaryLocation
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// Diagnostic Settings for Storage Account
resource storageAccountDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Diagnostic Settings for Blob Service
resource blobServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: blobService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'StorageWrite'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'StorageDelete'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Storage Account Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {}
}

// Storage Account Blob Containers
resource imagesContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: blobService
  name: 'images'
  properties: {
    publicAccess: 'None'
  }
}

resource documentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: blobService
  name: 'documents'
  properties: {
    publicAccess: 'None'
  }
}

// Search Service
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: 'search-${prefix}-${locShrt}'
  location: primaryLocation
  sku: {
    name: 'standard'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
  }
}

// Diagnostic Settings for Search Service
resource searchServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: searchService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'OperationLogs'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Form Recognizer
resource formRecognizer 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: 'docint-${prefix}-${locShrt}'
  location: primaryLocation
  kind: 'FormRecognizer'
  sku: {
    name: 'S0'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// Diagnostic Settings for Form Recognizer
resource formRecognizerDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: formRecognizer
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'RequestResponse'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Speech Service
resource speechService 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: 'speech-${prefix}-${locShrt}'
  location: primaryLocation
  kind: 'SpeechServices'
  sku: {
    name: 'S0'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

// Diagnostic Settings for Speech Service
resource speechServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: speechService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'RequestResponse'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// OpenAI Model Deployments
module openAiService 'modules/ai-services/cognitive-service/main.bicep' = {
  params: {
    core: {
      name: 'openai-${prefix}-${locShrt}'
      location: primaryLocation
    }
    props: {
      kind: 'OpenAI'
      modelDeployment: [
        {
          name: 'gpt-4.1-mini'
          sku: {
            name: 'GlobalStandard'
            capacity: 500
          }
          model: {
            format: 'OpenAI'
            name: 'gpt-4.1-mini'
            version: '2025-04-14'
          }
        }
        {
          name: 'text-embedding-ada-002'
          sku: {
            name: 'Standard'
            capacity: 60
          }
          model: {
            format: 'OpenAI'
            name: 'text-embedding-ada-002'
            version: '2'
          }
        }
        {
          name: 'dall-e-3'
          sku: {
            name: 'Standard'
            capacity: 1
          }
          model: {
            format: 'OpenAI'
            name: 'dall-e-3'
          }
        }
      ]
    }
  }
}

// OpenAI Service
resource openAiService_OLD 'Microsoft.CognitiveServices/accounts@2025-04-01-preview' = {
  name: 'openai-${prefix}-${locShrt}'
  location: primaryLocation
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    customSubDomainName: 'openai-${prefix}-${locShrt}'
  }
}

// Add OpenAI model deployments
var llmDeployments = [
  {
    name: 'gpt-4.1-mini'
    model: {
      format: 'OpenAI'
      name: 'gpt-4.1-mini'
      version: '2025-04-14'
    }
    sku: {
      name: 'GlobalStandard'
      capacity: 500
    }
  }
  {
    name: 'text-embedding-ada-002'
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    sku: {
      name: 'Standard'
      capacity: 120
    }
  }
  {
    name: 'dalle-e-3'
    model: {
      format: 'OpenAI'
      name: 'dall-e-3'
    }
    sku: {
      name: 'Standard'
      capacity: 1
    }
  }
]

@batchSize(1)
resource llmDeployment 'Microsoft.CognitiveServices/accounts/deployments@2025-04-01-preview' = [
  for deployment in llmDeployments: {
    parent: openAiService
    name: deployment.name
    properties: {
      model: deployment.model
      // raiPolicyName: 'Microsoft.Default'
      versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    }
    sku: deployment.sku
  }
]

// Diagnostic Settings for OpenAI Service
resource openAiServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: openAiService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'Audit'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'RequestResponse'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${prefix}-${locShrt}'
  location: primaryLocation
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
  }
}

// Diagnostic Settings for Key Vault
resource keyVaultDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'AzurePolicyEvaluationDetails'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Key Vault Secrets
resource openAiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZURE-OPENAI-API-KEY'
  properties: {
    value: openAiService.listKeys().key1
  }
}

resource openAiDalleKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZURE-OPENAI-DALLE-API-KEY'
  properties: {
    value: openAiService.listKeys().key1
  }
}

resource nextAuthSecretSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'NEXTAUTH-SECRET'
  properties: {
    value: nextAuthHash
  }
}

resource cosmosDbKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZURE-COSMOSDB-KEY'
  properties: {
    value: cosmosDbAccount.listKeys().primaryMasterKey
  }
}

resource formRecognizerKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZURE-DOCUMENT-INTELLIGENCE-KEY'
  properties: {
    value: formRecognizer.listKeys().key1
  }
}

resource speechServiceKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZURE-SPEECH-KEY'
  properties: {
    value: speechService.listKeys().key1
  }
}

resource searchServiceKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZURE-SEARCH-API-KEY'
  properties: {
    value: searchService.listAdminKeys().primaryKey
  }
}

resource storageAccountKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'AZURE-STORAGE-ACCOUNT-KEY'
  properties: {
    value: storageAccount.listKeys().keys[0].value
  }
}

// Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  #disable-next-line BCP334 // guess this isn't technically calculatable at this point, huh?
  name: 'cr${replace(prefix, '-', '')}'
  location: primaryLocation
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

// Diagnostic Settings for Container Registry
resource containerRegistryDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2016-09-01' = {
  name: 'service'
  location: primaryLocation
  scope: containerRegistry
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
    metrics: [
      {
        timeGrain: 'PT1M'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: true
        }
      }
    ]
  }
}

// Container App Environment
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' = {
  name: 'cae-${prefix}-${locShrt}'
  location: primaryLocation
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

// Container App
resource containerApp 'Microsoft.App/containerApps@2025-02-02-preview' = {
  name: 'ca-${prefix}-${locShrt}'
  location: primaryLocation
  tags: {
    'azd-service-name': 'frontend'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 3000
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        transport: 'Auto'
        corsPolicy: {
          allowedOrigins: [
            '*'
          ]
          allowedMethods: [
            'GET'
            'POST'
            'PUT'
            'DELETE'
            'OPTIONS'
          ]
          allowedHeaders: [
            '*'
          ]
          maxAge: 3600
        }
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          identity: 'system'
        }
      ]
      secrets: containerAppSecrets
    }
    template: {
      containers: [
        {
          name: 'ncx-chatgpt'
          image: '${containerRegistry.properties.loginServer}/ncx-chatgpt:latest'
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'USE_MANAGED_IDENTITIES'
              value: 'false'
            }
            {
              name: 'AZURE_KEY_VAULT_NAME'
              value: keyVault.name
            }
            {
              name: 'AZURE_OPENAI_API_INSTANCE_NAME'
              value: openAiService.name
            }
            {
              name: 'AZURE_OPENAI_API_DEPLOYMENT'
              value: 'gpt-35-turbo'
            }
            {
              name: 'AZURE_OPENAI_API_EMBEDDINGS_DEPLOYMENT'
              value: 'text-embedding-ada-002'
            }
            {
              name: 'AZURE_OPENAI_API_DALLE_DEPLOYMENT'
              value: 'dall-e-3'
            }
            {
              name: 'AZURE_OPENAI_API_VERSION'
              value: '2024-02-15-preview' // Update with your API version
            }
            {
              name: 'AZURE_OPENAI_DALLE_API_INSTANCE_NAME'
              value: openAiService.name
            }
            {
              name: 'AZURE_OPENAI_DALLE_API_DEPLOYMENT_NAME'
              value: 'dalle-3'
            }
            {
              name: 'AZURE_OPENAI_DALLE_API_VERSION'
              value: '2024-02-15-preview' // Update with your API version
            }
            {
              name: 'NEXTAUTH_SECRET'
              secretRef: 'nextauth-secret'
            }
            {
              name: 'NEXTAUTH_URL'
              value: 'https://ca-${prefix}-${locShrt}.${primaryLocation}.azurecontainerapps.io'
            }
            {
              name: 'AZURE_COSMOSDB_URI'
              value: cosmosDbAccount.properties.documentEndpoint
            }
            {
              name: 'AZURE_SEARCH_NAME'
              value: searchService.name
            }
            {
              name: 'AZURE_SEARCH_INDEX_NAME'
              value: 'ncx-chat' // Update with your search index name
            }
            {
              name: 'AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT'
              value: 'https://${formRecognizer.name}.cognitiveservices.azure.com/'
            }
            {
              name: 'AZURE_SPEECH_REGION'
              value: primaryLocation
            }
            {
              name: 'AZURE_SPEECH_KEY'
              secretRef: 'speech-service-key'
            }
            {
              name: 'AZURE_STORAGE_ACCOUNT_NAME'
              value: storageAccount.name
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'http-scale-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
}

// Container App Secrets
var containerAppSecrets = [
  {
    name: 'nextauth-secret'
    value: nextAuthHash
  }
  {
    name: 'speech-service-key'
    value: speechService.listKeys().key1
  }
]

// RBAC Role Assignments for Container App
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var cosmosDbDataContributorRoleId = '5bd9cd88-fe45-4216-938b-f97437e15450'
var cognitiveServicesUserRoleId = 'a97b65f3-24c7-4388-baec-2e87135dc908'
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var searchServiceContributorRoleId = '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
var searchIndexDataContributorRoleId = '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
var cosmosDbOperatorRoleId = '230815da-be43-4aae-9cb4-875f7bd000aa'
var cognitiveServicesContributorRoleId = '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
var cognitiveServicesOpenAIContributorRoleId = 'a001fd3d-188f-4b5d-821b-7da978bf7442'

// Key Vault Role Assignment
resource kvRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, containerApp.id, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Cosmos DB Role Assignment
resource cosmosDbRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosDbAccount.id, containerApp.id, cosmosDbDataContributorRoleId)
  scope: cosmosDbAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cosmosDbDataContributorRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Cognitive Services Role Assignment
resource cognitiveServicesRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAiService.id, containerApp.id, cognitiveServicesUserRoleId)
  scope: openAiService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesUserRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Role Assignment
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, containerApp.id, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Search Service Role Assignment
resource searchServiceRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, containerApp.id, searchServiceContributorRoleId)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchServiceContributorRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Search Index Data Contributor Role Assignment
resource searchIndexDataRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, containerApp.id, searchIndexDataContributorRoleId)
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', searchIndexDataContributorRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Cosmos DB Operator Role Assignment
resource cosmosDbOperatorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosDbAccount.id, containerApp.id, cosmosDbOperatorRoleId)
  scope: cosmosDbAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cosmosDbOperatorRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Cognitive Services Contributor Role Assignment
resource cognitiveServicesContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAiService.id, containerApp.id, cognitiveServicesContributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesContributorRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// OpenAI Contributor Role Assignment
resource cognitiveServicesOpenAIContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(openAiService.id, containerApp.id, cognitiveServicesOpenAIContributorRoleId)
  scope: openAiService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesOpenAIContributorRoleId)
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Custom Cosmos DB Role Definition
resource cosmosDbCustomRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' = {
  parent: cosmosDbAccount
  name: guid(cosmosDbAccount.id, 'CustomCosmosDbRole')
  properties: {
    roleName: 'Azure Cosmos DB for NoSQL Data Plane Owner'
    type: 'CustomRole'
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/read'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/throughput/read'
        ]
      }
    ]
  }
}

// Custom Cosmos DB Role Assignment
resource cosmosDbCustomRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = {
  parent: cosmosDbAccount
  name: guid(cosmosDbAccount.id, containerApp.id, 'CustomRoleAssignment')
  properties: {
    principalId: containerApp.identity.principalId
    roleDefinitionId: cosmosDbCustomRoleDefinition.id
    scope: cosmosDbAccount.id
  }
}

// // Outputs
// output containerAppFqdn string = containerApp.properties.configuration.ingress.fqdn
// output containerAppUrl string = 'https://${containerApp.properties.configuration.ingress.fqdn}'
// output openAiServiceName string = openAiService.name
// output openAiEndpoint string = 'https://${openAiService.properties.customSubDomainName}.openai.azure.com'
// output cosmosDbAccountName string = cosmosDbAccount.name
// output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
// output searchServiceName string = searchService.name
// output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'
// output storageAccountName string = storageAccount.name
// output keyVaultName string = keyVault.name
// output keyVaultUri string = keyVault.properties.vaultUri

// // Outputs for the parent module to consume
// output lawId string = logAnalyticsWorkspace.id
// output appInsightsKey string = applicationInsights.properties.InstrumentationKey
// output cosmosDbKey string = listKeys(cosmosDbAccount.id, cosmosDbAccount.apiVersion).primaryMasterKey
// output searchServiceKey string = listAdminKeys(searchService.id).primaryKey
// output storageAccountKey string = listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value
// output formRecognizerKey string = listKeys(formRecognizer.id, formRecognizer.apiVersion).key1
// output speechServiceKey string = listKeys(speechService.id, speechService.apiVersion).key1
// output openAiServiceKey string = listKeys(openAiService.id, openAiService.apiVersion).key1
// output containerRegistryLoginServer string = containerRegistry.properties.loginServer

// // Additional outputs for the parent module
// output cosmosDbAccountName string = cosmosDbAccount.name
// output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
// output searchServiceName string = searchService.name
// output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'
// output openAiServiceName string = openAiService.name
// output openAiEndpoint string = 'https://${openAiService.properties.customSubDomainName}.openai.azure.com'
// output storageAccountName string = storageAccount.name
// output keyVaultName string = keyVault.name
// output keyVaultUri string = keyVault.properties.vaultUri
