#!/bin/bash

# Variables - replace with your own values
RESOURCE_GROUP="notes-app-rg"
LOCATION="eastus"
ACR_NAME="notesappregistry" # Your ACR name
FRONTEND_CONTAINER_NAME="notes-frontend"
BACKEND_CONTAINER_NAME="notes-backend"
MONGODB_CONTAINER_NAME="notes-mongodb"
NETWORK_NAME="notes-network"

# Create a resource group if it doesn't exist
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a virtual network and subnet
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $NETWORK_NAME \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name default-subnet \
  --subnet-prefix 10.0.0.0/24

# Create a MongoDB container
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $MONGODB_CONTAINER_NAME \
  --image mongo:latest \
  --dns-name-label $MONGODB_CONTAINER_NAME \
  --ports 27017 \
  --cpu 1 \
  --memory 1.5 \
  --environment-variables MONGO_INITDB_ROOT_USERNAME=admin MONGO_INITDB_ROOT_PASSWORD=password

# Get MongoDB FQDN
MONGODB_FQDN=$(az container show --resource-group $RESOURCE_GROUP --name $MONGODB_CONTAINER_NAME --query ipAddress.fqdn --output tsv)

# Create backend container
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $BACKEND_CONTAINER_NAME \
  --registry-login-server "$ACR_NAME.azurecr.io" \
  --registry-username $(az acr credential show --name $ACR_NAME --query username --output tsv) \
  --registry-password $(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv) \
  --image "$ACR_NAME.azurecr.io/notes-backend:latest" \
  --dns-name-label $BACKEND_CONTAINER_NAME \
  --ports 5000 \
  --cpu 1 \
  --memory 1.5 \
  --environment-variables \
    PORT=5000 \
    MONGODB_URI="mongodb://admin:password@$MONGODB_FQDN:27017/notesapp?retryWrites=true&w=majority" \
    NODE_ENV=production

# Get Backend FQDN
BACKEND_FQDN=$(az container show --resource-group $RESOURCE_GROUP --name $BACKEND_CONTAINER_NAME --query ipAddress.fqdn --output tsv)

# Update the frontend container with the backend URL
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $FRONTEND_CONTAINER_NAME \
  --registry-login-server "$ACR_NAME.azurecr.io" \
  --registry-username $(az acr credential show --name $ACR_NAME --query username --output tsv) \
  --registry-password $(az acr credential show --name $ACR_NAME --query "passwords[0].value" --output tsv) \
  --image "$ACR_NAME.azurecr.io/notes-frontend:latest" \
  --dns-name-label $FRONTEND_CONTAINER_NAME \
  --ports 80 \
  --cpu 1 \
  --memory 1 \
  --environment-variables \
    REACT_APP_API_URL="http://$BACKEND_FQDN:5000/api"

# Output the URLs
echo "MongoDB is running at: mongodb://$MONGODB_FQDN:27017"
echo "Backend API is running at: http://$BACKEND_FQDN:5000"
echo "Frontend is running at: http://$(az container show --resource-group $RESOURCE_GROUP --name $FRONTEND_CONTAINER_NAME --query ipAddress.fqdn --output tsv)" 