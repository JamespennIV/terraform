variable "james" {
  description = "James - This variable is used to create unique resource names."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "East US"
}

variable "admin_password" {
  description = "The password for the admin user of the virtual machine."
  type        = string
  sensitive   = true
}

variable "dsrm_password" {
  description = "The password for the Directory Services Restore Mode (DSRM) account."
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The domain name for the Active Directory."
  type        = string
  default     = "corp.example.com"
}

variable "domain_netbios_name" {
  description = "The NetBIOS name for the Active Directory domain. (Maximum 15 characters)"
  type        = string
  default     = "CORP"
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default = {
    Project = "ad-lab"
  }
}
