variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos existente"
  default     = "rg-uniandes-dev"
}

variable "location" {
  type        = string
  description = "Región de Azure"
  default     = "eastus"
}

variable "project_prefix" {
  type        = string
  description = "Prefijo para los recursos del proyecto"
  default     = "dsit"
}

variable "env" {
  type        = string
  description = "Entorno (dev, qa, prod)"
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas obligatorias de la Universidad"
  default = {
    Environment = "Dev"
    Owner       = "DSIT"
    ManagedBy   = "Terraform"
    CostCenter  = "IT-101"
  }
}