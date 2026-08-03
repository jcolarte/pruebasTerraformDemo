output "function_app_name" {
  description = "Nombre de la Function App"
  value       = azurerm_linux_function_app.function.name
}

output "key_vault_uri" {
  description = "URI del Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "managed_identity_client_id" {
  description = "Client ID de la Identidad Administrada"
  value       = azurerm_user_assigned_identity.app_identity.client_id
}