# Terraform-CustomeScript-IIS-ADJOIN


# This Repor having , 2 extentios (IIS and AD Domain Join)


# Topic 1 (IIS)
---- How to get the extentios 

AZ CLI command -  {-l = location, -p=Publisher -o=output, -name/n=name of extention}

1. az vm extension image list -l eastus2 -o table  >> Will show list of available extension and publisher.

2. az vm extension image list-names -l southindia -p Microsoft.Compute -o table
                  
                  >> Filter with Publisher (Microsoft.Compute) 
                  
                  
---- How to get the  Version 

 1. az vm extension image list-versions -l southindia -p Microsoft.Compute -n JsonADDomainExtension -o table
 
 ==============================================================================================================
 
 JSON EXAMPLE OF JsonADDomainExtension
 
 {
    "apiVersion": "2015-06-15",
    "type": "Microsoft.Compute/virtualMachines/extensions",
    "name": "MYADJOINEDVM/joindomain",
    "location": "EastUS",
    "properties": {
        "publisher": "Microsoft.Compute",
        "type": "JsonADDomainExtension",
        "typeHandlerVersion": "1.3",
        "autoUpgradeMinorVersion": true,
        "settings": {
            "Name": "JACKSTROMBERG.COM",
            "OUPath": "OU=Users,OU=CustomOU,DC=jackstromberg,DC=com",
            "User": "JACKSTROMBERG.COM\\jack",
            "Restart": "true",
            "Options": "3"
        },
        "protectedSettings": {
            "Password": "SecretPassword!"
        }
    }
}


JSON EXAMPLE OF CustomScriptExtension

{
    "apiVersion": "2018-06-01",
    "type": "Microsoft.Compute/virtualMachines/extensions",
    "name": "config-app",
    "location": "EastUS",
    "properties": {
        "publisher": "Microsoft.Compute",
        "type": "CustomScriptExtension",
        "typeHandlerVersion": "1.9",
        "autoUpgradeMinorVersion": true,
        "settings": {
            "fileUris": [
                "script location"
            ]
        },
        "protectedSettings": {
            "commandToExecute": "myExecutionCommand",
            "storageAccountName": "mystorageaccountname",
            "storageAccountKey": "myStorageAccountKey"
        }
    }
}

===================================================================

TERRAFORM EXAMPLE OF JsonADDomainExtension

resource "azurerm_virtual_machine_extension" "MYADJOINEDVMADDE" {
  name                 = "MYADJOINEDVMADDE"
  location             = "EastUS"
  resource_group_name  = "MyRG"
  virtual_machine_name = "MYADJOINEDVM"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  # What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain

  settings = <<SETTINGS
    {
        "Name": "JACKSTROMBERG.COM",
        "OUPath": "OU=Users,OU=CustomOU,DC=jackstromberg,DC=com",
        "User": "JACKSTROMBERG.COM\\jack",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "SecretPassword!"
    }
  PROTECTED_SETTINGS
  depends_on = ["azurerm_virtual_machine.MYADJOINEDVM"]
}

# NOTE :- Protected_settings and depends_on is not required , you can pass the password key in setting itself.


TERRAFORM EXAMPLE OF CustomScriptExtension

resource "azurerm_virtual_machine_extension" "MYADJOINEDVMCSE" {
  name                 = "MYADJOINEDVMCSE"
  location             = "EastUS"
  resource_group_name  = "MyRG"
  virtual_machine_name = "MYADJOINEDVM"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  # CustomVMExtension Documetnation: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows

  settings = <<SETTINGS
    {
        "fileUris": ["https://mystorageaccountname.blob.core.windows.net/postdeploystuff/post-deploy.ps1"]
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File post-deploy.ps1",
      "storageAccountName": "mystorageaccountname",
      "storageAccountKey": "myStorageAccountKey"
    }
  PROTECTED_SETTINGS
  depends_on = ["azurerm_virtual_machine_extension.MYADJOINEDVMADDE"]
}

OR

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

##################################################################################################################

Reference URLS -
https://jackstromberg.com/2018/11/using-terraform-with-azure-vm-extensions/

https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html

https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows
https://docs.microsoft.com/en-us/powershell/module/az.compute/set-azvmcustomscriptextension?view=azps-3.6.1
https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/features-windows#troubleshoot-vm-extensions
