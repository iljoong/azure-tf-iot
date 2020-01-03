resource "azurerm_storage_account" "tfrg" {
  name                     = "${var.prefix}storacc"
  resource_group_name      = azurerm_resource_group.tfrg.name
  location                 = azurerm_resource_group.tfrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_function_app" "fxeh" {
  name                      = "${var.prefix}fxeh"
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
    WEBSITE_CONTENTSHARE                     = "fxeh" #azurerm_storage_account.tfrg.name
    RootManageSharedAccessKey_EVENTHUB       = azurerm_eventhub_namespace.tfrg.default_primary_connection_string
    API_URL                                  = "https://${azurerm_app_service.tfrg.default_site_hostname}"
  }

  depends_on = [azurerm_eventhub.tfrg]
}

/*
resource "azurerm_template_deployment" "fxeh" {
  name                = "${var.prefix}fxehdeploy"
  resource_group_name = azurerm_resource_group.tfrg.name

  template_body = file(var.fxapp_template_path)

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    appName = azurerm_function_app.fxeh.name
    hostingPlanName = azurerm_app_service_plan.fxeh.name
    packageUri = var.fxehpackageurl
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_function_app.fxeh]
}
*/

/*
resource "null_resource" "fxeh" {
  provisioner "local-exec" {
    command = "Compress-Archive -Path fxeh\\* -DestinationPath ..\\assets\\fxeh.zip -Force"
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [azurerm_function_app.fxeh]
}
*/

output "fxeh_site_credentials" {
  value = azurerm_function_app.fxeh.site_credential
}
