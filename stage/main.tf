terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
  backend "azurerm" {
    resource_group_name  = "burak-tfstate-rg"
    storage_account_name = "buraktfstate2369"
    container_name       = "tfstate"
    key                  = "stage.terraform.tfstate"
  }

}

provider "azurerm" {
  environment     = "public"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags = {
    Environment = "Stage"
    Team = "DataEngineering"
  }
}
