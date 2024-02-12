# create resource group
az group create --location uksouth --name ben-resource-group

# run main.bicep
az deployment group create --subscription "Visual Studio Professional" --resource-group "ben-resource-group" --template-file main.bicep --mode Incremental

# Login
az login

# checked current logged in user
az account show