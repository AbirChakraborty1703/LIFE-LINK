@description('Deploys a Container App Environment and connects to Log Analytics')
param environmentName string
param location string
param logAnalyticsCustomerId string
@secure()
param logAnalyticsSharedKey string
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: '${environmentName}-cae'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
  }
}
output containerAppEnvId string = containerAppEnv.id
