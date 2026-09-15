#!/usr/bin/env sh
set -eu

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is required to create the blob trigger Event Grid subscription." >&2
  exit 1
fi

extension_key=$(az functionapp keys list --name "$AZURE_FUNCTION_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "systemKeys.blobs_extension" --output tsv)
if [ -z "$extension_key" ]; then
  echo "Unable to retrieve the Functions blob extension key." >&2
  exit 1
fi

endpoint="https://${AZURE_FUNCTION_APP_NAME}.azurewebsites.net/runtime/webhooks/blobs?functionName=Host.Functions.blob_trigger&code=${extension_key}"
az eventgrid system-topic event-subscription create --name blob-trigger --resource-group "$RESOURCE_GROUP" --system-topic-name "$AZURE_STORAGE_SYSTEM_TOPIC_NAME" --endpoint-type webhook --endpoint "$endpoint" --included-event-types Microsoft.Storage.BlobCreated --output none