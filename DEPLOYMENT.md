# Deploying Notes App to Azure

This guide covers how to deploy the Notes App to Azure Container Registry (ACR) and Azure Container Instances (ACI).

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- Azure account with active subscription
- GitHub accounts with access to both repositories
- Administrative access to set up GitHub Actions secrets

## Step 1: Create Azure Container Registry

1. Log in to Azure CLI:
   ```
   az login
   ```

2. Create a resource group:
   ```
   az group create --name notes-app-rg --location eastus
   ```

3. Create an Azure Container Registry:
   ```
   az acr create --resource-group notes-app-rg --name notesappregistry --sku Basic
   ```

4. Enable admin user for your ACR:
   ```
   az acr update --name notesappregistry --admin-enabled true
   ```

5. Get the credentials for your ACR:
   ```
   az acr credential show --name notesappregistry
   ```
   Note the username and password.

## Step 2: Configure GitHub Actions Secrets

For each repository (notes-app and notes-app-backend), add the following secrets:

1. Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret
2. Add the following secrets:
   - `AZURE_CREDENTIALS` - JSON object with Azure service principal details (see below)
   - `ACR_LOGIN_SERVER` - Your ACR login server (e.g., notesappregistry.azurecr.io)
   - `ACR_USERNAME` - The username from step 1.5
   - `ACR_PASSWORD` - The password from step 1.5

### Creating Azure Credentials for GitHub Actions

```bash
# Create service principal and get JSON credentials
az ad sp create-for-rbac --name "notes-app-sp" --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/notes-app-rg \
  --sdk-auth
```

The output JSON object should be set as the `AZURE_CREDENTIALS` secret.

## Step 3: Push Code to GitHub

Ensure your code is pushed to the main branch of both repositories. This will trigger the GitHub Actions workflows to build and push your container images to ACR.

## Step 4: Deploy to Azure Container Instances

1. Ensure you have the Azure CLI installed and are logged in.
2. Make the deployment script executable:
   ```
   chmod +x scripts/deploy-to-azure.sh
   ```
3. Run the deployment script:
   ```
   ./scripts/deploy-to-azure.sh
   ```

## Step 5: Access Your Application

Once deployment is complete, the script will output URLs for:
- Frontend application
- Backend API
- MongoDB instance

## Troubleshooting

1. If containers fail to start, check logs with:
   ```
   az container logs --resource-group notes-app-rg --name notes-frontend
   az container logs --resource-group notes-app-rg --name notes-backend
   ```

2. Check container status:
   ```
   az container show --resource-group notes-app-rg --name notes-frontend
   ```

3. If you need to redeploy just one component, you can use specific commands from the deployment script.

## Clean Up Resources

To avoid incurring charges, remember to delete resources when not in use:
```
az group delete --name notes-app-rg --yes
``` 