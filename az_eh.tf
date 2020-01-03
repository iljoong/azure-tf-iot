resource "azurerm_eventhub_namespace" "tfrg" {
  name                = "${var.prefix}eh"
  location            = azurerm_resource_group.tfrg.location
  resource_group_name = azurerm_resource_group.tfrg.name
  sku                 = "Basic"
  capacity            = 1
}

resource "azurerm_eventhub" "tfrg" {
  name                = "testeh"
  namespace_name      = azurerm_eventhub_namespace.tfrg.name
  resource_group_name = azurerm_resource_group.tfrg.name
  partition_count     = 2
  message_retention   = 1
}

output "eventhub_connstring" {
  value = azurerm_eventhub_namespace.tfrg.default_primary_connection_string
}