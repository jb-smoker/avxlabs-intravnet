variable "location" {
  description = "The location where resources will be created"
  default     = "eastus"
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)

  default = {
    application = "Wordpress"
    cloud = "Azure"
  }
}

variable "name_prefix" {
  default = "avx-useg-wp"
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_username" {
  default = "avx-admin"
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
}

variable "admin_password" {
  default = "Aviatrix123#"
  description = "Default password for admin account"
}

variable "database_admin_login" {
  default = "wordpress"
}

variable "database_admin_password" {
  default = "w0rdpr3ssp4ss!"
}

variable "aws_account_name" {
  default = "cmchenry-aviatrix"
}

variable "aws_region_1" {
    default = "us-east-2"
}

variable "azure_region" {
  default = "East US"
}

variable "number_of_web_servers" {
  default = 2
}