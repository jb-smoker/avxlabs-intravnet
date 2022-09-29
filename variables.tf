variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
}

variable "name_prefix" {
  default = "avx-intravnet-wp"
}

variable "application_port" {
  description = "The port that you want to expose to the external load balancer"
  default     = 80
}

variable "admin_username" {
  description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
}

variable "admin_password" {
  description = "Default password for admin account"
}

variable "database_admin_login" {
  default = "wordpress"
}

variable "database_admin_password" {
  description = "Default password for wordpress db"
}

variable "aws_account_name" {
  description = "AWS account label in the Aviatrix controller"
}

variable "azure_account_name" {
  description = "Azure account label in the Aviatrix controller"
}

variable "gcp_account_name" {
  description = "GCP account label in the Aviatrix controller"
}

variable "gcp_region" {
  default = "us-west1"
}

variable "aws_region" {
  default = "us-east-2"
}

variable "azure_region" {
  default = "East US"
}

variable "number_of_web_servers" {
  default = 2
}
