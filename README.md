# Aviatrix IntraVnet Demo

## Description

Terraform to provision a Micro-Segmentation, including IntraVnet, demo topology across AWS, Azure and GCP.  Includes a functional Wordpress application leveraging PaaS for the database tier and cloud-native load-balancers.  It also deploys a global bastion with "Guacamole" and a Windows desktop in the Ingress tier in AWS.

## Diagram

![IntraVnet Infrastructure](/images/topology.png)

## Prerequisites

- Deployed and configured Aviatrix controller with AWS, Azure, and GCP accounts on-boarded.
- Subsciption to [Apache Guacamole packaged by Bitnami](https://aws.amazon.com/marketplace/pp/prodview-qfe3iaudofb5q) in the AWS Marketplace.
- Service limit of \> 5 EIPs in the AWS region being used.

## Example Usage

```hcl
terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "~>2.23.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.21.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.91.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.6.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aviatrix" {
  username                = ""
  password                = ""
  controller_ip           = ""
}

provider "aws" {
  region  = "us-east-2"
}

provider "azurerm" {
  features {}
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
}

provider "google" {
  credentials = ""
  project     = ""
  region      = ""
}

module "intravnet" {
  source                  = "github.com/jb-smoker/avxlabs-intravnet"
  name_prefix             = "avx-intravnet-wp"
  application_port        = "80"
  admin_username          = "student"
  admin_password          = "[your_password_here]"
  database_admin_login    = "student"
  database_admin_password = "[your_password_here]"
  aws_account_name        = "[Access Account label for AWS in the Aviatrix Controller]"
  azure_account_name      = "[Access Account label for AWS in the Aviatrix Controller]"
  gcp_account_name        = "[Access Account label for AWS in the Aviatrix Controller]"
  aws_region_1            = "[AWS Region to use - Default is us-east-2 - must match aws provider setting]"
  azure_region            = "[Azure Region to use - Default is East US]"
  gcp_region              = "[GCP Region to use - Default is us-west1 - must match aws provider setting]]"
  number_of_web_servers   = 2
  tags                    = "{map of tags to be applied to resources}"
}

output "intravnet" {
  value = module.intravnet
}
```
