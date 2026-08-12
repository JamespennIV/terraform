terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-ad-${var.james}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-ad-${var.james}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = "subnet-ad-${var.james}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "main" {
  name                = "pip-ad-${var.james}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_security_group" "main" {
  name                = "nsg-ad-${var.james}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_interface" "main" {
  name                = "nic-ad-${var.james}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_windows_virtual_machine" "main" {
  name                   = "vm-ad-${var.james}"
  computer_name          = "ad-${var.james}"
  resource_group_name    = azurerm_resource_group.main.name
  location               = var.location
  size                   = "Standard_D2alds_v7"
  admin_username         = "adadmin"
  admin_password         = var.admin_password
  network_interface_ids  = [azurerm_network_interface.main.id]

  # Spot pricing keeps this lab within the Azure for Students free tier limits.
  priority        = "Spot"
  eviction_policy = "Deallocate"
  max_bid_price   = -1

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # Lab convenience only: logs in automatically as adadmin using the unattend answer file.
  # Not a pattern that's safe for production — this leaves the password recoverable from the
  # VM's local unattend.xml. Fine for a disposable lab VM, not for anything real.
  additional_unattend_content {
    content = <<xml
        <AutoLogon>
            <Password>
                <Value>${var.admin_password}</Value>
                <PlainText>true</PlainText>
            </Password>
            <Enabled>true</Enabled>
            <Username>adadmin</Username>
        </AutoLogon>
        xml

    setting = "AutoLogon"
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "main" {
  name                       = "install-ad-ds"
  virtual_machine_id         = azurerm_windows_virtual_machine.main.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  # NOTE: SafeModeAdministratorPassword below reuses var.admin_password.
  # var.dsrm_password is declared and set in terraform.tfvars but not
  # currently wired in here — see lessons-learned.md.
  settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Unrestricted -Command \"Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools; Import-Module ADDSDeployment; Install-ADDSForest -DomainName '${var.domain_name}' -DomainNetbiosName '${var.domain_netbios_name}' -ForestMode 'WinThreshold' -DomainMode 'WinThreshold' -InstallDns:$true -SafeModeAdministratorPassword (ConvertTo-SecureString '${var.admin_password}' -AsPlainText -Force) -Force:$true\""
  })

  tags = var.tags
}
