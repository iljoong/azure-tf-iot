resource "azurerm_function_app" "fxapp" {
  name                      = "${var.prefix}fxhttp"
  location                  = azurerm_resource_group.tfrg.location
  resource_group_name       = azurerm_resource_group.tfrg.name
  app_service_plan_id       = azurerm_app_service_plan.tfrg.id
  storage_connection_string = azurerm_storage_account.tfrg.primary_connection_string

  version = "~2"
  
  site_config {
    always_on = "true"
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME                 = "dotnet"
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = azurerm_storage_account.tfrg.primary_connection_string
    WEBSITE_CONTENTSHARE                     = "fxapp" #azurerm_storage_account.tfrg.name

    # change default key management, https://github.com/Azure/azure-functions-host/wiki/Changes-to-Key-Management-in-Functions-V2
    AzureWebJobsSecretStorageType = "Files"
  }

}

resource "azurerm_template_deployment" "fxapp" {
  name                = "${var.prefix}-fxapp-deploy"
  resource_group_name = azurerm_resource_group.tfrg.name

  template_body = file(var.fxapp_template_path)

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    appName = azurerm_function_app.fxapp.name
    hostingPlanName = azurerm_app_service_plan.tfrg.name
    packageUri = var.fxapp_package_url
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_function_app.fxapp]
}

output "fxapp_site_credentials" {
  value = azurerm_function_app.fxapp.site_credential
}
