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

resource "azurerm_data_factory_integration_runtime_managed" "ingestion" {
  name                = "${var.organization}ingestionserver${random_string.namesuffix.result}"
  data_factory_name   = azurerm_data_factory.ingestion.name
  resource_group_name = azurerm_resource_group.de.name
  location            = azurerm_resource_group.de.location

  node_size = "Standard_D2_v3"
}

resource "azurerm_data_factory_linked_service_web" "de" {
  name                     = "${var.organization}webservice${random_string.namesuffix.result}"
  resource_group_name      = azurerm_resource_group.de.name
  data_factory_name        = azurerm_data_factory.ingestion.name
  integration_runtime_name = azurerm_data_factory_integration_runtime_managed.ingestion.name
  authentication_type      = "Anonymous"
  url                      = "https://api.citybik.es"
}

resource "azurerm_data_factory_dataset_json" "nextbike-london" {
  name                = "${var.organization}nextbike-london${random_string.namesuffix.result}"
  resource_group_name = azurerm_resource_group.de.name
  data_factory_name   = azurerm_data_factory.ingestion.name
  linked_service_name = azurerm_data_factory_linked_service_web.de.name

  http_server_location {
    relative_url = "/v2/"
    path         = "networks/"
    filename     = "nextbike-london"
  }

  encoding = "UTF-8"
}