@description('Deploys Application Insights and connects to Log Analytics')
param environmentName string
param location string
param logAnalyticsId string
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${environmentName}-appi'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsId
  }
}
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
