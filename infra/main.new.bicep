

targetScope = 'subscription'

param prefix string = 'ncxat'
param location string = deployment().location
param locShrt string = 'eus2'

@secure()
param nextAuthHash string = uniqueString(newGuid())

// TODO: name generator

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-03-01' = {
  name: 'rg-${prefix}-${locShrt}'
  location: location
}

// Log Analytics Workspace
module logAnalyticsWorkspace 'modules/monitoring/log-analytics-workspace/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'law-${prefix}-${locShrt}'
      location: location
    }
    props: {
      sku: 'PerGB2018'
      retention: 60
    }
  }
}

// Application Insights
module applicationInsights 'modules/monitoring/application-insights/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'appinsights-${prefix}-${locShrt}'
      location: location
    }
    props: {
      workspaceId: logAnalyticsWorkspace.outputs.id
    }
  }
}

// Cosmos DB Account
// Cosmos DB SQL Database
// Cosmos DB SQL Database Containers
module cosmosDb 'modules/data-storage/cosmos-db/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'cosmosdb-${prefix}-${locShrt}'
      location: location
    }
    props: {
      databaseName: 'chat'
      containers: [
        { name: 'history', partitionKeyPaths: ['/userId'] }
        { name: 'config', partitionKeyPaths: ['/userId'] }
      ]
    }
  }
}

// Storage Account
// Storage Account Blob Service
// Storage Account Blob Container(s)
module storageAccount 'modules/data-storage/storage-account/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'sa${replace(prefix, '-', '')}${locShrt}'
      location: location
    }
    props: {
      containers: [
        { name: 'images' }
        { name: 'documents' }
      ]
    }
  }
}

// Search Service
module searchService 'modules/ai-services/search-service/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'search-${prefix}-${locShrt}'
      location: location
    }
  }
}

// Form Recognizer
module formRecognizer 'modules/ai-services/cognitive-service/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'docint-${prefix}-${locShrt}'
      location: location
    }
    props: {
      kind: 'FormRecognizer'
    }
  }
}

// Speech Service
module speechService 'modules/ai-services/cognitive-service/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'speech-${prefix}-${locShrt}'
      location: location
    }
    props: {
      kind: 'SpeechServices'
    }
  }
}

// OpenAI Model Deployments
module openAiService 'modules/ai-services/cognitive-service/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'openai-${prefix}-${locShrt}'
      location: location
    }
    props: {
      kind: 'OpenAI'
      modelDeployment: [
        {
          name: 'gpt-4o'
          sku: {
            name: 'GlobalStandard'
            capacity: 30
          }
          model: {
            format: 'OpenAI'
            name: 'gpt-4o'
            version: '2024-05-13'
          }
        }
        {
          name: 'text-embedding-ada-002'
          sku: {
            name: 'Standard'
            capacity: 120
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

//// Grounding with Bing
// HACK 2025-06-03 Not supported by ARM deployments, at this time

// Microsoft Entra ID Application Registration

// Key Vault
module keyVault 'modules/data-storage/key-vault/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'kv-${prefix}-${locShrt}'
      location: location
    }
    props: {
      secrets: [
        {
          name: 'AZURE-OPENAI-API-KEY'
          value: openAiService.outputs.key
        }
        {
          name: 'AZURE-OPENAI-DALLE-API-KEY'
          value: openAiService.outputs.key
        }
        {
          name: 'NEXTAUTH-SECRET'
          value: nextAuthHash
        }
        {
          name: 'AZURE-COSMOSDB-KEY'
          value: cosmosDb.outputs.key
        }
        {
          name: 'AZURE-DOCUMENT-INTELLIGENCE-KEY'
          value: formRecognizer.outputs.key
        }
        {
          name: 'AZURE-SPEECH-KEY'
          value: speechService.outputs.key
        }
        {
          name: 'AZURE-SEARCH-API-KEY'
          value: searchService.outputs.key
        }
        {
          name: 'AZURE-STORAGE-ACCOUNT-KEY'
          value: storageAccount.outputs.key
        }
      ]
    }
  }
}

// Container Registry
module containerRegistry 'modules/application/container-registry/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'cr${replace(prefix, '-', '')}'
      location: location
    }
    sku: {
      name: 'Standard'
    }
  }
}

// Container App Environment
module containerAppEnvironment 'modules/application/container-app-environment/main.bicep' = {
  scope: resourceGroup
  params: {
    core: {
      name: 'cae-${prefix}-${locShrt}'
      location: location
    }
    props: {
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.outputs.id
        key: logAnalyticsWorkspace.outputs.key
      }
    }
  }
}

// Container App
// ? Should this be deferred until after the first image deployed to the registry?

// Public DNS Zone CNAME Record

// Azure Role Assignments
// Cosmos DB SQL Database Role Definition
// Cosmos DB SQL Database Role Assignment
