# 1. Managed Identity (User Assigned)
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-${var.project_prefix}-func-${var.env}"
  resource_group_name = data.azurerm_resource_group.dev_rg.name
  location            = data.azurerm_resource_group.dev_rg.location
  tags                = var.tags
}

# 2. Key Vault (Usando modelo RBAC moderno)
resource "azurerm_key_vault" "kv" {
  name                        = "kv-${var.project_prefix}-app-${var.env}"
  location                    = data.azurerm_resource_group.dev_rg.location
  resource_group_name         = data.azurerm_resource_group.dev_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  
  enable_rbac_authorization   = true # Best practice: RBAC en lugar de Access Policies
  purge_protection_enabled    = false # Habilitar en PRD

  tags                        = var.tags
}

# 3. Asignación de Roles (RBAC) para el Key Vault
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}

# 4. Storage Account (Requisito para Function App)
resource "azurerm_storage_account" "func_sa" {
  name                     = "st${var.project_prefix}func${var.env}"
  resource_group_name      = data.azurerm_resource_group.dev_rg.name
  location                 = data.azurerm_resource_group.dev_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_storage_account" "func_stga" {
  name                     = "stga${var.project_prefix}func${var.env}"
  resource_group_name      = data.azurerm_resource_group.dev_rg.name
  location                 = data.azurerm_resource_group.dev_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# 5. App Service Plan (Consumption Plan para Linux)
resource "azurerm_service_plan" "func_plan" {
  name                = "asp-${var.project_prefix}-func-${var.env}"
  resource_group_name = data.azurerm_resource_group.dev_rg.name
  location            = data.azurerm_resource_group.dev_rg.location
  os_type             = "Linux"
  sku_name            = "Y1" # Plan Consumption
  tags                = var.tags
}

# 6. Linux Function App
resource "azurerm_linux_function_app" "function" {
  name                       = "func-${var.project_prefix}-api-${var.env}"
  resource_group_name        = data.azurerm_resource_group.dev_rg.name
  location                   = data.azurerm_resource_group.dev_rg.location
  service_plan_id            = azurerm_service_plan.func_plan.id
  storage_account_name       = azurerm_storage_account.func_sa.name
  storage_account_access_key = azurerm_storage_account.func_sa.primary_access_key
  
  site_config {
    application_stack {
      python_version = "3.11" # Ajustar al stack necesario
    }
  }

  # Asociamos la Identidad Administrada
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app_identity.id]
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "KeyVaultUri"              = azurerm_key_vault.kv.vault_uri
    # Variable de entorno referenciando secretos de KV vía UAMI de forma segura
    "SecretExample"            = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=MySecret)"
  }

  tags = var.tags
}