resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  count               = "${var.counts}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_public_ip" "pip" {
   name                = "pip${count.index}-pip"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  count               = "${var.counts}"
}

resource "azurerm_virtual_machine_extension" "ADDS" {
  name                 = "ADDS-IIS"
  virtual_machine_id   = azurerm_windows_virtual_machine.example[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  depends_on           = []
  count                = "${var.counts}"

  settings = <<SETTINGS
    
    {
      "fileUris": ["https://raw.githubusercontent.com/eltimmo/learning/master/azureInstallWebServer.ps1"],
      "commandToExecute": "start powershell -ExecutionPolicy Unrestricted -File azureInstallWebServer.ps1"
    }
    
SETTINGS
}
 
resource "azurerm_virtual_machine_extension" "AD-Join2" {
  name                 = "ADJoin2"
  virtual_machine_id   = azurerm_windows_virtual_machine.example.1.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  count                = "${var.counts}"

  settings = <<SETTINGS
    
    {
        "Name": "ad.COM",
        "OUPath": "CN=Computers,DC=ad,DC=com",
        "User": "ad.COM\\adminuser",
        "Password" : "P@$$w0rd1234!",
        "Restart": "true",
        "Options": "3"
    }
    
SETTINGS
}



resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.prefix}-${count.index}-AD"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  count               = "${var.counts}"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example[count.index].id
  ]
  
   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }


}