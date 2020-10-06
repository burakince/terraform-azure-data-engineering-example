variable "agent_client_id" {}
variable "agent_client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}

variable "backend_resource_group_name" {}
variable "backend_storage_account_name" {}

# https://azure.microsoft.com/en-us/global-infrastructure/data-residency/#select-geography
variable "location" {
  description = "Datacenter location"
  default     = "uksouth"
}

variable "resource_group_name" {
  default = "myTFResourceGroup"
}
