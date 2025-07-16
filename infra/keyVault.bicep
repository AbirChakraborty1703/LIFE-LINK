@description('Deploys a Key Vault for secrets')
param environmentName string
param location string
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${environmentName}-kv'
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    // accessPolicies intentionally left empty for RBAC
    enableSoftDelete: true
    enablePurgeProtection: true
    enableRbacAuthorization: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}
output keyVaultUri string = keyVault.properties.vaultUri
