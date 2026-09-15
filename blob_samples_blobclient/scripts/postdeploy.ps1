$ErrorActionPreference = "Stop"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is required to create the blob trigger Event Grid subscription."
}

$extensionKey = az functionapp keys list --name $env:AZURE_FUNCTION_APP_NAME --resource-group $env:RESOURCE_GROUP --query "systemKeys.blobs_extension" --output tsv
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($extensionKey)) {
    throw "Unable to retrieve the Functions blob extension key."
}

$endpoint = "https://$($env:AZURE_FUNCTION_APP_NAME).azurewebsites.net/runtime/webhooks/blobs?functionName=Host.Functions.blob_trigger&code=$extensionKey"
az eventgrid system-topic event-subscription create --name blob-trigger --resource-group $env:RESOURCE_GROUP --system-topic-name $env:AZURE_STORAGE_SYSTEM_TOPIC_NAME --endpoint-type webhook --endpoint $endpoint --included-event-types Microsoft.Storage.BlobCreated --output none
if ($LASTEXITCODE -ne 0) {
    throw "Unable to create the blob trigger Event Grid subscription."
}