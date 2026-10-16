resource "azurerm_public_ip" "web_ip" {
    name = "${var.prefix}-web-ip"
    resource_group_name = azurerm_resource_group.example.name
    location = azurerm_resource_group.example.location
    allocation_method = "Static"
}

resource "azurerm_network_interface" "web_nic" {
  name                = "${var.prefix}-web-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet["web"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_ip.id
  }
}


resource "azurerm_linux_virtual_machine" "web_vm" {
  name                = "${var.prefix}-web-vm-1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = var.vm_size
  admin_username      = "adityaadmin"
  network_interface_ids = [
    azurerm_network_interface.web_nic.id,
  ]

  admin_ssh_key {
    username   = "adityaadmin"
    public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}