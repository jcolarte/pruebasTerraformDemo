# Lectura del grupo de recursos brownfield
data "azurerm_resource_group" "dev_rg" {
  name = var.resource_group_name
}