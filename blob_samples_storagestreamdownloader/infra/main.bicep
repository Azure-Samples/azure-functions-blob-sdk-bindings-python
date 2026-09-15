targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('The azd environment name used to generate resource names.')
param environmentName string

@description('The Azure region for all resources.')
@metadata({
  azd: {
    type: 'location'
  }
})
param location string

module app '../../infra/function-app.bicep' = {
  name: 'streamdownloader'
  params: {
    environmentName: environmentName
    location: location
    sampleName: 'streamdownloader'
  }
}

output AZURE_FUNCTION_APP_NAME string = app.outputs.AZURE_FUNCTION_APP_NAME
output AZURE_LOCATION string = app.outputs.AZURE_LOCATION
output AZURE_STORAGE_ACCOUNT_NAME string = app.outputs.AZURE_STORAGE_ACCOUNT_NAME
output AZURE_STORAGE_SYSTEM_TOPIC_NAME string = app.outputs.AZURE_STORAGE_SYSTEM_TOPIC_NAME
output AZURE_TENANT_ID string = app.outputs.AZURE_TENANT_ID
output RESOURCE_GROUP string = app.outputs.RESOURCE_GROUP
output SERVICE_API_NAME string = app.outputs.SERVICE_API_NAME
