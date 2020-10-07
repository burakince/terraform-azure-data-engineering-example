terraform {
  backend "azurerm" {
    resource_group_name  = "burak-tfstate-rg"
    storage_account_name = "buraktfstate2369"
    container_name       = "tfstate"
    key                  = "stage.terraform.tfstate"
  }
}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.agent_client_id
  client_secret   = var.agent_client_secret

  version     = "= 2.26"
  environment = "public"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Stage"
    Team        = "DataEngineering"
  }
}
