
targetScope = 'subscription'

param location string = deployment().location

@sys.secure()
param nextAuthHash string = uniqueString(newGuid())

// TODO: name generator

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-03-01' = {
  name: 'some-demo-resource-group'
  location: location
}

// Log Analytics Workspace
module logAnalyticsWorkspace 'modules/monitoring/log-analytics-workspace/main.bicep' = {
  name: 'logAnalyticsWorkspace'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-log-analytics-workspace'
      location: location
    }
  }
}

// Application Insights
module applicationInsights 'modules/monitoring/application-insights/main.bicep' = {
  name: 'applicationInsights'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-application-insights'
      location: location
    }
    props: {
      workspaceId: logAnalyticsWorkspace.outputs.core.id
    }
  }
}

// Cosmos DB Account
// Cosmos DB SQL Database
// Cosmos DB SQL Database Containers
module cosmosDb 'modules/data-storage/cosmos-db/main.bicep' = {
  name: 'cosmosDb'
  scope: resourceGroup
  params: {
    core: {
      name: 'mycosmosdb'
      location: location
    }
    props: {
      databaseName: 'myDatabase'
      containers: [
        {
          name: 'historyContainer'
          partitionKeyPaths: ['/userId']
        }
        {
          name: 'configContainer'
          partitionKeyPaths: ['/userId']
        }
      ]
    }
  }
}

// Storage Account
// Storage Account Blob Service
// Storage Account Blob Container(s)
module storageAccount 'modules/data-storage/storage-account/main.bicep' = {
  name: 'storageAccount'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-sa' // ! Yes, this is a bad name, but it's just a demo
      location: location
    }
    sku: {
      name: 'Standard_LRS'
    }
    props: {
      containers: [ { name: 'images' }, { name: 'documents' } ]
    }
  }
}

// Search Service
module searchService 'modules/ai-services/search-service/main.bicep' = {
  name: 'searchService'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-search-service'
      location: location
    }
  }
}

// Form Recognizer
module formRecognizer 'modules/ai-services/cognitive-service/main.bicep' = {
  name: 'formRecognizer'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-form-recognizer'
      location: location
    }
    props: {
      kind: 'FormRecognizer'
    }
  }
}

// Speech Service
module speechService 'modules/ai-services/cognitive-service/main.bicep' = {
  name: 'speechService'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-speech-service'
      location: location
    }
    props: {
      kind: 'SpeechServices'
    }
  }
}

// OpenAI Model Deployments
module openai 'modules/ai-services/cognitive-service/main.bicep' = {
  name: 'openaiService'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-openai-service'
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

// Key Vault
module keyVault 'modules/data-storage/key-vault/main.bicep' = {
  name: 'keyVault'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-key-vault'
      location: location
    }
    props: {
      secrets: [
        {
          name: 'AZURE-OPENAI-API-KEY'
          value: openai.outputs.core.keys[0]
        }
        {
          name: 'AZURE-OPENAI-DALLE-API-KEY'
          value: openai.outputs.core.keys[0]
        }
        {
          name: 'NEXTAUTH-SECRET'
          value: nextAuthHash
        }
        {
          name: 'AZURE-COSMOSDB-KEY'
          value: cosmosDb.outputs.core.keys[0]
        }
        {
          name: 'AZURE-DOCUMENT-INTELLIGENCE-KEY'
          value: formRecognizer.outputs.core.keys[0]
        }
        {
          name: 'AZURE-SPEECH-KEY'
          value: speechService.outputs.core.keys[0]
        }
        {
          name: 'AZURE-SEARCH-API-KEY'
          value: searchService.outputs.core.keys[0]
        }
        {
          name: 'AZURE-STORAGE-ACCOUNT-KEY'
          value: storageAccount.outputs.core.keys[0]
        }
      ]
    }
  }
}

// Container Registry
module containerRegistry 'modules/application/container-registry/main.bicep' = {
  name: 'containerRegistry'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-container-registry'
      location: location
    }
    sku: {
      name: 'Premium'
    }
  }
}

// Container App Environment
module containerAppEnvironment 'modules/application/container-app-environment/main.bicep' = {
  name: 'containerAppEnvironment'
  scope: resourceGroup
  params: {
    core: {
      name: 'some-demo-container-app-env'
      location: location
    }
    props: {
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.outputs.core.id
        key: logAnalyticsWorkspace.outputs.core.key
      }
    }
  }
}

// Container App

// Public DNS Zone CNAME Record

// Role Assignments
// Cosmos DB SQL Database Role Definition
// Cosmos DB SQL Database Role Assignment
