output "public_ip" {
  description = "The public IP address of the virtual machine."
  value       = azurerm_public_ip.main.ip_address
}

output "domain_name" {
  description = "The domain name for the Active Directory."
  value       = var.domain_name
}

output "admin_username" {
  description = "The admin username for the virtual machine."
  value       = "adadmin"
}
