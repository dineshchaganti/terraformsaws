  terraform {
     backend "azurerm" {
    resource_group_name  = "DR-region-rg"
    storage_account_name = "tfstateeastasia1"
    container_name       = "devstate1"
    key                  = "terraform.devstate"
    access_key = "5TY0dztmz+9Gb1Ad+LT7uPd+sa5lFG4uWqATs3HdPSn2bMqnf/ly1ehyvSWlj6Z2Q4b8zXng36Qj+AStpGR+LA=="
     }
  }
  
    provider "azurerm"{
    features {
      
    }
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
    
}

resource "azurerm_resource_group" "newresource" {
    name = "newresource1"
    location = "Australia East"
    tags = {
      "name" = "newresource-Australia East-1"
     }

}

 resource "azurerm_virtual_network" "vntest1" {
     name = "virtualnetwork11"
     location = azurerm_resource_group.newresource.location
     resource_group_name = azurerm_resource_group.newresource.name
     address_space = [ "10.60.0.0/16" ]
 }

 resource "azurerm_subnet" "rsgwebsubnet1" {
     name = "websubnet"
     resource_group_name = azurerm_resource_group.newresource.name
     virtual_network_name = azurerm_virtual_network.vntest1.name
     address_prefixes = [ "10.60.1.0/24" ]

      
 }

 resource "azurerm_subnet" "rsgappsubnet1" {
     name = "appsubnet"
     resource_group_name = azurerm_resource_group.newresource.name
     virtual_network_name = azurerm_virtual_network.vntest1.name
     address_prefixes = [ "10.60.2.0/24" ]


 }



resource "azurerm_subnet" "rsgdbsubnet1" {
     name = "dbsubnet"
     resource_group_name = azurerm_resource_group.newresource.name
     virtual_network_name = azurerm_virtual_network.vntest1.name
     address_prefixes = [ "10.60.3.0/24" ]

}

resource "azurerm_public_ip" "newresourcepip" {
   name = "newresource-ip"
   resource_group_name = azurerm_resource_group.newresource.name
   location = azurerm_resource_group.newresource.location
   allocation_method = "Static"

}

resource "azurerm_network_interface" "newresourcenetworkintf" {
    name = "newresource-nic"
    resource_group_name = azurerm_resource_group.newresource.name
    location = azurerm_resource_group.newresource.location
    ip_configuration {
      name= "newresourceipconfiguration"
      subnet_id = azurerm_subnet.rsgwebsubnet1.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.newresourcepip.id
    }

}
  resource "azurerm_linux_virtual_machine" "newresourcevm1" {
    name = "newresourcews"
    location = azurerm_resource_group.newresource.location
    resource_group_name = azurerm_resource_group.newresource.name
    size = "Standard_F2"
    admin_username = "adminuser"
    network_interface_ids = [ azurerm_network_interface.newresourcenetworkintf.id,]

    admin_ssh_key {
        username = "adminuser"
        public_key = file("~/.ssh/id_rsa.pub")
      
    }

os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
