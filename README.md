---
name: Blob SDK-Type Bindings with Azure Functions (Python)
description: Bind to rich SDK types when using blob trigger or blob input.
languages:
- python
products:
- azure
- azure-functions
- azure-storage-blob
- sdk-bindings
page_type: sample
urlFragment: blob-sdk-type-bindings-with-azure-functions

---
<!-- YAML front-matter schema: https://review.learn.microsoft.com/en-us/help/contribute/samples/process/onboarding?branch=main#supported-metadata-fields-for-readmemd -->

# Blob SDK-Type Bindings with Azure Functions (Python)

This sample demonstrates how to use the Azure Functions Blob SDK-type bindings in Python. The supported SDK types include BlobClient, ContainerClient,
and StorageStreamDownloader.

You can learn more about SDK-type bindings for blob in the [SDK-type Bindings for Python Reference](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=get-started%2Casgi%2Capplication-level&pivots=python-mode-decorators#sdk-type-bindings-preview).

## Prerequisites

Before running the sample, you need the following:

1. **Azure Subscription**: An [Azure account](https://azure.com/free) is required.
   
2. **Azure Functions Core Tools**: Install [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-python) to run and test functions locally.

3. **Python 3.x**: Ensure [Python 3.9 or later](https://www.python.org/downloads/) is installed on your machine.

4. **Azure Storage Account**: Create a [storage account via the Azure Portal](https://docs.microsoft.com/azure/storage/common/storage-account-overview) and get the connection string.

## Using SDK-type Bindings for Blob in an Azure Function App
The code in the sample folder has already been updated to support use of SDK-type bindings for blob. Let's walk through the changed files.

The `requirements.txt` file has an additional dependency of the `azurefunctions-extensions-bindings-blob` module:

```
azure-functions
azurefunctions-extensions-bindings-blob
```

Each blob_samples_* folder contains `function_app.py` which import the `azurefunctions-extensions-bindings-blob` module.
```python
import azure.functions as func
import azurefunctions.extensions.bindings.blob as blob
```

In each `function_app.py` file, there are two functions defined: a blob trigger and a blob input. Both of these functions specify an arg
named `client` and define the type as an SDK-type.

The blob_samples_blobclient directory shows the type defined as `BlobClient`.
```python
@app.blob_trigger(
    arg_name="client", path="PATH/TO/BLOB", connection="AzureWebJobsStorage"
)
def blob_trigger(client: blob.BlobClient):
```

The blob_samples_containerclient directory shows the type defined as `ContainerClient`, and 
the blob_samples_storagestreamdownloader directory shows the type defined as `StorageStreamDownloader`.

## Running the sample
### Testing Locally
1. **Clone the repository**: 
    ```
        git clone https://github.com/Azure-Samples/azure-functions-blob-sdk-bindings-python.git
    ```
2. **Navigate to one of the project directories**:
    ```
        cd blob_samples_blobclient
    ```
3. Create a [Python virtual environment](https://docs.python.org/3/tutorial/venv.html#creating-virtual-environments) and activate it.
4. **Install the required dependencies**:
    ```
        pip install -r requirements.txt
    ```
5. **Update `local.settings.json`**: replace `StorageConnection` with your storage account connection string.
6. **Update the blob path**: in `function_app.py`, replace *PATH/TO/BLOB* with your blob path.
7. **Start the function**: If you are using VS Code for development, click the "Run and Debug" button or follow [the instructions for running a function locally](https://docs.microsoft.com/azure/azure-functions/create-first-function-vs-code-python#run-the-function-locally). Outside of VS Code, follow [these instructions for using Core Tools commands directly to run the function locally](https://docs.microsoft.com/azure/azure-functions/functions-run-local?tabs=v4%2Cwindows%2Cpython%2Cportal%2Cbash#start).
   ```
       Functions:
               blob_input:  http://localhost:7071/api/file
               blob_trigger: blobTrigger
   ```
8. **Execute the function**: 
   - Blob trigger: upload the specified blob to the storage account.
   - Blob input: ensure the specified blob is uploaded and send a GET request to the function API endpoint.

### Deploying to Azure

There are three main ways to deploy this to Azure:

* [Deploy with the VS Code Azure Functions extension](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-vs-code-python#publish-the-project-to-azure). 
* [Deploy with the Azure CLI](https://docs.microsoft.com/en-us/azure/azure-functions/create-first-function-cli-python?tabs=azure-cli%2Cbash%2Cbrowser#create-supporting-azure-resources-for-your-function).
* Deploy with the Azure Developer CLI: After [installing the `azd` tool](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd?tabs=localinstall%2Cwindows%2Cbrew), run `azd up` in the root of the project. You can also run `azd pipeline config` to set up a CI/CD pipeline for deployment.

All approaches will provision a Function App, Storage account (to store the code), and a Log Analytics workspace.

## Next Steps
Visit the [SDK-type bindings in Python reference documentation](https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=get-started%2Casgi%2Capplication-level&pivots=python-mode-decorators#sdk-type-bindings-preview) to learn more about how to use SDK-type bindings in a Python Function App and the
[API reference documentation](https://aka.ms/azsdk-python-storage-blob-ref) to learn more about
what you can do with the Azure Storage Blob client library.