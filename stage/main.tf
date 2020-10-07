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

  version     = "= 2.30"
  environment = "public"
  features {}
}

resource "random_string" "namesuffix" {
  length  = 8
  upper   = false
  number  = true
  lower   = true
  special = false
}

resource "azurerm_resource_group" "de" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Stage"
    Team        = "DataEngineering"
  }
}

resource "azurerm_data_factory" "ingestion" {
  name                = "${var.organization}ingestion${random_string.namesuffix.result}"
  location            = azurerm_resource_group.de.location
  resource_group_name = azurerm_resource_group.de.name
}

resource "azurerm_data_factory_linked_service_web" "de" {
  name                     = "${var.organization}webservice${random_string.namesuffix.result}"
  resource_group_name      = azurerm_resource_group.de.name
  data_factory_name        = azurerm_data_factory.ingestion.name
  authentication_type      = "Anonymous"
  url                      = "https://api.citybik.es"
}

resource "azurerm_data_factory_dataset_delimited_text" "nextbike-london" {
  name                = "${var.organization}nextbike-london${random_string.namesuffix.result}"
  resource_group_name = azurerm_resource_group.de.name
  data_factory_name   = azurerm_data_factory.ingestion.name
  linked_service_name = azurerm_data_factory_linked_service_web.de.name

  url            = "https://api.citybik.es/v2/networks/nextbike-london"
  request_body   = ""
  request_method = "GET"
}
