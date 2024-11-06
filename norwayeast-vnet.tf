resource "azurerm_virtual_network" "norwayeast-vnet" {
  name = "norwayeast-vnet"
  location = "Norway East"
  resource_group_name = "gindox-network"
  address_space = [ "10.14.47.0/24" ]
  dns_servers = var.dns-global
}

resource "azurerm_subnet" "norwayeast-domain" {
    name = "domain"
    resource_group_name = var.rg
    virtual_network_name = azurerm_virtual_network.norwayeast-vnet.name
    address_prefixes = [ "10.14.47.0/28" ]
}

resource "azurerm_subnet" "norwayeast-storage" {
    name = "storage"
    resource_group_name = var.rg
    virtual_network_name = azurerm_virtual_network.norwayeast-vnet.name
    address_prefixes = [ "10.14.47.16/28" ]
}

resource "azurerm_route_table" "norwayeast-shared-rt" {
  name = "norwayeast-shared-rt"
  location = azurerm_virtual_network.norwayeast-vnet.location
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
        name = "norwayeast"
        address_prefix = "10.14.47.0/24"
        next_hop_type = "VirtualAppliance"
        next_hop_in_ip_address = var.hub-nexthop
    }
}

resource "azurerm_subnet_route_table_association" "norwayeast-domain" {
  subnet_id = azurerm_subnet.norwayeast-domain.id
  route_table_id = azurerm_route_table.norwayeast-shared-rt.id
}

resource "azurerm_subnet_route_table_association" "norwayeast-storage" {
  subnet_id = azurerm_subnet.norwayeast-storage.id
  route_table_id = azurerm_route_table.norwayeast-shared-rt.id
}


resource "azurerm_virtual_network_peering" "norwayeasttohub" {
    name = "norwayeast-to-hub-peer"
    resource_group_name = var.rg
    virtual_network_name = azurerm_virtual_network.norwayeast-vnet.name
    remote_virtual_network_id = var.hub-id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "hubtonorwayeast" {
    name = "hub-to-norwayeast-peer"
    resource_group_name = var.rg
    virtual_network_name = var.hub-name
    remote_virtual_network_id = azurerm_virtual_network.norwayeast-vnet.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
}