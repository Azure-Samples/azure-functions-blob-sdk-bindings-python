targetScope = 'subscription'

@minLength(1)
@maxLength(64)
param environmentName string

param location string

@minLength(1)
@maxLength(32)
param sampleName string

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location, sampleName))
var tags = {
  'azd-env-name': environmentName
  sample: sampleName
}
var resourceGroupName = 'rg-${sampleName}-${take(environmentName, 50)}'
var functionAppName = 'func-${sampleName}-${resourceToken}'
var storageAccountName = 'st${resourceToken}'
var storageQueueEndpoint = 'https://${storageAccountName}.queue.${environment().suffixes.storage}'
var deploymentContainerName = 'app-package-${take(resourceToken, 12)}'
var storageBlobDataOwnerRoleId = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
var storageQueueDataContributorRoleId = '974c5e8b-45b9-4653-ba55-5f855dd0fb88'
var monitoringMetricsPublisherRoleId = '3913510d-42f4-4e42-8a64-420c390055eb'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module identity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.1' = {
  name: 'identity'
  scope: resourceGroup
  params: {
    name: 'id-${sampleName}-${resourceToken}'
    location: location
    tags: tags
  }
}

module plan 'br/public:avm/res/web/serverfarm:0.1.1' = {
  name: 'plan'
  scope: resourceGroup
  params: {
    name: 'plan-${resourceToken}'
    location: location
    reserved: true
    sku: {
      name: 'FC1'
      tier: 'FlexConsumption'
    }
    tags: tags
  }
}

module storage 'br/public:avm/res/storage/storage-account:0.8.3' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    name: storageAccountName
    location: location
    tags: tags
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    blobServices: {
      containers: [
        {
          name: deploymentContainerName
        }
      ]
    }
  }
}

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.7.0' = {
  name: 'log-analytics'
  scope: resourceGroup
  params: {
    name: 'log-${resourceToken}'
    location: location
    tags: tags
    dataRetention: 30
  }
}

module applicationInsights 'br/public:avm/res/insights/component:0.4.1' = {
  name: 'application-insights'
  scope: resourceGroup
  params: {
    name: 'appi-${resourceToken}'
    location: location
    tags: tags
    workspaceResourceId: logAnalytics.outputs.resourceId
    disableLocalAuth: true
  }
}

module rbac './rbac.bicep' = {
  name: 'rbac'
  scope: resourceGroup
  params: {
    applicationInsightsName: applicationInsights.outputs.name
    managedIdentityPrincipalId: identity.outputs.principalId
    monitoringMetricsPublisherRoleId: monitoringMetricsPublisherRoleId
    storageAccountName: storage.outputs.name
    storageBlobDataOwnerRoleId: storageBlobDataOwnerRoleId
    storageQueueDataContributorRoleId: storageQueueDataContributorRoleId
  }
}

module eventGridTopic 'br/public:avm/res/event-grid/system-topic:0.6.1' = {
  name: 'event-grid-topic'
  scope: resourceGroup
  params: {
    name: 'evgt-${resourceToken}'
    location: location
    tags: tags
    source: storage.outputs.resourceId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

module functionApp 'br/public:avm/res/web/site:0.15.1' = {
  name: 'function-app'
  scope: resourceGroup
  dependsOn: [
    rbac
  ]
  params: {
    name: functionAppName
    kind: 'functionapp,linux'
    location: location
    tags: union(tags, {
      'azd-service-name': 'api'
    })
    serverFarmResourceId: plan.outputs.resourceId
    managedIdentities: {
      userAssignedResourceIds: [
        identity.outputs.resourceId
      ]
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storage.outputs.primaryBlobEndpoint}${deploymentContainerName}'
          authentication: {
            type: 'UserAssignedIdentity'
            userAssignedIdentityResourceId: identity.outputs.resourceId
          }
        }
      }
      runtime: {
        name: 'python'
        version: '3.14'
      }
      scaleAndConcurrency: {
        instanceMemoryMB: 2048
        maximumInstanceCount: 100
      }
    }
    siteConfig: {
      alwaysOn: false
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
    appSettingsKeyValuePairs: {
      APPLICATIONINSIGHTS_AUTHENTICATION_STRING: 'ClientId=${identity.outputs.clientId};Authorization=AAD'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.outputs.connectionString
      BLOB_TRIGGER_SOURCE: 'EventGrid'
      AzureWebJobsStorage__blobServiceUri: storage.outputs.primaryBlobEndpoint
      AzureWebJobsStorage__clientId: identity.outputs.clientId
      AzureWebJobsStorage__credential: 'managedidentity'
      AzureWebJobsStorage__queueServiceUri: storageQueueEndpoint
      StorageConnection__blobServiceUri: storage.outputs.primaryBlobEndpoint
      StorageConnection__clientId: identity.outputs.clientId
      StorageConnection__credential: 'managedidentity'
      StorageConnection__queueServiceUri: storageQueueEndpoint
    }
  }
}

output AZURE_FUNCTION_APP_NAME string = functionApp.outputs.name
output AZURE_LOCATION string = location
output AZURE_STORAGE_ACCOUNT_NAME string = storage.outputs.name
output AZURE_STORAGE_SYSTEM_TOPIC_NAME string = eventGridTopic.outputs.name
output AZURE_TENANT_ID string = tenant().tenantId
output RESOURCE_GROUP string = resourceGroup.name
output SERVICE_API_NAME string = functionApp.outputs.name
