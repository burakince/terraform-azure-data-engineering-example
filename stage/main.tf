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
  name     = "${var.resource_group_name}-${random_string.namesuffix.result}"
  location = var.location

  tags = {
    Environment = "Stage"
    Team        = "DataEngineering"
  }
}

resource "azurerm_storage_account" "rawdata" {
  name                     = "${var.organization}storage${random_string.namesuffix.result}"
  resource_group_name      = azurerm_resource_group.de.name
  location                 = azurerm_resource_group.de.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

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
  name                = "${var.organization}webservice${random_string.namesuffix.result}"
  resource_group_name = azurerm_resource_group.de.name
  data_factory_name   = azurerm_data_factory.ingestion.name
  authentication_type = "Anonymous"
  url                 = "https://api.citybik.es"
}

resource "azurerm_data_factory_dataset_http" "nextbike-london" {
  name                = "${var.organization}nextbike-london${random_string.namesuffix.result}"
  resource_group_name = azurerm_resource_group.de.name
  data_factory_name   = azurerm_data_factory.ingestion.name
  linked_service_name = azurerm_data_factory_linked_service_web.de.name

  relative_url   = "https://api.citybik.es/v2/networks/nextbike-london"
  request_method = "GET"
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "de" {
  name                = "${var.organization}blobstoragelink${random_string.namesuffix.result}"
  resource_group_name = azurerm_resource_group.de.name
  data_factory_name   = azurerm_data_factory.ingestion.name
  connection_string   = azurerm_storage_account.rawdata.primary_connection_string
}
