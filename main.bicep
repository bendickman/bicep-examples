resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'bdbicepstdev'
  location: 'uksouth'
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Create simple key vault
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'bdbicepkvdev'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

// Create a secret outside of key vault definition
resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: 'mySecret'
  parent: keyVault  // Pass key vault symbolic name as parent
  properties: {
    value: 'mySecretValue'
  }
}

// Create App Configuration
@description('Specifies the name of the App Configuration store.')
param configStoreName string = 'bdbicepacdev'

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

@description('Specifies the names of the key-value resources. The name is a combination of key and label with $ as delimiter. The label is optional.')
param keyValueNames array = [
  'myKey'
  'myKey$myLabel'
]

@description('Specifies the values of the key-value resources. It\'s optional')
param keyValueValues array = [
  'Key-value without label'
  'Key-value with label'
]

@description('Adds tags for the key-value resources. It\'s optional')
param tags object = {
  tag1: 'tag-value-1'
  tag2: 'tag-value-2'
}

resource configStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: configStoreName
  location: location
  sku: {
    name: 'standard'
  }
}

resource configStoreKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = [for (item, i) in keyValueNames: {
  parent: configStore
  name: item
  properties: {
    value: keyValueValues[i]
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
    tags: tags
  }
}]
