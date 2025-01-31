# Azure Functions Blob SDK-Type Bindings Sample (Python)

This sample demonstrates how to use the Azure Functions Blob SDK-type bindings in Python. The supported SDK types include BlobClient, ContainerClient,
and StorageStreamDownloader.

You can learn more about SDK-type bindings for blob in the [Azure Functions Python Developer Reference](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=get-started%2Casgi%2Capplication-level&pivots=python-mode-decorators#sdk-type-bindings-preview)

## Prerequisites

Before running the sample, you need the following:

1. **Azure Subscription**: An [Azure account](https://azure.com/free) is required.
   
2. **Azure Functions Core Tools**: Install [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-python) to run and test functions locally.

3. **Python 3.x**: Ensure [Python 3.9 or later](https://www.python.org/downloads/) is installed on your machine.

4. **Azure Storage Account**: Create a [storage account via the Azure Portal](https://docs.microsoft.com/azure/storage/common/storage-account-overview) and get the connection string.

## Prepare your local environment
1. **Clone the repository**: `git clone [repository-url]`
2. **Navigate to the project directory**: `cd blob_samples_blobclient`
3. **Install the required dependencies**: `pip install -r requirements.txt`
4. **Update local.settings.json**: replace `AzureWebJobsStorage` with your storage account connection string.
5. **Update the blob path**: in function_app.py, replace *PATH/TO/BLOB* with your blob path.

## Run the function locally
1. **Run the command in your terminal**: `func host start`
2. **For blob trigger**: upload the specified blob to the storage account
3. **For blob input**: ensure the specified blob is uploaded and send a GET request to the function API endpoint.

## Deployment
1. **Ensure you're logged into your Azure subscription**: `azure login`
2. **Create the function app**: You can create it [through the portal](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-function-app-portal?pivots=programming-language-python) or run the command `az functionapp create --name <your-function-app-name> --resource-group <your-resource-group> --consumption-plan-location <region> --runtime python`
3. **Run the command in your terminal**: `func azure functionapp publish <function_name>`

## Next Steps
Visit the [SDK-type bindings in Python reference documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=get-started%2Casgi%2Capplication-level&pivots=python-mode-decorators#sdk-type-bindings-preview) to learn more about how to use SDK-type bindings in a Python Function App and the
[API reference documentation](https://aka.ms/azsdk-python-storage-blob-ref) to learn more about
what you can do with the Azure Storage Blob client library.