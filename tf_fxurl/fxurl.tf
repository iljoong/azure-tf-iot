# Configure the Microsoft Azure Provider
provider "azurerm" {
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "tfrg" {
    name     = "${var.prefix}-rg"
    location = var.location

    tags = {
        environment = var.tag
    }
}

resource "azurerm_storage_account" "tfrg" {
  name                     = "${var.prefix}storacc"
  resource_group_name      = azurerm_resource_group.tfrg.name
  location                 = azurerm_resource_group.tfrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "tfrg" {
  name                = "${var.prefix}svcplan"
  location            = "${azurerm_resource_group.tfrg.location}"
  resource_group_name = "${azurerm_resource_group.tfrg.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "tfrg" {
  name                      = "${var.prefix}fxapp"
  location                  = azurerm_resource_group.tfrg.location
  resource_group_name       = azurerm_resource_group.tfrg.name
  app_service_plan_id       = azurerm_app_service_plan.tfrg.id
  storage_connection_string = azurerm_storage_account.tfrg.primary_connection_string

  version = "~2"
}

resource "azurerm_template_deployment" "fxurl" {
  name                = "${var.prefix}deploy"
  resource_group_name = azurerm_resource_group.tfrg.name

  template_body = file(var.fxapp_template_path)

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    appName = azurerm_function_app.tfrg.name
    hostingPlanName = azurerm_app_service_plan.tfrg.name
    packageUri = var.fxpackageurl
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_function_app.tfrg]
}