resource "azurerm_app_service_plan" "tfrg" {
  name                = "${var.prefix}-svcplan"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "tfrg" {
  name                = "${var.prefix}api"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  app_service_plan_id = azurerm_app_service_plan.tfrg.id

  site_config {
    always_on                = "true"
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    # remove double quote from http return string
    FX_URL = replace(data.http.tfrg.body, "\"", "")
    EVENTS_SQLCONN = "Server=tcp:${azurerm_sql_server.tfrg.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.tfrg.name};Persist Security Info=False;User ID=${var.admin_username};Password=${var.admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${azurerm_sql_server.tfrg.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.tfrg.name};Persist Security Info=False;User ID=${var.admin_username};Password=${var.admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

  #depends_on = [data.http.tfrg, azurerm_sql_server.tfrg]
  depends_on = [data.http.tfrg, azurerm_sql_server.tfrg]
}

/*
resource "azurerm_template_deployment" "tfrg" {
  name                = "${var.prefix}-appdeploy"
  resource_group_name = azurerm_resource_group.tfrg.name

  template_body = file(var.webapp_template_path)

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    appName = azurerm_app_service.tfrg.name
    hostingPlanName = azurerm_app_service_plan.tfrg.name
    packageUri = var.package_url
  }

  deployment_mode = "Incremental"

  depends_on = [azurerm_app_service.tfrg]
}
*/

data "http" "tfrg" {
  url = var.fx_url

  # Optional request headers
  request_headers = {
    Accept    = "application/json"
    cid       = var.client_id
    secret    = var.client_secret
    tenantid  = var.tenant_id
    subsid    = var.subscription_id
    rgname    = azurerm_resource_group.tfrg.name
    sitename  = azurerm_function_app.fxapp.name
    fxname    = "HttpTest"
  }

  depends_on  = [azurerm_template_deployment.fxapp]
}

output "fx_url" {
  value = "${data.http.tfrg.body}"
}

output "webapp_site_credentials" {
  value = azurerm_app_service.tfrg.site_credential
}