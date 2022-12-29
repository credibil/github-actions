
az ts create \
  --name ts-container-app \
  --version "1.0" \
  --resource-group "app-ticc-stg-ae-rg" \
  --location "australiaeast" \
  --template-file "./bicep/container-app.bicep"

az ts create \
  --name ts-api-backend \
  --version "1.0" \
  --resource-group "app-ticc-stg-ae-rg" \
  --location "australiaeast" \
  --template-file "./bicep/api-backend.bicep"

az ts create \
  --name ts-custom-api \
  --version "1.0" \
  --resource-group "app-ticc-stg-ae-rg" \
  --location "australiaeast" \
  --template-file "./bicep/custom-api.bicep"

