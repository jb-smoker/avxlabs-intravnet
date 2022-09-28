terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    aviatrix = {
      source = "AviatrixSystems/aviatrix"
    }
    aws = {
      source = "hashicorp/aws"
    }
    guacamole = {
      source = "techBeck03/guacamole"
    }
    ssh = {
      source = "loafoe/ssh"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_region_1
}

provider "aviatrix" {
  controller_ip           = "18.190.10.255"
  username                = "admin"
  password                = "giqqew-ziMce3-wikhuv"
  skip_version_validation = true
}

// Generate random value for the Resource Group name
resource "random_pet" "rg_name" {
  prefix = var.name_prefix
}

// Generate random value for the name
resource "random_string" "name" {
  length  = 8
  upper   = false
  lower   = true
  special = false
}

// Generate random value for the login password
resource "random_password" "password" {
  length           = 8
  upper            = true
  lower            = true
  special          = true
  override_special = "_"
}

// Manages the Resource Group where the resource exists
resource "azurerm_resource_group" "default" {
  name     = "wp-useg-RG-${random_pet.rg_name.id}"
  location = var.location
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}
