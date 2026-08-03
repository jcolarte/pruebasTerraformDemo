terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "rg-demo-terraform-stg-ua"
    storage_account_name = "stgaccountandesdemo"
    container_name       = "tfstate"
    key                  = "dev.apps.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Obtiene la configuración de cliente actual (Tenant ID, Object ID del SPN que ejecuta el pipeline)
data "azurerm_client_config" "current" {}