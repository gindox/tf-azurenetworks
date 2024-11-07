resource "azurerm_virtual_network" "uksouth-vnet" {
  name = "uksouth-vnet"
  location = "UK South"
  resource_group_name = "gindox-network"
  address_space = [ "10.14.44.0/24" ]
  dns_servers = var.dns-global
}

resource "azurerm_subnet" "uksouth-domain" {
    name = "domain"
    resource_group_name = var.rg
    virtual_network_name = azurerm_virtual_network.uksouth-vnet.name
    address_prefixes = [ "10.14.44.0/28" ]
}

resource "azurerm_subnet" "uksouth-storage" {
    name = "storage"
    resource_group_name = var.rg
    virtual_network_name = azurerm_virtual_network.uksouth-vnet.name
    address_prefixes = [ "10.14.44.16/28" ]
}

resource "azurerm_subnet" "uksouth-database" {
    name = "storage"
    resource_group_name = var.rg
    virtual_network_name = azurerm_virtual_network.uksouth-vnet.name
    address_prefixes = [ "10.14.44.128/26" ]

    delegation {
      name = "delegation"

      service_delegation {
        name = "Microsoft.Sql/managedInstances"
      }
    }
}

resource "azurerm_route_table" "uksouth-shared-rt" {
  name = "uksouth-shared-rt"
  location = azurerm_virtual_network.uksouth-vnet.location
  resource_group_name = var.rg
  bgp_route_propagation_enabled = false

    route {
        name = "default"
        address_prefix = "0.0.0.0/0"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.hub-nexthop
    }

    route {
        name = "hub"
        address_prefix = var.hub-network
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.hub-nexthop
    }

    route { 
        name = "uksouth"
        address_prefix = "10.14.44.0/24"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.hub-nexthop
    }
}

resource "azurerm_subnet_route_table_association" "uksouth-domain" {
  subnet_id = azurerm_subnet.uksouth-domain.id
  route_table_id = azurerm_route_table.uksouth-shared-rt.id
}

resource "azurerm_subnet_route_table_association" "uksouth-storage" {
  subnet_id = azurerm_subnet.uksouth-storage.id
  route_table_id = azurerm_route_table.uksouth-shared-rt.id
}


resource "azurerm_virtual_network_peering" "uksouthtohub" {
    name = "uksouth-to-hub-peer"
    resource_group_name = var.rg
    virtual_network_name = azurerm_virtual_network.uksouth-vnet.name
    remote_virtual_network_id = var.hub-id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "hubtouksouth" {
    name = "hub-to-uksouth-peer"
    resource_group_name = var.rg
    virtual_network_name = var.hub-name
    remote_virtual_network_id = azurerm_virtual_network.uksouth-vnet.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}