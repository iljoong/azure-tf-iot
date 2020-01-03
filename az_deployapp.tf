# deploy apiapp
resource "null_resource" "apiapp" {
  provisioner "local-exec" {
    command = ".\\zipdeploy.ps1 -username '${azurerm_app_service.tfrg.site_credential[0].username}' -password ${azurerm_app_service.tfrg.site_credential[0].password} -appname ${azurerm_app_service.tfrg.name} -filepath .\\assets\\apiapp.zip"
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [azurerm_app_service.tfrg]
}

# deploy fxeh
resource "null_resource" "fxeh" {
  provisioner "local-exec" {
    command = ".\\zipdeploy.ps1 -username '${azurerm_function_app.fxeh.site_credential[0].username}' -password ${azurerm_function_app.fxeh.site_credential[0].password} -appname ${azurerm_function_app.fxeh.name} -filepath .\\assets\\fxeh.zip"
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [azurerm_app_service.tfrg]
}

# sqlcmd installed in your environment
resource "null_resource" "mssql" {
  provisioner "local-exec" {
    command = "sqlcmd -S ${azurerm_sql_server.tfrg.name}.database.windows.net -d ${azurerm_sql_database.tfrg.name} -U ${var.admin_username} -P ${var.admin_password} -Q \"drop table events; create table events (id bigint identity primary key, message nvarchar(max), timecreated datetime)\""
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [azurerm_sql_database.tfrg]
}
