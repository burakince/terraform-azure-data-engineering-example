variable "agent_client_id" {}
variable "agent_client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}

# https://azure.microsoft.com/en-us/global-infrastructure/data-residency/#select-geography
variable "location" {
  description = "Datacenter location"
  default     = "uksouth"
}

variable "resource_group_name" {
  default = "myTFResourceGroup"
}
