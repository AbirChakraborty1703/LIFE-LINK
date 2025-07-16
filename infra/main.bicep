targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment used to generate a short unique hash for resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Optional parameters
@description('JWT Secret for authentication')
@secure()
param jwtSecret string = ''

@description('Gemini API Key for AI chat functionality')
@secure()
param geminiApiKey string = ''

@description('Session Secret for sessions')
@secure()
param sessionSecret string = ''

@description('Stripe Secret Key for payments')
@secure()
param stripeSecretKey string = ''

@description('Cloudinary Cloud Name')
param cloudinaryCloudName string = ''

@description('Cloudinary API Key')
@secure()
param cloudinaryApiKey string = ''

@description('Cloudinary API Secret')
@secure()
param cloudinaryApiSecret string = ''

// Generate a unique token to be used in naming resources
var resourceToken = toLower(uniqueString(subscription().id, resourceGroup().id, environmentName))

// Tags that should be applied to all resources
var tags = {
  'azd-env-name': environmentName
}

// Generate names for resources - keeping them short
var prefix = 'll-${resourceToken}'

// Log Analytics Workspace
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: take('${prefix}-loganalytics', 63)
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${prefix}-appinsights'
  location: location
  kind: 'web'
  tags: tags
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

// Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: '${prefix}-kv'
  location: location
  tags: tags
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

// User-assigned managed identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${prefix}-identity'
  location: location
  tags: tags
}

// Key Vault access policy for managed identity
resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: managedIdentity.properties.principalId
        permissions: {
          secrets: ['get', 'list']
        }
      }
    ]
  }
}

// Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: '${replace(prefix, '-', '')}registry'
  location: location
  sku: {
    name: 'Basic'
  }
  tags: tags
  properties: {
    adminUserEnabled: false
  }
}

// ACR Pull role assignment for managed identity
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, managedIdentity.id, 'acrpull')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Cosmos DB account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
  name: take('${prefix}-cosmos', 50)
  location: location
  kind: 'MongoDB'
  tags: tags
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    apiProperties: {
      serverVersion: '4.2'
    }
    capabilities: [
      {
        name: 'EnableMongo'
      }
    ]
    enableFreeTier: true
    publicNetworkAccess: 'Enabled'
    networkAclBypass: 'AzureServices'
  }
}

// Storage account for file uploads
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: '${replace(prefix, '-', '')}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: tags
  properties: {
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: true
    minimumTlsVersion: 'TLS1_2'
  }
}

// Container App Environment
resource containerEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${prefix}-env'
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// Store secrets in Key Vault
resource jwtSecretKv 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(jwtSecret)) {
  parent: keyVault
  name: 'jwt-secret'
  properties: {
    value: jwtSecret
  }
}

resource geminiApiKeyKv 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(geminiApiKey)) {
  parent: keyVault
  name: 'gemini-api-key'
  properties: {
    value: geminiApiKey
  }
}

resource sessionSecretKv 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(sessionSecret)) {
  parent: keyVault
  name: 'session-secret'
  properties: {
    value: sessionSecret
  }
}

resource stripeSecretKeyKv 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(stripeSecretKey)) {
  parent: keyVault
  name: 'stripe-secret-key'
  properties: {
    value: stripeSecretKey
  }
}

resource cloudinaryApiKeyKv 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(cloudinaryApiKey)) {
  parent: keyVault
  name: 'cloudinary-api-key'
  properties: {
    value: cloudinaryApiKey
  }
}

resource cloudinaryApiSecretKv 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if (!empty(cloudinaryApiSecret)) {
  parent: keyVault
  name: 'cloudinary-api-secret'
  properties: {
    value: cloudinaryApiSecret
  }
}

// Backend Container App
resource backendApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: '${prefix}-backend'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  tags: union(tags, { 'azd-service-name': 'backend' })
  properties: {
    environmentId: containerEnv.id
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 4000
        corsPolicy: {
          allowedOrigins: ['*']
          allowedMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
          allowedHeaders: ['*']
          allowCredentials: false
        }
      }
      registries: [
        {
          server: containerRegistry.properties.loginServer
          identity: managedIdentity.id
        }
      ]
      secrets: [
        {
          name: 'mongo-uri'
          value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
        }
        {
          name: 'jwt-secret'
          value: !empty(jwtSecret) ? jwtSecret : 'default-jwt-secret'
        }
        {
          name: 'gemini-api-key'
          value: !empty(geminiApiKey) ? geminiApiKey : 'default-gemini-key'
        }
        {
          name: 'session-secret'
          value: !empty(sessionSecret) ? sessionSecret : 'default-session-secret'
        }
        {
          name: 'stripe-secret-key'
          value: !empty(stripeSecretKey) ? stripeSecretKey : 'default-stripe-key'
        }
        {
          name: 'cloudinary-api-key'
          value: !empty(cloudinaryApiKey) ? cloudinaryApiKey : 'default-cloudinary-key'
        }
        {
          name: 'cloudinary-api-secret'
          value: !empty(cloudinaryApiSecret) ? cloudinaryApiSecret : 'default-cloudinary-secret'
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: 'backend'
          env: [
            {
              name: 'PORT'
              value: '4000'
            }
            {
              name: 'MONGO_URI'
              secretRef: 'mongo-uri'
            }
            {
              name: 'JWT_SECRET'
              secretRef: 'jwt-secret'
            }
            {
              name: 'GEMINI_API_KEY'
              secretRef: 'gemini-api-key'
            }
            {
              name: 'SESSION_SECRET'
              secretRef: 'session-secret'
            }
            {
              name: 'STRIPE_SECRET_KEY'
              secretRef: 'stripe-secret-key'
            }
            {
              name: 'CLOUDINARY_CLOUD_NAME'
              value: cloudinaryCloudName
            }
            {
              name: 'CLOUDINARY_API_KEY'
              secretRef: 'cloudinary-api-key'
            }
            {
              name: 'CLOUDINARY_API_SECRET'
              secretRef: 'cloudinary-api-secret'
            }
            {
              name: 'NODE_ENV'
              value: 'production'
            }
          ]
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}

// Static Web Apps for frontend and admin
resource frontendApp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: '${prefix}-frontend'
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  tags: union(tags, { 'azd-service-name': 'frontend' })
  properties: {
    branch: 'main'
    buildProperties: {
      appLocation: '/'
      outputLocation: 'dist'
    }
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'None'
  }
}

resource adminApp 'Microsoft.Web/staticSites@2023-12-01' = {
  name: '${prefix}-admin'
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  tags: union(tags, { 'azd-service-name': 'admin' })
  properties: {
    branch: 'main'
    buildProperties: {
      appLocation: '/'
      outputLocation: 'dist'
    }
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'None'
  }
}

// Outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.properties.loginServer
output AZURE_KEY_VAULT_NAME string = keyVault.name
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.properties.vaultUri
output BACKEND_URI string = 'https://${backendApp.properties.configuration.ingress.fqdn}'
output FRONTEND_URI string = 'https://${frontendApp.properties.defaultHostname}'
output ADMIN_URI string = 'https://${adminApp.properties.defaultHostname}'
output RESOURCE_GROUP_ID string = resourceGroup().id
